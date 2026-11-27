#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
NS=exercise-47; P="pod orange -n $NS"
banner "Validating Question 47"
if jp '{.spec.initContainers[0].command[*]} {.spec.initContainers[0].args[*]}' $P | grep -q sleeeep; then fail "init container still runs 'sleeeep'"; else pass "init container command fixed"; fi
eq "main container unchanged" "$(jp '{.spec.containers[0].name}|{.spec.containers[0].image}|{.spec.containers[0].command[*]}' $P)" "orange-container|busybox:1.36|sh -c echo The app is running! && sleep 3600"
kubectl wait --for=condition=Ready $P --timeout=60s >/dev/null 2>&1
eq "init container exited 0" "$(jp '{.status.initContainerStatuses[0].state.terminated.exitCode}' $P)" 0
eq "pod orange Running" "$(jp '{.status.phase}' $P)" Running
summary
