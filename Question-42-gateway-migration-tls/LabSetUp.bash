#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
ensure_envoy_gateway
bash "$HERE/cleanup.sh"
NS=exercise-42; kubectl create ns $NS >/dev/null
T=$(mktemp -d)
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $T/tls.key -out $T/tls.crt -subj "/CN=web.k8s.local" \
  -addext "subjectAltName=DNS:web.k8s.local,DNS:gateway.web.k8s.local" >/dev/null 2>&1
kubectl -n $NS create secret tls web-tls --cert=$T/tls.crt --key=$T/tls.key >/dev/null; rm -rf $T
kubectl -n $NS create deployment web --image=nginx:1.28 >/dev/null
kubectl -n $NS expose deployment web --port=80 >/dev/null
cat <<'YAML' | kubectl apply -f - >/dev/null
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web
  namespace: exercise-42
spec:
  ingressClassName: nginx
  tls:
  - hosts: ["web.k8s.local"]
    secretName: web-tls
  rules:
  - host: web.k8s.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web
            port:
              number: 80
YAML
kubectl -n $NS rollout status deploy/web --timeout=120s >/dev/null
echo "Lab ready. Ingress exercise-42/web exists; GatewayClass eg is installed."
