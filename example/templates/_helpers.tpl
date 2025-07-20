{{- define "example.customObjects" -}}

{{- $fullName := contains .Chart.Name .Release.Name | ternary
  .Release.Name
  (printf "%v-%v" .Release.Name .Chart.Name)
-}}
{{- $selectorLabels := dict
  "app.kubernetes.io/name" .Chart.Name
  "app.kubernetes.io/instance" .Release.Name
-}}
{{- $fullLabels := merge
  (deepCopy $selectorLabels)
  (dict
    "helm.sh/chart" (printf "%v-%v" .Chart.Name .Chart.Version)
    "app.kubernetes.io/managed-by" .Release.Service
  )
  (deepCopy .Values.extraLabels)
-}}
{{- $serviceAccountName := default
  (.Values.serviceAccount.create | ternary $fullName "default")
  .Values.serviceAccount.name
-}}

{{- $_ := set . "custom" (dict
  "fullName" $fullName
  "fullLabels" $fullLabels
  "selectorLabels" $selectorLabels
  "serviceAccountName" $serviceAccountName
)
-}}

{{- end -}}
