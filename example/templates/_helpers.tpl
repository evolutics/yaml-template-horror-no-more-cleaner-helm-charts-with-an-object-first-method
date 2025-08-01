{{ define "my-chart.customObjects" }}
{{ $_ := set . "custom" (dict
  "labels" (dict
    "app.kubernetes.io/name" .Chart.Name
    "app.kubernetes.io/instance" .Release.Name
  )
  "serviceAccountName" (default .Release.Name .Values.serviceAccount.name)
) }}
{{ end }}
