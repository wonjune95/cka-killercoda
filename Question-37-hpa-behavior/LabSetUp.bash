#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
ensure_metrics_server
bash "$HERE/cleanup.sh"
kubectl create ns exercise-37 >/dev/null
kubectl -n exercise-37 create deployment apache-server --image=httpd:2.4 >/dev/null
kubectl -n exercise-37 set resources deployment apache-server --requests=cpu=100m,memory=64Mi >/dev/null
kubectl -n exercise-37 rollout status deploy/apache-server --timeout=120s >/dev/null
echo "Lab ready. Deployment exercise-37/apache-server is running."
