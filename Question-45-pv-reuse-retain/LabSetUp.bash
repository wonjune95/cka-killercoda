#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
bash "$HERE/cleanup.sh"
NS=exercise-45; kubectl create ns $NS >/dev/null
cat <<'YAML' | kubectl apply -f - >/dev/null
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mariadb-pv
spec:
  capacity:
    storage: 250Mi
  accessModes: ["ReadWriteOnce"]
  persistentVolumeReclaimPolicy: Retain
  storageClassName: ""
  hostPath:
    path: /mnt/exercise-45
    type: DirectoryOrCreate
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mariadb
  namespace: exercise-45
spec:
  accessModes: ["ReadWriteOnce"]
  storageClassName: ""
  volumeName: mariadb-pv
  resources:
    requests:
      storage: 250Mi
YAML
for i in $(seq 1 30); do [ "$(jp '{.status.phase}' pvc mariadb -n $NS)" = Bound ] && break; sleep 2; done
kubectl delete pvc mariadb -n $NS --wait=true >/dev/null          # the "accident": PV stays, Released
for i in $(seq 1 30); do [ "$(jp '{.status.phase}' pv mariadb-pv)" = Released ] && break; sleep 2; done
cat <<'YAML' > /root/mariadb-deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mariadb
  namespace: exercise-45
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mariadb
  template:
    metadata:
      labels:
        app: mariadb
    spec:
      containers:
      - name: mariadb
        image: mariadb:11.4
        env:
        - name: MARIADB_ROOT_PASSWORD
          value: rootpass
        ports:
        - containerPort: 3306
        volumeMounts:
        - name: mariadb-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: mariadb-storage
        emptyDir: {}
YAML
kubectl get pv mariadb-pv
echo "Lab ready. Deployment file: /root/mariadb-deploy.yaml"
