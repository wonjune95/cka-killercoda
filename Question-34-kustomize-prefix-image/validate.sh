#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
NS=exercise-34; O=/root/kustomize/overlays/prod
banner "Validating Question 34"
if (cd /root/kustomize/base 2>/dev/null && md5sum -c --quiet /root/.cka-lab/q34-base.md5 >/dev/null 2>&1); then pass "base unchanged"; else fail "the base was changed"; fi
check "overlay $O/kustomization.yaml exists" test -f $O/kustomization.yaml
R=$(kubectl kustomize $O 2>/dev/null)
nonempty "overlay renders" "$R"
for s in 'name: prod-web' "namespace: $NS" 'image: nginx:1.27' 'replicas: 3'; do
  if echo "$R" | grep -q "$s"; then pass "rendered output has '$s'"; else fail "rendered output lacks '$s'"; fi
done
eq "Deployment prod-web replicas" "$(jp '{.spec.replicas}' deploy prod-web -n $NS)" 3
eq "Deployment prod-web image" "$(jp '{.spec.template.spec.containers[0].image}' deploy prod-web -n $NS)" nginx:1.27
kubectl rollout status deploy/prod-web -n $NS --timeout=90s >/dev/null 2>&1
eq "3 pods ready" "$(jp '{.status.readyReplicas}' deploy prod-web -n $NS)" 3
check "Service prod-web exists in $NS" kubectl get svc prod-web -n $NS
summary
