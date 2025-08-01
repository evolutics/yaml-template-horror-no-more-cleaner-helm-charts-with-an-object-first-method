{{ include "my-chart.customObjects" . }}
{{ toYaml (.Values.serviceAccount.create | ternary
  (dict
    "apiVersion" "v1"
    "kind" "ServiceAccount"
    "metadata" (dict
      "name" .custom.serviceAccountName
      "labels" .custom.labels
      "annotations" .Values.serviceAccount.annotations
    )
    "automountServiceAccountToken" .Values.serviceAccount.automount
  )
  nil
) }}
