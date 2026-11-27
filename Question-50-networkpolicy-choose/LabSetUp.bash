#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
bash "$HERE/cleanup.sh"
F=exercise-50-frontend; B=exercise-50-backend
kubectl create ns $F >/dev/null; kubectl create ns $B >/dev/null
kubectl -n $F create deployment frontend --image=nginx:1.27 >/dev/null
kubectl -n $F create deployment other --image=nginx:1.27 >/dev/null
kubectl -n $B create deployment backend --image=nginx:1.27 --port=80 >/dev/null
kubectl -n $B expose deployment backend --port=80 >/dev/null
cat <<'YAML' | kubectl apply -f - >/dev/null
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: exercise-50-backend
spec:
  podSelector: {}
  policyTypes: [Ingress]
YAML
mkdir -p /root/netpol /root/.cka-lab
np(){ printf 'apiVersion: networking.k8s.io/v1\nkind: NetworkPolicy\nmetadata:\n  name: %s\n  namespace: exercise-50-backend\nspec:\n  podSelector:\n    matchLabels:\n      app: backend\n  policyTypes:\n  - Ingress\n  ingress:\n%s\n' "$1" "$2" > /root/netpol/$1.yaml; }
np netpol-1 '  - from:
    - namespaceSelector: {}'
np netpol-2 '  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: exercise-50-frontend
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 80'
np netpol-3 '  - from:
    - ipBlock:
        cidr: 0.0.0.0/0
    ports:
    - protocol: TCP
      port: 80'
np netpol-4 '  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: exercise-50-frontend
      podSelector:
        matchLabels:
          app: frontend'
np netpol-5 '  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: exercise-50-frontend
      podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 80'
kubectl -n $B get netpol deny-all -o jsonpath='{.spec}' > /root/.cka-lab/q50-denyall
for n in $F $B; do kubectl -n $n rollout status deploy --timeout=120s >/dev/null; done
ls /root/netpol
echo "Lab ready."
