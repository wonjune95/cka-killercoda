#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
NS=exercise-32; C="csr john-developer"
banner "Validating Question 32"
check "CSR john-developer exists" kubectl get $C
eq "signerName" "$(jp '{.spec.signerName}' $C)" kubernetes.io/kube-apiserver-client
if jp '{.spec.usages[*]}' $C | grep -qw 'client auth'; then pass "usage client auth"; else fail "usages are '$(jp '{.spec.usages[*]}' $C)'"; fi
if jp '{.spec.request}' $C | base64 -d 2>/dev/null | openssl req -noout -subject 2>/dev/null | grep -qE 'CN *= *john'; then pass "CSR is the one for CN=john"; else fail "CSR request is not john's CSR"; fi
eq "CSR approved" "$(jp '{.status.conditions[?(@.type=="Approved")].status}' $C)" True
nonempty "certificate issued" "$(jp '{.status.certificate}' $C)"
eq "RoleBinding uses Role developer" "$(jp '{.roleRef.kind}/{.roleRef.name}' rolebinding developer-role-binding -n $NS)" Role/developer
eq "RoleBinding subject is user john" "$(jp '{.subjects[0].kind}/{.subjects[0].name}' rolebinding developer-role-binding -n $NS)" User/john
for v in create list get update delete; do
  eq "john can $v pods in $NS" "$(kubectl auth can-i $v pods -n $NS --as=john 2>/dev/null)" yes
done
eq "john can NOT watch pods (only the 5 verbs)" "$(kubectl auth can-i watch pods -n $NS --as=john 2>/dev/null)" no
eq "john can NOT create pods in default" "$(kubectl auth can-i create pods -n default --as=john 2>/dev/null)" no
summary
