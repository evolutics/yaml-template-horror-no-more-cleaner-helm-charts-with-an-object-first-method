#!/bin/bash

set -o errexit -o nounset -o pipefail

cd -- "$(dirname -- "$0")/.."

travel-kit

for equal_file in Chart.yaml values.yaml; do
  diff --unified "baseline/${equal_file}" "example/${equal_file}"
done

helm lint --strict baseline
helm lint --strict example

for test_case in tests/*; do
  bad="$(helm template --values "${test_case}/values.yaml" baseline)"
  good="$(helm template --values "${test_case}/values.yaml" example)"

  actual_diff="$(diff --label 'Bad' --label 'Good' --unified \
    <(echo "${bad}" | yq --sort-keys) <(echo "${good}" | yq --sort-keys))" \
    || true

  diff --label 'Actual diff' --unified <(echo "${actual_diff}") \
    "${test_case}/expected_diff.txt"
done
