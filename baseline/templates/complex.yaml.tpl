apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "example.fullName" . | quote }}
  labels:
    {{- include "example.fullLabels" . | nindent 4 }}
spec:
  selector:
    matchLabels:
      {{- include "example.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "example.fullLabels" . | nindent 8 }}
    spec:
      serviceAccountName: {{ include "example.serviceAccountName" . | quote }}
      containers:
        - name: {{ .Chart.Name | quote }}
          image: "docker.io/hashicorp/http-echo:1.0"
