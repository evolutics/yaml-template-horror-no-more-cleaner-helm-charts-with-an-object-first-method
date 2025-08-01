{{- define "my-chart.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name | quote }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
{{- end }}

{{- define "my-chart.serviceAccountName" -}}
{{- default .Release.Name .Values.serviceAccount.name }}
{{- end }}
