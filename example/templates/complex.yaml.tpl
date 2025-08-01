{{ include "my-chart.setCustom" . }}
{{ toYaml (dict
  "apiVersion" "apps/v1"
  "kind" "Deployment"
  "metadata" (dict
    "name" .Release.Name
    "labels" .custom.labels
  )
  "spec" (dict
    "selector" (dict
      "matchLabels" .custom.labels
    )
    "template" (dict
      "metadata" (dict
        "labels" .custom.labels
      )
      "spec" (dict
        "serviceAccountName" .custom.serviceAccountName
        "containers" (list
          (dict
            "name" .Chart.Name
            "image" "docker.io/hashicorp/http-echo:1.0"
          )
        )
      )
    )
  )
) }}
