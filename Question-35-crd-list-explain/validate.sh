#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
R=/root/resources.yaml; S=/root/subject.yaml
banner "Validating Question 35"
check "$R exists" test -s $R
EXP=$(kubectl get crd -o name 2>/dev/null | sed 's#.*/##' | grep 'cert-manager.io$')
N=$(echo "$EXP" | grep -c .); M=0
for c in $EXP; do grep -qw "$c" $R 2>/dev/null && M=$((M+1)); done
eq "all $N cert-manager CRDs listed" "$M" "$N"
if grep -qE '^(apiVersion:|kind:|items:|\{|- )|"name"' $R 2>/dev/null; then fail "$R looks like -o yaml/json output - use the default format"
else
  # default table: the CRD name first, the CREATED AT timestamp last (kubectl 1.37 added SCOPE and VERSIONS in between)
  T=$(grep -cE '^[a-z0-9.-]+[[:space:]].*[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9:]+Z[[:space:]]*$' $R 2>/dev/null)
  if [ "${T:-0}" -ge "$N" ]; then pass "$R is in the default table format"; else fail "$R is not the default 'kubectl get crd' table"; fi
fi
check "$S exists" test -s $S
if grep -qi 'subject' $S 2>/dev/null && grep -qi 'organizations' $S; then pass "$S documents Certificate spec.subject"; else fail "$S is not the explain output of certificate.spec.subject"; fi
summary
