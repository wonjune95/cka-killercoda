#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
ensure_local_path
bash "$HERE/cleanup.sh"
mkdir -p /root/.cka-lab
# remember which classes are default now (restored by cleanup), then make local-path the default
kubectl get sc -o jsonpath='{range .items[*]}{.metadata.name} {.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}{"\n"}{end}' \
  | awk '$2=="true"{print $1}' > /root/.cka-lab/q44-defaults
kubectl annotate sc local-path storageclass.kubernetes.io/is-default-class=true --overwrite >/dev/null
NS=exercise-44; kubectl create ns $NS >/dev/null
cat <<'YAML' | kubectl apply -f - >/dev/null
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-data
  namespace: exercise-44
spec:
  accessModes: ["ReadWriteOnce"]
  storageClassName: local-path
  resources:
    requests:
      storage: 1Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
  namespace: exercise-44
spec:
  replicas: 1
  selector:
    matchLabels: {app: app}
  template:
    metadata:
      labels: {app: app}
    spec:
      containers:
      - name: app
        image: busybox:1.36
        command: ["sleep", "3600"]
        volumeMounts: [{name: data, mountPath: /data}]
      volumes:
      - name: data
        persistentVolumeClaim: {claimName: app-data}
YAML
kubectl -n $NS rollout status deploy/app --timeout=180s >/dev/null
kubectl -n $NS get deploy app -o jsonpath='{.spec.template}' > /root/.cka-lab/q44-deploy
kubectl -n $NS get pvc app-data -o jsonpath='{.spec}' > /root/.cka-lab/q44-pvc
kubectl get storageclass
echo "Lab ready."
