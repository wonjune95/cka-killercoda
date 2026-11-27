#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
bash "$HERE/cleanup.sh"
NS=exercise-53; kubectl create ns $NS >/dev/null; mkdir -p /root/.cka-lab
kubectl create priorityclass user-low --value=1000 --description="low priority user workloads" >/dev/null
kubectl create priorityclass user-medium --value=50000 --description="medium priority user workloads" >/dev/null
kubectl create priorityclass user-critical --value=$(( 900000 + RANDOM % 90000 )) --description="critical user workloads" >/dev/null
kubectl -n $NS create deployment busybox-logger --image=busybox:1.36 -- sh -c 'while true; do date; sleep 5; done' >/dev/null
kubectl -n $NS create deployment web --image=nginx:1.27 >/dev/null
kubectl -n $NS rollout status deploy/busybox-logger --timeout=180s >/dev/null
kubectl -n $NS rollout status deploy/web --timeout=180s >/dev/null
kubectl -n $NS get deploy web -o jsonpath='{.spec.template}' > /root/.cka-lab/q53-web
kubectl get priorityclass
echo "Lab ready. Deployments busybox-logger and web run in namespace exercise-53."
