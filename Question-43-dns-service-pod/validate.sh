#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
NS=exercise-43; S="svc nginx-resolver-service -n $NS"
banner "Validating Question 43"
kubectl wait --for=condition=Ready pod/nginx-resolver -n $NS --timeout=60s >/dev/null 2>&1
eq "pod nginx-resolver Running" "$(jp '{.status.phase}' pod nginx-resolver -n $NS)" Running
eq "Service type/port" "$(jp '{.spec.type}/{.spec.ports[0].port}' $S)" ClusterIP/80
PIP=$(jp '{.status.podIP}' pod nginx-resolver -n $NS); CIP=$(jp '{.spec.clusterIP}' $S)
if jp '{.items[*].endpoints[*].addresses[*]}' endpointslices -n $NS -l kubernetes.io/service-name=nginx-resolver-service | grep -qw "$PIP"; then pass "Service selects the pod"; else fail "Service has no endpoint for the pod ($PIP)"; fi
F=/root/CKA/nginx.svc
if grep -q 'nginx-resolver-service.exercise-43.svc.cluster.local' $F 2>/dev/null && grep -qw "$CIP" $F; then pass "$F has the Service lookup ($CIP)"; else fail "$F is missing or has no answer with $CIP"; fi
F=/root/CKA/nginx.pod
if grep -q "${PIP//./-}.exercise-43.pod.cluster.local" $F 2>/dev/null && grep -qw "$PIP" $F; then pass "$F has the Pod lookup ($PIP)"; else fail "$F is missing or is not the lookup of ${PIP//./-}.exercise-43.pod.cluster.local"; fi
summary
