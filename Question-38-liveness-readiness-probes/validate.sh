#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
NS=exercise-38; D="deploy probe-web -n $NS"; C='{.spec.template.spec.containers[0]'
banner "Validating Question 38"
check "Deployment probe-web exists" kubectl get $D
eq "replicas" "$(jp '{.spec.replicas}' $D)" 2
if jp "$C.image}" $D | grep -qE '(^|/)nginx(:|$)'; then pass "image nginx"; else fail "image is '$(jp "$C.image}" $D)'"; fi
eq "readinessProbe httpGet path/port" "$(jp "$C.readinessProbe.httpGet.path}:$C.readinessProbe.httpGet.port}" $D)" /:80
eq "readinessProbe initialDelay/period" "$(jp "$C.readinessProbe.initialDelaySeconds}/$C.readinessProbe.periodSeconds}" $D)" 5/5
eq "livenessProbe httpGet path/port" "$(jp "$C.livenessProbe.httpGet.path}:$C.livenessProbe.httpGet.port}" $D)" /:80
eq "livenessProbe initialDelay/period/failureThreshold" "$(jp "$C.livenessProbe.initialDelaySeconds}/$C.livenessProbe.periodSeconds}/$C.livenessProbe.failureThreshold}" $D)" 10/10/3
kubectl rollout status $D --timeout=90s >/dev/null 2>&1
eq "2 pods ready" "$(jp '{.status.readyReplicas}' $D)" 2
summary
