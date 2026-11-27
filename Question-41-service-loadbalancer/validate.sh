#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
NS=exercise-41; S="svc lb-web-svc -n $NS"; W=$(worker_node)
banner "Validating Question 41"
kubectl rollout status deploy/lb-web -n $NS --timeout=90s >/dev/null 2>&1
eq "Deployment lb-web 2 ready" "$(jp '{.status.readyReplicas}' deploy lb-web -n $NS)" 2
eq "Service type" "$(jp '{.spec.type}' $S)" LoadBalancer
eq "Service port" "$(jp '{.spec.ports[0].port}' $S)" 80
N=$(jp '{range .items[*].endpoints[*]}{.addresses[0]}{"\n"}{end}' endpointslices -n $NS -l kubernetes.io/service-name=lb-web-svc | grep -c .)
eq "Service has 2 endpoints" "$N" 2
NP=$(jp '{.spec.ports[0].nodePort}' $S)
IP=$(jp '{.status.addresses[?(@.type=="InternalIP")].address}' node $W)
if [ -n "$NP" ] && curl -s -m5 "http://$IP:$NP" | grep -qi 'welcome to nginx'; then pass "answers on NodePort $IP:$NP"; else fail "no answer on the NodePort"; fi
summary
