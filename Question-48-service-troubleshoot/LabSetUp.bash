#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
bash "$HERE/cleanup.sh"
NS=exercise-48; kubectl create ns $NS >/dev/null
kubectl -n $NS create deployment web --image=nginx:1.27 --replicas=2 --port=80 >/dev/null
cat <<'YAML' | kubectl apply -f - >/dev/null
apiVersion: v1
kind: Service
metadata:
  name: web-svc
  namespace: exercise-48
spec:
  selector:
    app: webapp
  ports:
  - port: 80
    targetPort: 8080
YAML
kubectl -n $NS rollout status deploy/web --timeout=120s >/dev/null
mkdir -p /root/.cka-lab; kubectl -n $NS get deploy web -o jsonpath='{.spec.template}' > /root/.cka-lab/q48-deploy
echo "Lab ready. Service exercise-48/web-svc does not answer."
