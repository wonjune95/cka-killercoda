#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
NS=exercise-39; W=$(worker_node); P="pod prod-redis -n $NS"
banner "Validating Question 39 (worker $W)"
if jp '{range .spec.taints[*]}{.key}={.value}:{.effect}{"\n"}{end}' node $W | grep -qx 'env_type=production:NoSchedule'; then pass "$W has taint env_type=production:NoSchedule"; else fail "$W lacks taint env_type=production:NoSchedule"; fi
check "pod prod-redis exists" kubectl get $P
if jp '{.spec.containers[0].image}' $P | grep -qE '(^|/)redis:alpine$'; then pass "image redis:alpine"; else fail "image is '$(jp '{.spec.containers[0].image}' $P)'"; fi
T=$(jp '{range .spec.tolerations[?(@.key=="env_type")]}{.operator}|{.value}|{.effect}{"\n"}{end}' $P)
if echo "$T" | grep -qxE '(Equal|)\|production\|(NoSchedule|)|Exists\|\|(NoSchedule|)'; then pass "pod tolerates env_type=production:NoSchedule"; else fail "no matching toleration (got '$T')"; fi
kubectl wait --for=condition=Ready $P --timeout=90s >/dev/null 2>&1
eq "pod Running" "$(jp '{.status.phase}' $P)" Running
summary
