# Question 42 - Migrate an Ingress (with TLS) to the Gateway API  (Services & Networking | Hard | 20 min)
# 한글: 원본 시험 5번. TLS가 있는 Ingress를 Gateway + HTTPRoute로 옮기고 Ingress를 지운다 (GatewayClass는 eg).
#       시험에서는 GatewayClass 이름이 nginx 였지만, 이 랩은 Envoy Gateway 의 eg 를 쓴다.
#
# Namespace exercise-42 runs a web application exposed by the Ingress web (TLS, host web.k8s.local).
# The GatewayClass eg is installed. Migrate the application from the Ingress to the Gateway API;
# HTTPS access must keep working.
#
# 1. Create a Gateway named web-gateway with the hostname gateway.web.k8s.local that keeps the
#    TLS and listener configuration of the existing Ingress web
# 2. Create an HTTPRoute named web-route with the hostname gateway.web.k8s.local that keeps the
#    routing rules of the existing Ingress web
# 3. Test it (the Envoy proxy is a NodePort Service in envoy-gateway-system), e.g.:
#      curl -k --resolve gateway.web.k8s.local:<nodeport>:<node-ip> https://gateway.web.k8s.local:<nodeport>
# 4. Finally delete the Ingress web
