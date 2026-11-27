#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
NS=exercise-45; C="pvc mariadb -n $NS"; D="deploy mariadb -n $NS"
banner "Validating Question 45"
eq "PVC mariadb Bound" "$(jp '{.status.phase}' $C)" Bound
eq "PVC bound to the retained PV" "$(jp '{.spec.volumeName}' $C)" mariadb-pv
eq "PVC access mode" "$(jp '{.spec.accessModes[*]}' $C)" ReadWriteOnce
eq "PVC request" "$(jp '{.spec.resources.requests.storage}' $C)" 250Mi
if grep -qE 'claimName:[[:space:]]*mariadb[[:space:]]*$' /root/mariadb-deploy.yaml 2>/dev/null; then pass "/root/mariadb-deploy.yaml uses the PVC"; else fail "/root/mariadb-deploy.yaml does not use claimName: mariadb"; fi
eq "Deployment volume uses PVC mariadb" "$(jp '{.spec.template.spec.volumes[?(@.name=="mariadb-storage")].persistentVolumeClaim.claimName}' $D)" mariadb
kubectl rollout status $D --timeout=180s >/dev/null 2>&1
eq "MariaDB ready" "$(jp '{.status.readyReplicas}' $D)" 1
P=$(jp '{.items[0].metadata.name}' pod -n $NS -l app=mariadb)
R=$(jp '{.status.containerStatuses[0].restartCount}' pod $P -n $NS)
if [ "${R:-0}" -le 1 ]; then pass "MariaDB stable (restarts: ${R:-0})"; else fail "MariaDB restarted $R times"; fi
summary
