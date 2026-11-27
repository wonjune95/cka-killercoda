#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
bash "$HERE/cleanup.sh"
NS=project-snake; kubectl create ns $NS >/dev/null
pod(){ # name app text listen-lines
  cat <<YAML | kubectl apply -f - >/dev/null
apiVersion: v1
kind: ConfigMap
metadata:
  name: $1-conf
  namespace: $NS
data:
  default.conf: |
    server {
      $4
      default_type text/plain;
      location / { return 200 '$3'; }
    }
---
apiVersion: apps/v1
kind: StatefulSet            # pod $2-0; a controller recreates it if node01 is removed (Q08)
metadata:
  name: $2
  namespace: $NS
spec:
  serviceName: $2
  replicas: 1
  selector:
    matchLabels:
      app: $2
  template:
    metadata:
      labels:
        app: $2
    spec:
      containers:
      - name: nginx
        image: nginx:1-alpine
        volumeMounts:
        - name: conf
          mountPath: /etc/nginx/conf.d
      volumes:
      - name: conf
        configMap:
          name: $1-conf
YAML
}
pod backend-0 backend "backend" "listen 80;"
pod db1-0 db1 "database one" "listen 1111; listen 2222;"
pod db2-0 db2 "database two" "listen 1111; listen 2222;"
pod vault-0 vault "vault secret storage" "listen 3333;"
for s in backend db1 db2 vault; do kubectl -n $NS rollout status sts/$s --timeout=180s >/dev/null; done
echo "Q15 ready: namespace project-snake"
