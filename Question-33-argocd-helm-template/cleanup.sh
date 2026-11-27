#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
command -v helm >/dev/null && helm uninstall argocd -n argocd >/dev/null 2>&1
del_ns argocd
kubectl delete crd applications.argoproj.io applicationsets.argoproj.io appprojects.argoproj.io --ignore-not-found >/dev/null 2>&1
command -v helm >/dev/null && helm repo remove argo >/dev/null 2>&1
rm -f /root/argo-helm.yaml
true
