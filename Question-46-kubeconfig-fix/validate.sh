#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
F=/root/CKA/admin.kubeconfig
banner "Validating Question 46"
check "$F exists" test -f $F
if grep -E 'server: https://[^:/]+:6443' $F >/dev/null 2>&1; then pass "server uses port 6443"; else fail "server is '$(grep server: $F 2>/dev/null | tr -s ' ')'"; fi
check "kubectl --kubeconfig $F get nodes works" kubectl --kubeconfig $F --request-timeout=10s get nodes
summary
