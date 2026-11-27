#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
bash "$HERE/cleanup.sh"
kubectl create ns exercise-47 >/dev/null
cat <<'YAML' | kubectl apply -f - >/dev/null
apiVersion: v1
kind: Pod
metadata:
  name: orange
  namespace: exercise-47
spec:
  initContainers:
  - name: init-myservice
    image: busybox:1.36
    command: ["sh", "-c", "sleeeep 2"]
  containers:
  - name: orange-container
    image: busybox:1.36
    command: ["sh", "-c", "echo The app is running! && sleep 3600"]
YAML
echo "Lab ready. Pod exercise-47/orange does not start."
