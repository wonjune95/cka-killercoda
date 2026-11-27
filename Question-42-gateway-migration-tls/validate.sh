#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
NS=exercise-42; GW="gateway web-gateway -n $NS"; RT="httproute web-route -n $NS"; H=gateway.web.k8s.local
banner "Validating Question 42"
eq "Gateway class" "$(jp '{.spec.gatewayClassName}' $GW)" eg
L='{.spec.listeners[?(@.protocol=="HTTPS")]'
eq "HTTPS listener on 443 for $H" "$(jp "$L.port} $L.hostname}" $GW)" "443 $H"
eq "listener terminates TLS with Secret web-tls" "$(jp "$L.tls.mode} $L.tls.certificateRefs[0].name}" $GW)" "Terminate web-tls"
for i in $(seq 1 20); do [ "$(jp '{.status.conditions[?(@.type=="Programmed")].status}' $GW)" = True ] && break; sleep 3; done
eq "Gateway Programmed" "$(jp '{.status.conditions[?(@.type=="Programmed")].status}' $GW)" True
eq "HTTPRoute parent" "$(jp '{.spec.parentRefs[0].name}' $RT)" web-gateway
eq "HTTPRoute hostname" "$(jp '{.spec.hostnames[*]}' $RT)" $H
eq "HTTPRoute / -> web:80" "$(jp '{.spec.rules[0].matches[0].path.value} {.spec.rules[0].backendRefs[0].name}:{.spec.rules[0].backendRefs[0].port}' $RT)" "/ web:80"
eq "HTTPRoute Accepted" "$(jp '{.status.parents[0].conditions[?(@.type=="Accepted")].status}' $RT)" True
SVC=$(jp '{.items[0].metadata.name}' svc -n envoy-gateway-system -l gateway.envoyproxy.io/owning-gateway-name=web-gateway,gateway.envoyproxy.io/owning-gateway-namespace=$NS)
NP=$(jp '{.spec.ports[?(@.port==443)].nodePort}' svc "$SVC" -n envoy-gateway-system)
IP=$(jp '{.status.addresses[?(@.type=="InternalIP")].address}' node $(worker_node))
C=$(curl -sk -m5 -o /dev/null -w '%{http_code}' --resolve $H:$NP:$IP https://$H:$NP/ 2>/dev/null)
eq "HTTPS 200 through the Gateway" "$C" 200
if kubectl get ingress web -n $NS >/dev/null 2>&1; then fail "Ingress web still exists - delete it"; else pass "Ingress web deleted"; fi
summary
