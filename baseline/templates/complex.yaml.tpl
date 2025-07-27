apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "my-chart.fullName" . | quote }}
  labels:
    {{- include "my-chart.fullLabels" . | nindent 4 }}
spec:
  selector:
    matchLabels:
      {{- include "my-chart.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "my-chart.fullLabels" . | nindent 8 }}
    spec:
      serviceAccountName: {{ include "my-chart.serviceAccountName" . | quote }}
      containers:
        - name: {{ .Chart.Name | quote }}
          image: "docker.io/hashicorp/http-echo:1.0"
