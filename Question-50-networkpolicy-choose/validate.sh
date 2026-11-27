#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
F=exercise-50-frontend; B=exercise-50-backend
banner "Validating Question 50"
eq "deny-all unchanged" "$(jp '{.spec}' netpol deny-all -n $B)" "$(cat /root/.cka-lab/q50-denyall 2>/dev/null)"
P=$(kubectl get netpol -n $B -o jsonpath='{.items[*].metadata.name}' 2>/dev/null | tr ' ' '\n' | grep -v '^deny-all$' | tr '\n' ' ')
eq "exactly the least-privilege policy is applied" "$P" "netpol-5 "
if kubectl -n $F exec deploy/frontend -- curl -s -m4 http://backend.$B 2>/dev/null | grep -qi 'welcome to nginx'; then pass "frontend -> backend:80 works"; else fail "frontend cannot reach backend"; fi
if kubectl -n $F exec deploy/other -- curl -s -m4 http://backend.$B >/dev/null 2>&1; then fail "another pod in $F can reach backend (policy too wide)"; else pass "other pods in $F are blocked"; fi
summary
