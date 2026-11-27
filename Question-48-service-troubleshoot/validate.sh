#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
NS=exercise-48
banner "Validating Question 48"
eq "Deployment web unchanged" "$(jp '{.spec.template}' deploy web -n $NS)" "$(cat /root/.cka-lab/q48-deploy 2>/dev/null)"
N=$(jp '{range .items[*].endpoints[*]}{.addresses[0]}{"\n"}{end}' endpointslices -n $NS -l kubernetes.io/service-name=web-svc | grep -c .)
eq "web-svc has 2 endpoints" "$N" 2
eq "endpoint port 80" "$(jp '{.items[0].ports[0].port}' endpointslices -n $NS -l kubernetes.io/service-name=web-svc)" 80
kubectl -n $NS delete pod q48-client --ignore-not-found --now >/dev/null 2>&1
kubectl -n $NS run q48-client --image=busybox:1.36 --restart=Never -- sleep 120 >/dev/null 2>&1
kubectl -n $NS wait --for=condition=Ready pod/q48-client --timeout=60s >/dev/null 2>&1
if kubectl -n $NS exec q48-client -- wget -qO- -T 3 web-svc 2>/dev/null | grep -qi 'welcome to nginx'; then pass "web-svc answers inside the cluster"; else fail "web-svc does not answer"; fi
kubectl -n $NS delete pod q48-client --now >/dev/null 2>&1
summary
