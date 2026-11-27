#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
NS=exercise-36; P="pod secret-1401 -n $NS"
banner "Validating Question 36"
check "pod secret-1401 exists" kubectl get $P
eq "container name" "$(jp '{.spec.containers[*].name}' $P)" secret-admin
if jp '{.spec.containers[0].image}' $P | grep -qE '^(docker.io/(library/)?)?busybox(:|$)'; then pass "image busybox"; else fail "image is '$(jp '{.spec.containers[0].image}' $P)'"; fi
if echo "$(jp '{.spec.containers[0].command[*]} {.spec.containers[0].args[*]}' $P)" | grep -q 'sleep 4800'; then pass "runs sleep 4800"; else fail "command is not sleep 4800"; fi
eq "volume secret-volume uses Secret dotfile-secret" "$(jp '{.spec.volumes[?(@.name=="secret-volume")].secret.secretName}' $P)" dotfile-secret
eq "mounted at /etc/secret-volume" "$(jp '{.spec.containers[0].volumeMounts[?(@.name=="secret-volume")].mountPath}' $P)" /etc/secret-volume
eq "mount is read-only" "$(jp '{.spec.containers[0].volumeMounts[?(@.name=="secret-volume")].readOnly}' $P)" true
kubectl wait --for=condition=Ready $P --timeout=60s >/dev/null 2>&1
eq "pod Running" "$(jp '{.status.phase}' $P)" Running
if kubectl exec -n $NS secret-1401 -c secret-admin -- ls -a /etc/secret-volume 2>/dev/null | grep -qFx '.secret-file'; then pass ".secret-file visible in the container"; else fail ".secret-file not found in /etc/secret-volume"; fi
summary
