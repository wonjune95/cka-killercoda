#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
NS=exercise-53; D="deploy busybox-logger -n $NS"
banner "Validating Question 53"
# highest user-defined value = every class except system-* and the new high-priority itself
MAX=$(kubectl get priorityclass -o jsonpath='{range .items[*]}{.metadata.name} {.value}{"\n"}{end}' 2>/dev/null | grep -vE '^(system-|high-priority )' | awk '{print $2}' | sort -n | tail -1)
V=$(jp '{.value}' priorityclass high-priority)
check "PriorityClass high-priority exists" kubectl get priorityclass high-priority
eq "high-priority value = highest user-defined value ($MAX) - 1" "$V" "$((MAX-1))"
eq "busybox-logger uses priorityClassName high-priority" "$(jp '{.spec.template.spec.priorityClassName}' $D)" high-priority
kubectl rollout status $D --timeout=120s >/dev/null 2>&1
eq "busybox-logger rolled out (1 ready, 1 updated)" "$(jp '{.status.readyReplicas}/{.status.updatedReplicas}' $D)" 1/1
PR=$(kubectl get pods -n $NS -l app=busybox-logger -o jsonpath='{range .items[*]}{.metadata.deletionTimestamp}|{.spec.priority}{"\n"}{end}' 2>/dev/null | grep '^|' | head -1 | cut -d'|' -f2)
eq "running busybox-logger pod has priority $V" "$PR" "$V"
eq "the other Deployment (web) is unchanged" "$(jp '{.spec.template}' deploy web -n $NS)" "$(cat /root/.cka-lab/q53-web 2>/dev/null)"
summary
