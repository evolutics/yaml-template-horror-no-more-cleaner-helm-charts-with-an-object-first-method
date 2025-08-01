apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name | quote }}
  labels:
    {{- include "my-chart.labels" . | nindent 4 }}
spec:
  selector:
    matchLabels:
      {{- include "my-chart.labels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "my-chart.labels" . | nindent 8 }}
    spec:
      serviceAccountName: {{ include "my-chart.serviceAccountName" . | quote }}
      containers:
        - name: {{ .Chart.Name | quote }}
          image: "docker.io/hashicorp/http-echo:1.0"
