{{ include "my-chart.customObjects" . }}
{{ toYaml (dict
  "apiVersion" "v1"
  "kind" "ServiceAccount"
  "metadata" (dict
    "name" .custom.serviceAccountName
    "labels" .custom.fullLabels
    "annotations" .Values.serviceAccount.annotations
  )
  "automountServiceAccountToken" .Values.serviceAccount.automount
) }}
