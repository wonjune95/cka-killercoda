#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
NS=exercise-37; A="hpa.v2.autoscaling apache-server -n $NS"
banner "Validating Question 37"
check "HPA apache-server exists" kubectl get $A
eq "targets Deployment apache-server" "$(jp '{.spec.scaleTargetRef.kind}/{.spec.scaleTargetRef.name}' $A)" Deployment/apache-server
eq "minReplicas" "$(jp '{.spec.minReplicas}' $A)" 1
eq "maxReplicas" "$(jp '{.spec.maxReplicas}' $A)" 4
eq "CPU target Utilization 50%" "$(jp '{.spec.metrics[?(@.resource.name=="cpu")].resource.target.type} {.spec.metrics[?(@.resource.name=="cpu")].resource.target.averageUtilization}' $A)" "Utilization 50"
eq "scaleDown stabilizationWindowSeconds" "$(jp '{.spec.behavior.scaleDown.stabilizationWindowSeconds}' $A)" 30
summary
