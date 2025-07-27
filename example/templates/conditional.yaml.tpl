{{ include "example.customObjects" . }}
{{ (.Values.serviceAccount.create | ternary
  (dict
    "apiVersion" "v1"
    "kind" "ServiceAccount"
    "metadata" (dict
      "name" .custom.serviceAccountName
      "labels" .custom.fullLabels
    )
    "automountServiceAccountToken" true
  )
  nil
) | toYaml }}
