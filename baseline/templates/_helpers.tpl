{{- define "example.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name | quote }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
{{- end }}

{{- define "example.fullLabels" -}}
{{ include "example.selectorLabels" . }}
helm.sh/chart: {{ printf "%v-%v" .Chart.Name .Chart.Version | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
{{- with .Values.extraLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{- define "example.fullName" -}}
{{- if contains .Chart.Name .Release.Name }}
{{- .Release.Name }}
{{- else }}
{{- printf "%v-%v" .Release.Name .Chart.Name }}
{{- end }}
{{- end }}

{{- define "example.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "example.fullName" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
