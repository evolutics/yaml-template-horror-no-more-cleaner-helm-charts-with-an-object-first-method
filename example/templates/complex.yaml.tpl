{{ include "my-chart.customObjects" . }}
{{ toYaml (dict
  "apiVersion" "apps/v1"
  "kind" "Deployment"
  "metadata" (dict
    "name" .custom.fullName
    "labels" .custom.fullLabels
  )
  "spec" (dict
    "selector" (dict
      "matchLabels" .custom.selectorLabels
    )
    "template" (dict
      "metadata" (dict
        "labels" .custom.fullLabels
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
