#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
bash "$HERE/cleanup.sh"
NS=exercise-54; W=$(worker_node); kubectl create ns $NS >/dev/null; mkdir -p /root/.cka-lab
A=$(jp '{.status.allocatable.cpu}' node $W); case $A in *m) A=${A%m};; *) A=$((A*1000));; esac
M=$(( $(jp '{.status.allocatable.memory}' node $W | tr -d 'Ki') / 1024 ))
CPU=$(( A * 45 / 100 ))m; MEM=$(( M * 40 / 100 ))Mi          # two Pods fill the node, the third stays Pending
echo "$CPU $MEM" > /root/.cka-lab/q54-initial
cat <<YAML | kubectl apply -f - >/dev/null
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress
  namespace: $NS
spec:
  replicas: 3
  selector:
    matchLabels:
      app: wordpress
  template:
    metadata:
      labels:
        app: wordpress
    spec:
      nodeSelector:
        kubernetes.io/hostname: $W
      initContainers:
      - name: init-wordpress
        image: busybox:1.36
        command: ["sh", "-c", "echo preparing wordpress; sleep 2"]
        resources:
          requests:
            cpu: $CPU
            memory: $MEM
      containers:
      - name: wordpress
        image: nginx:1.27
        resources:
          requests:
            cpu: $CPU
            memory: $MEM
YAML
sleep 15
kubectl -n $NS get pods -o wide
echo "Lab ready. Deployment exercise-54/wordpress (3 replicas, bound to $W) requests cpu=$CPU memory=$MEM per container."
