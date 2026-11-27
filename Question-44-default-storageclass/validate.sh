#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
S="sc low-latency"; NS=exercise-44
banner "Validating Question 44"
eq "provisioner" "$(jp '{.provisioner}' $S)" rancher.io/local-path
eq "volumeBindingMode" "$(jp '{.volumeBindingMode}' $S)" WaitForFirstConsumer
eq "low-latency is marked default" "$(jp '{.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}' $S)" true
DEF=$(kubectl get sc -o jsonpath='{range .items[*]}{.metadata.name} {.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}{"\n"}{end}' | awk '$2=="true"{print $1}' | tr '\n' ' ')
eq "exactly one default StorageClass" "$DEF" "low-latency "
eq "Deployment app unchanged" "$(jp '{.spec.template}' deploy app -n $NS)" "$(cat /root/.cka-lab/q44-deploy 2>/dev/null)"
eq "PVC app-data unchanged" "$(jp '{.spec}' pvc app-data -n $NS)" "$(cat /root/.cka-lab/q44-pvc 2>/dev/null)"
summary
