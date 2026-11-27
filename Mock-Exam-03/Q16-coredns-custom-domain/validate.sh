#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../../lib/common.sh"
banner "Validating Mock Exam 03 - Question 16"
B=/root/mock3/16/coredns_backup.yaml
if grep -q 'kind: ConfigMap' $B 2>/dev/null && grep -q 'name: coredns' $B; then pass "backup is the coredns ConfigMap YAML"; else fail "backup missing or not the coredns ConfigMap"; fi
if grep -Eq 'kubernetes +cluster.local' $B 2>/dev/null; then pass "backup holds the original Corefile"; else fail "backup does not hold the original Corefile"; fi
# a "get -o yaml" backup holds resourceVersion/uid, which make a later apply fail with a conflict;
# restoring means applying it without those fields, so check exactly that
if sed -E '/^  (resourceVersion|uid|creationTimestamp):/d' $B 2>/dev/null | kubectl apply --dry-run=server -f - >/dev/null 2>&1; then pass "backup can be applied (server dry-run)"; else fail "backup can not be applied (server dry-run)"; fi
if kubectl -n kube-system get cm coredns -o jsonpath='{.data.Corefile}' | grep -Eq '^[[:space:]]*kubernetes .*custom-domain'; then pass "Corefile kubernetes plugin serves custom-domain"; else fail "custom-domain not added to the kubernetes plugin"; fi
check "CoreDNS rollout healthy" kubectl -n kube-system rollout status deploy/coredns --timeout=90s
kubectl delete pod mock3-dns-test --ignore-not-found --force --grace-period=0 >/dev/null 2>&1
kubectl run mock3-dns-test --image=busybox:1 --restart=Never -- sleep 300 >/dev/null 2>&1
kubectl wait --for=condition=Ready pod/mock3-dns-test --timeout=90s >/dev/null 2>&1
for d in cluster.local custom-domain; do
  if kubectl exec mock3-dns-test -- nslookup kubernetes.default.svc.$d 2>/dev/null | grep -A1 "Name:.*kubernetes.default.svc.$d" | grep -q 'Address'; then pass "kubernetes.default.svc.$d resolves"; else fail "kubernetes.default.svc.$d does not resolve"; fi
done
kubectl delete pod mock3-dns-test --force --grace-period=0 >/dev/null 2>&1
summary
