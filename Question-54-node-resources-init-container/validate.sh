#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
NS=exercise-54; W=$(worker_node); D="deploy wordpress -n $NS"; T='.spec.template.spec'
banner "Validating Question 54 (node $W)"
milli(){ case "$1" in "") echo 0;; *m) echo "${1%m}";; *.*) awk "BEGIN{printf \"%d\", $1*1000}";; *) echo $(( $1 * 1000 ));; esac; }
mebi(){ case "$1" in "") echo 0;; *Ki) echo $(( ${1%Ki} / 1024 ));; *Mi) echo "${1%Mi}";; *Gi) awk "BEGIN{printf \"%d\", ${1%Gi}*1024}";; *M) echo $(( ${1%M} * 1000000 / 1048576 ));; *G) echo $(( ${1%G} * 1000000000 / 1048576 ));; *) echo $(( $1 / 1048576 ));; esac; }
IC=$(milli "$(jp "{$T.initContainers[0].resources.requests.cpu}" $D)"); IM=$(mebi "$(jp "{$T.initContainers[0].resources.requests.memory}" $D)")
CC=$(milli "$(jp "{$T.containers[0].resources.requests.cpu}" $D)");     CM=$(mebi "$(jp "{$T.containers[0].resources.requests.memory}" $D)")
AC=$(milli "$(jp '{.status.allocatable.cpu}' node $W)"); AM=$(mebi "$(jp '{.status.allocatable.memory}' node $W)")
read -r OC OM < /root/.cka-lab/q54-initial 2>/dev/null; OC=$(milli "$OC"); OM=$(mebi "$OM")
if [ "$CC" -gt 0 ] && [ "$CM" -gt 0 ]; then pass "container has cpu and memory requests (${CC}m / ${CM}Mi)"; else fail "container has no cpu and memory requests"; fi
if [ "$IC" = "$CC" ] && [ "$IM" = "$CM" ] && [ "$CC" -gt 0 ]; then pass "init container and container use exactly the same requests"; else fail "requests differ: init ${IC}m/${IM}Mi, container ${CC}m/${CM}Mi"; fi
if [ "$CC" -lt "$OC" ] && [ "$CM" -lt "$OM" ]; then pass "requests were lowered"; else fail "requests are not lower than before (${OC}m / ${OM}Mi)"; fi
if [ $((CC*3)) -le "$AC" ] && [ $((CM*3)) -le "$AM" ]; then pass "3 Pods fit into the node's allocatable resources (${AC}m / ${AM}Mi)"; else fail "3 x requests exceed the node's allocatable resources (${AC}m / ${AM}Mi)"; fi
eq "replicas" "$(jp '{.spec.replicas}' $D)" 3
kubectl rollout status $D --timeout=120s >/dev/null 2>&1
eq "3 replicas ready" "$(jp '{.status.readyReplicas}' $D)" 3
N=$(kubectl get pods -n $NS -l app=wordpress --field-selector spec.nodeName=$W,status.phase=Running --no-headers 2>/dev/null | wc -l)
eq "all 3 Pods run on $W" "$N" 3
# an even share is roughly allocatable/3 (minus what other pods use and some overhead)
if [ "$CC" -gt 0 ] && { [ $((CC*10)) -lt "$AC" ] || [ $((CM*10)) -lt "$AM" ]; }; then     # below 30% of a third
  warn "requests are far below an even share of the node (allocatable/3 = $((AC/3))m / $((AM/3))Mi) - the task asks to divide the node's resources"; fi
summary
