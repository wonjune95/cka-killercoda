#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
banner "Validating Question 20"
L(){ jp "{.metadata.labels.pod-security\.kubernetes\.io/$2}" ns "$1"; }
eq "exercise-20 enforce=restricted" "$(L exercise-20 enforce)" restricted
eq "exercise-20-baseline enforce=baseline" "$(L exercise-20-baseline enforce)" baseline
eq "exercise-20-audit audit=restricted" "$(L exercise-20-audit audit)" restricted
eq "exercise-20-audit warn=restricted" "$(L exercise-20-audit warn)" restricted
E=$(L exercise-20-audit enforce); if [ -z "$E" ] || [ "$E" = privileged ]; then pass "exercise-20-audit is not enforcing"; else fail "exercise-20-audit enforces '$E' - it should only audit/warn"; fi
if kubectl run pss-test --image=nginx:1.28 --privileged -n exercise-20 --dry-run=server >/dev/null 2>&1; then fail "privileged pod would be admitted in exercise-20"; else pass "privileged pod rejected in exercise-20"; fi
if kubectl run pss-test --image=nginx:1.28 --privileged -n exercise-20-baseline --dry-run=server >/dev/null 2>&1; then fail "privileged pod would be admitted in exercise-20-baseline"; else pass "privileged pod rejected in exercise-20-baseline"; fi
eq "safe-pod Running in exercise-20-baseline" "$(jp '{.status.phase}' pod safe-pod -n exercise-20-baseline)" Running
# runAsNonRoot / runAsUser may be set at pod level, container level, or both
SC(){ echo "$(jp "{.spec.securityContext.$1}" pod safe-pod -n exercise-20-baseline) $(jp "{.spec.containers[0].securityContext.$1}" pod safe-pod -n exercise-20-baseline)"; }
V=$(SC runAsNonRoot); if echo "$V" | grep -qw true && ! echo "$V" | grep -qw false; then pass "safe-pod runAsNonRoot true"; else fail "safe-pod runAsNonRoot is '$V' (expected true)"; fi
C=$(jp '{.spec.containers[0].securityContext.runAsUser}' pod safe-pod -n exercise-20-baseline); [ -z "$C" ] && C=$(jp '{.spec.securityContext.runAsUser}' pod safe-pod -n exercise-20-baseline)
eq "safe-pod runAsUser 1000" "$C" 1000
eq "audit-pod Running in exercise-20-audit" "$(jp '{.status.phase}' pod audit-pod -n exercise-20-audit)" Running
eq "audit-pod is privileged" "$(jp '{.spec.containers[0].securityContext.privileged}' pod audit-pod -n exercise-20-audit)" true
summary
