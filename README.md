# YAML Template Horror No More: Cleaner Helm Charts with an Object-First Method

Most Helm chart templates look something like this:

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "example.fullName" . }}
  labels:
    {{- include "example.fullLabels" . | nindent 4 }}
  {{- with .Values.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
data:
  foo: "bar"
```

The construction of a Kubernetes object is mixed with its YAML encoding.

Consider this form instead:

```
{{ include "example.customObjects" . }}
{{ (dict
  "apiVersion" "v1"
  "kind" "ConfigMap"
  "metadata" (dict
    "name" .custom.fullName
    "labels" .custom.fullLabels
    "annotations" .Values.annotations
  )
  "data" (dict
    "foo" "bar"
  )
) | toYaml }}
```

Here the object is first fully constructed using template functions like `dict`.
The encoding happens only at the very end with `toYaml`.
