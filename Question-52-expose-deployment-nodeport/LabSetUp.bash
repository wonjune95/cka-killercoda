#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
bash "$HERE/cleanup.sh"
NS=exercise-52; kubectl create ns $NS >/dev/null
kubectl -n $NS create deployment front-end --image=nginx:1.27 --replicas=2 >/dev/null
kubectl -n $NS rollout status deploy/front-end --timeout=180s >/dev/null
echo "Lab ready. Deployment exercise-52/front-end is running (container nginx, no ports declared)."
