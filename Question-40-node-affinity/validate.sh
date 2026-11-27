#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
NS=exercise-40; W=$(worker_node); P="pod affinity-pod -n $NS"
banner "Validating Question 40 (worker $W)"
eq "$W label disktype" "$(jp '{.metadata.labels.disktype}' node $W)" ssd
check "pod affinity-pod exists" kubectl get $P
R=$(jp '{.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution}' $P | tr -d ' ')
if echo "$R" | grep -q '"key":"disktype"' && echo "$R" | grep -q '"operator":"In"' && echo "$R" | grep -q '"ssd"'; then pass "required affinity disktype In [ssd]"; else fail "required node affinity for disktype=ssd missing"; fi
F=$(jp '{.spec.affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution}' $P | tr -d ' ')
if echo "$F" | grep -q '"weight":50' && echo "$F" | grep -q '"key":"zone"' && echo "$F" | grep -q '"a"'; then pass "preferred affinity zone In [a], weight 50"; else fail "preferred node affinity (zone=a, weight 50) missing"; fi
kubectl wait --for=condition=Ready $P --timeout=90s >/dev/null 2>&1
eq "pod Running" "$(jp '{.status.phase}' $P)" Running
eq "pod scheduled on the disktype=ssd node" "$(jp '{.spec.nodeName}' $P)" "$W"
summary
