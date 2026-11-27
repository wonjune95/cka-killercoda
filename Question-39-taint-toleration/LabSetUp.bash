#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
bash "$HERE/cleanup.sh"
kubectl create ns exercise-39 >/dev/null
echo "Lab ready. Worker node: $(worker_node)"
