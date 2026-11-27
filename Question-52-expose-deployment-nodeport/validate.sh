#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
NS=exercise-52; D="deploy front-end -n $NS"; S="svc front-end-svc -n $NS"
banner "Validating Question 52"
P=$(jp '{range .spec.template.spec.containers[?(@.name=="nginx")]}{range .ports[*]}{.containerPort}/{.protocol}{"\n"}{end}{end}' $D)
if echo "$P" | grep -qx '80/TCP'; then pass "container nginx declares port 80/TCP"; else fail "container nginx does not declare containerPort 80/TCP (got '$(echo $P)')"; fi
eq "container image unchanged" "$(jp '{.spec.template.spec.containers[?(@.name=="nginx")].image}' $D)" nginx:1.27
kubectl rollout status $D --timeout=120s >/dev/null 2>&1
eq "Deployment front-end 2 ready" "$(jp '{.status.readyReplicas}' $D)" 2
eq "Service type" "$(jp '{.spec.type}' $S)" NodePort
eq "Service port/protocol" "$(jp '{.spec.ports[0].port}/{.spec.ports[0].protocol}' $S)" 80/TCP
N=$(jp '{range .items[*].endpoints[*]}{.addresses[0]}{"\n"}{end}' endpointslices -n $NS -l kubernetes.io/service-name=front-end-svc | grep -c .)
eq "Service has 2 endpoints" "$N" 2
eq "endpoints use port 80" "$(jp '{.items[0].ports[0].port}' endpointslices -n $NS -l kubernetes.io/service-name=front-end-svc)" 80
NP=$(jp '{.spec.ports[0].nodePort}' $S); IP=$(jp '{.status.addresses[?(@.type=="InternalIP")].address}' node $(worker_node))
if [ -n "$NP" ] && curl -s -m5 "http://$IP:$NP" | grep -qi 'welcome to nginx'; then pass "answers on NodePort $IP:$NP"; else fail "no answer on the NodePort"; fi
summary
