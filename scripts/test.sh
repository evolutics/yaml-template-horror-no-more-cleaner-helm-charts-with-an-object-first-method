#!/bin/bash

set -o errexit -o nounset -o pipefail

cd -- "$(dirname -- "$0")/.."

travel-kit

helm lint --strict example
