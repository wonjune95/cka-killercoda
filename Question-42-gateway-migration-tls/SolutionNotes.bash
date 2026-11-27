kubectl -n exercise-42 get ingress web -o yaml       # tls.secretName web-tls, rule / -> web:80
kubectl get gatewayclass                              # eg
cat <<'EOF2' | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: web-gateway
  namespace: exercise-42
spec:
  gatewayClassName: eg
  listeners:
  - name: https
    protocol: HTTPS
    port: 443
    hostname: gateway.web.k8s.local
    tls:
      mode: Terminate
      certificateRefs:
      - kind: Secret
        name: web-tls
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: web-route
  namespace: exercise-42
spec:
  parentRefs:
  - name: web-gateway
  hostnames:
  - gateway.web.k8s.local
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: web
      port: 80
EOF2
kubectl -n exercise-42 get gateway,httproute         # PROGRAMMED True
SVC=$(kubectl get svc -n envoy-gateway-system -l gateway.envoyproxy.io/owning-gateway-name=web-gateway -o jsonpath='{.items[0].metadata.name}')
NP=$(kubectl get svc $SVC -n envoy-gateway-system -o jsonpath='{.spec.ports[?(@.port==443)].nodePort}')
IP=$(kubectl get node node01 -o jsonpath='{.status.addresses[?(@.type=="InternalIP")].address}')
curl -k --resolve gateway.web.k8s.local:$NP:$IP https://gateway.web.k8s.local:$NP
kubectl -n exercise-42 delete ingress web
# 참고: 문법이 기억나지 않으면 kubectl explain gateway.spec.listeners.tls
