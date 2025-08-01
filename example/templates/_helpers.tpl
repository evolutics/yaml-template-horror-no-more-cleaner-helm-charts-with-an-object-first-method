{{ define "my-chart.customObjects" }}

{{ $selectorLabels := dict
  "app.kubernetes.io/name" .Chart.Name
  "app.kubernetes.io/instance" .Release.Name
}}
{{ $fullLabels := merge
  (deepCopy $selectorLabels)
  (dict
    "helm.sh/chart" (printf "%v-%v" .Chart.Name .Chart.Version)
    "app.kubernetes.io/managed-by" .Release.Service
  )
  (deepCopy .Values.extraLabels)
}}
{{ $fullName := contains .Chart.Name .Release.Name | ternary
  .Release.Name
  (printf "%v-%v" .Release.Name .Chart.Name)
}}
{{ $serviceAccountName := default
  (.Values.serviceAccount.create | ternary $fullName "default")
  .Values.serviceAccount.name
}}

{{ $_ := set . "custom" (dict
  "fullLabels" $fullLabels
  "fullName" $fullName
  "selectorLabels" $selectorLabels
  "serviceAccountName" $serviceAccountName
)
}}

{{ end }}
