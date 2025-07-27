# YAML Template Horror No More: Cleaner Helm Charts with an Object-First Method

Most Helm chart templates look something like this:

```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ include "example.serviceAccountName" . | quote }}
  labels:
    {{- include "example.fullLabels" . | nindent 4 }}
  {{- with .Values.serviceAccount.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
automountServiceAccountToken: {{ .Values.serviceAccount.automount }}
```

The construction of a Kubernetes object is mixed with its YAML encoding.

Consider this form instead:

```
{{ include "example.customObjects" . }}
{{ (dict
  "apiVersion" "v1"
  "kind" "ServiceAccount"
  "metadata" (dict
    "name" .custom.serviceAccountName
    "labels" .custom.fullLabels
    "annotations" .Values.serviceAccount.annotations
  )
  "automountServiceAccountToken" .Values.serviceAccount.automount
) | toYaml }}
```

Here the object is first fully constructed using template functions like `dict`.
The encoding happens only at the very end with `toYaml`.
