#!/bin/bash

set -o errexit -o nounset -o pipefail

cd -- "$(dirname -- "$0")/.."

travel-kit

for equal_file in Chart.yaml values.yaml; do
  diff --unified "baseline/${equal_file}" "example/${equal_file}"
done

helm lint --strict baseline
helm lint --strict example
