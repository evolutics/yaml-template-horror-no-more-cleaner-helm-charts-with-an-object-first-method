{{ include "example.customObjects" . }}
{{ (dict
  "apiVersion" "v1"
  "kind" "ServiceAccount"
  "metadata" (dict
    "name" .custom.serviceAccountName
    "labels" .custom.fullLabels
  )
  "automountServiceAccountToken" true
) | toYaml }}
