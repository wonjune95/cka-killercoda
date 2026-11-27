#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
F=/root/argo-helm.yaml
banner "Validating Question 33"
U=$(helm repo list 2>/dev/null | awk '$1=="argo"{print $2}'); U=${U%/}
eq "helm repo argo" "$U" https://argoproj.github.io/argo-helm
check "$F exists" test -s $F
check "template contains the argocd-server Deployment" grep -q 'name: argocd-server$' $F
check "template is chart argo-cd-8.6.4" grep -q 'helm.sh/chart: argo-cd-8.6.4' $F
check "template uses namespace argocd" grep -q 'namespace: argocd' $F
if grep -q 'kind: CustomResourceDefinition' $F 2>/dev/null; then fail "template contains CRDs (set crds.install=false)"; else pass "template has no CRDs"; fi
L=$(helm list -n argocd -o yaml 2>/dev/null)
if echo "$L" | grep -q 'name: argocd$'; then pass "release argocd in namespace argocd"; else fail "no release argocd in namespace argocd"; fi
if echo "$L" | grep -q 'chart: argo-cd-8.6.4'; then pass "release uses chart argo-cd-8.6.4"; else fail "release does not use chart argo-cd-8.6.4"; fi
if echo "$L" | grep -q 'status: deployed'; then pass "release deployed"; else fail "release not deployed"; fi
if helm get values argocd -n argocd -o yaml 2>/dev/null | grep -A3 '^crds:' | grep -q 'install: false'; then pass "release installed with crds.install=false"; else fail "release values do not set crds.install=false"; fi
M=$(jp '{.metadata.annotations.meta\.helm\.sh/release-name}' crd applications.argoproj.io)
if [ -z "$M" ]; then pass "CRDs are not managed by the Helm release"; else fail "CRD applications.argoproj.io is owned by Helm release '$M'"; fi
if kubectl wait --for=condition=Available deploy/argocd-server -n argocd --timeout=180s >/dev/null 2>&1; then pass "argocd-server Available"; else warn "argocd-server not Available yet (needs RAM - check kubectl get pods -n argocd)"; fi
summary
