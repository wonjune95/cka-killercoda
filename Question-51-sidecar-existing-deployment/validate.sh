#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
NS=exercise-51; D="deploy synergy-deployment -n $NS"; T='.spec.template.spec'
banner "Validating Question 51"
# the sidecar may be a normal container or a native sidecar (initContainers + restartPolicy: Always)
SC(){ jp "{$T.containers[?(@.name==\"sidecar\")]$1}{$T.initContainers[?(@.name==\"sidecar\")]$1}" $D; }
# mounts <container name> -> one "mountPath=volumeName" line per volume mount
mounts(){ jp "{range $T.containers[?(@.name==\"$1\")]}{range .volumeMounts[*]}{.mountPath}={.name}{\"\\n\"}{end}{end}{range $T.initContainers[?(@.name==\"$1\")]}{range .volumeMounts[*]}{.mountPath}={.name}{\"\\n\"}{end}{end}" $D; }
eq "container sidecar uses image busybox:stable" "$(SC .image)" busybox:stable
if echo "$(SC '.command[*]') $(SC '.args[*]')" | grep -qF 'tail -n+1 -f /var/log/synergy-deployment.log'; then pass "sidecar runs tail -n+1 -f /var/log/synergy-deployment.log"; else fail "sidecar command is '$(SC '.command[*]') $(SC '.args[*]')'"; fi
SV=$(mounts sidecar | sed -n 's#^/var/log/\{0,1\}=##p' | head -1); MV=$(mounts synergy | sed -n 's#^/var/log/\{0,1\}=##p' | head -1)
nonempty "sidecar mounts a volume at /var/log" "$SV"
if [ -n "$SV" ] && [ "$SV" = "$MV" ]; then pass "the existing container mounts the same volume ($SV) at /var/log"; else fail "the existing container does not mount the sidecar's volume at /var/log (sidecar: '$SV', existing: '$MV')"; fi
eq "existing container otherwise unchanged (image, command)" "$(jp "{$T.containers[?(@.name==\"synergy\")].image}|{$T.containers[?(@.name==\"synergy\")].command}" $D)" "$(cat /root/.cka-lab/q51-main 2>/dev/null)"
kubectl rollout status $D --timeout=120s >/dev/null 2>&1
eq "Deployment rolled out (1 ready)" "$(jp '{.status.readyReplicas}/{.status.updatedReplicas}' $D)" 1/1
if kubectl -n $NS logs deploy/synergy-deployment -c sidecar --tail=20 2>/dev/null | grep -q 'synergy legacy app is working'; then pass "kubectl logs -c sidecar shows the app log"; else fail "kubectl logs -c sidecar does not show the app log"; fi
summary
