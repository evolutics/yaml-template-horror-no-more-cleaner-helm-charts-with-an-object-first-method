# YAML Template Horror No More: Cleaner Helm Charts with an Object-First Style

Helm charts are probably the most common package format to distribute Kubernetes
applications. Parametrization of those packages is supported by Go templates to
generate variations of YAML manifests. These templates are usually written in a
somewhat fragile style because the construction of Kubernetes manifest objects
is entangled with their YAML serialization. However, there is an alternative for
cleaner templates – without extra tooling.

In a hurry? Jump right to the [proposed alternative](#alternative-style)!

## Status quo

Helm chart templates often look something like this:

```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ include "my-chart.serviceAccountName" . | quote }}
  labels:
    {{- include "my-chart.labels" . | nindent 4 }}
  {{- with .Values.serviceAccount.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
automountServiceAccountToken: {{ .Values.serviceAccount.automount }}
```

It is easy to see where such templates come from: take a plain YAML manifest as
a base and then gradually introduce placeholders `{{ … }}` where parametrization
is desired. This is effectively string interpolation with user-provided
`.Values` and text from named templates to `include`.

This text-first style has its complications.

First, it is well known that indentation must be carefully addressed, as is done
using `nindent 4` for labels. The number 4 here is sensitively tied to its
context; it would have to change when used at another nesting level (for
instance, to `nindent 8` for pod metadata in a deployment spec).

Moreover, the example template makes sure the object name is quoted as a string
by applying the function `quote`, preventing issues with escaping or unquoted
words representing non-string literals such as the Boolean `no`.

In short, instead of focussing on Kubernetes manifests, maintainers need to pay
much of their attention to serialization in templates, with readability
suffering.

## Alternative style

It would be desirable to work directly with Kubernetes manifest objects, leaving
the entire business of YAML serialization up to a tool.

Thus, consider the following two-phase approach for a clean separation of
concerns:

1. Construct a Kubernetes manifest object, that is, a (possibly nested)
   structure made from maps, lists, strings, integers, Booleans, etc. No
   serialization at this point.
1. Serialize the whole Kubernetes manifest object using `toYaml`.

The first phase of constructing objects is supported by Helm template functions
such as `dict` or `list`. For instance, the template expression
`dict "a" "b" "c" 3` represents a map `{"a": "b", "c": 3}`.

Rewritten in an object-first style, above example is equivalent to this:

```
{{ include "my-chart.setCustom" . }}
{{ toYaml (dict
  "apiVersion" "v1"
  "kind" "ServiceAccount"
  "metadata" (dict
    "name" .custom.serviceAccountName
    "labels" .custom.labels
    "annotations" .Values.serviceAccount.annotations
  )
  "automountServiceAccountToken" .Values.serviceAccount.automount
) }}
```

The `include` on the first line does not render anything on its own but provides
extra values to be shared between templates under the name `.custom`. For this
purpose, the template `my-chart.setCustom` is defined in `_helpers.tpl` like so:

```
{{ define "my-chart.setCustom" }}
{{ $_ := set . "custom" (dict
  "labels" (dict
    "app.kubernetes.io/name" .Chart.Name
    "app.kubernetes.io/instance" .Release.Name
  )
  "serviceAccountName" (default .Release.Name .Values.serviceAccount.name)
) }}
{{ end }}
```

The function `set` on line 2 mutates a map (dot `.` in this case) by setting the
given key `"custom"` to the given value `dict …`. Note that while `set` mutates
a map in place, it still returns the map; we assign the returned map to a dummy
variable `$_` as otherwise the template engine tries to render it.

While real-world Helm charts are surely more complex than this example, it shows
the basics of how to put object construction at the center of our code, with
serialization left only to the boundary.

## Alternative applied to common patterns

The following shows how to express commonly seen patterns in the alternative.

### Maps, lists

```diff
-image: my-image
-env:
-  - name: LOG_LEVEL
-    value: "debug"
-  - name: PORT
-    value: "443"

+dict
+  "image" "my-image"
+  "env" (list
+    (dict
+      "name" "LOG_LEVEL"
+      "value" "debug"
+    )
+    (dict
+      "name" "PORT"
+      "value" "443"
+    )
+  )
```

### Conditional

```diff
-{{- if contains $name .Release.Name }}
-{{- .Release.Name }}
-{{- else }}
-{{- printf "%v-%v" .Release.Name $name }}
-{{- end }}

+{{- contains $name .Release.Name | ternary
+  .Release.Name
+  (printf "%v-%v" .Release.Name $name)
+-}}
```

### Merging maps

```diff
-{{- with .Values.baseLabels }}
-{{ toYaml . }}
-{{- end }}
-{{- with .Values.extraLabels }}
-{{ toYaml . }}
-{{- end }}

+merge (deepCopy .Values.baseLabels) (deepCopy .Values.extraLabels)
```

Tricky here:
[`merge`](https://helm.sh/docs/chart_template_guide/function_list/#merge-mustmerge)
modifies its arguments as a side effect, hence the calls to `deepCopy`.

### Conditional creation of Kubernetes object

```diff
-{{- if .Values.serviceAccount.create -}}
-apiVersion: v1
-kind: ServiceAccount
-metadata: …
-{{- end }}

+{{ toYaml (.Values.serviceAccount.create | ternary
+  (dict
+    "apiVersion" "v1"
+    "kind" "ServiceAccount"
+    "metadata" …
+  )
+  nil
+) }}
```

The `nil` in the else case is serialized as YAML `null`, which is equivalent to
an empty YAML file.

## Alternatives for variable Kubernetes manifests

The assumption so far has been that you need to author your own Helm charts,
perhaps because users of your Kubernetes application favor Helm.

If that is not the case, but you just need to generate variations of your
Kubernetes manifests (for instance, to support different environments), there
are more options to consider:

- [Kustomize](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/)
  (`kubectl apply --kustomize …`)
- [Skaffold](https://skaffold.dev)
- [Terraform](https://developer.hashicorp.com/terraform)
- Any programming language with JSON/YAML serialization
