#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
bash "$HERE/cleanup.sh"
NS=exercise-51; kubectl create ns $NS >/dev/null; mkdir -p /root/.cka-lab
cat <<'YAML' | kubectl apply -f - >/dev/null
apiVersion: apps/v1
kind: Deployment
metadata:
  name: synergy-deployment
  namespace: exercise-51
spec:
  replicas: 1
  selector:
    matchLabels:
      app: synergy
  template:
    metadata:
      labels:
        app: synergy
    spec:
      containers:
      - name: synergy
        image: busybox:stable
        command: ["/bin/sh", "-c", "while true; do echo \"$(date) INFO synergy legacy app is working\" >> /var/log/synergy-deployment.log; sleep 2; done"]
YAML
kubectl -n $NS rollout status deploy/synergy-deployment --timeout=180s >/dev/null
kubectl -n $NS get deploy synergy-deployment -o jsonpath='{.spec.template.spec.containers[0].image}|{.spec.template.spec.containers[0].command}' > /root/.cka-lab/q51-main
echo "Lab ready. Deployment exercise-51/synergy-deployment writes /var/log/synergy-deployment.log."
