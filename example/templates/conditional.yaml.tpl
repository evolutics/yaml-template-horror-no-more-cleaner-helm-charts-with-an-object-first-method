{{ include "example.customObjects" . }}
{{ (.Values.serviceAccount.create | ternary
  (dict
    "apiVersion" "v1"
    "kind" "ServiceAccount"
    "metadata" (dict
      "name" .custom.serviceAccountName
      "labels" .custom.fullLabels
      "annotations" .Values.serviceAccount.annotations
    )
    "automountServiceAccountToken" .Values.serviceAccount.automount
  )
  nil
) | toYaml }}
