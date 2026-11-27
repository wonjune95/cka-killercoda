#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
if kubectl get crd applications.argoproj.io >/dev/null 2>&1; then
  kubectl patch application my-app -n argocd --type=merge -p '{"metadata":{"finalizers":null}}' >/dev/null 2>&1
  kubectl delete application my-app -n argocd --ignore-not-found --wait=false >/dev/null 2>&1
fi
del_ns argocd
# cluster-scoped objects of an Argo CD install (manifest or chart): left behind they block the next install
# ("ClusterRole argocd-application-controller exists and cannot be imported into the current release")
kubectl delete clusterrolebinding,clusterrole -l app.kubernetes.io/part-of=argocd --ignore-not-found >/dev/null 2>&1
kubectl delete clusterrolebinding,clusterrole argocd-application-controller argocd-applicationset-controller argocd-server --ignore-not-found >/dev/null 2>&1
kubectl delete crd applications.argoproj.io applicationsets.argoproj.io appprojects.argoproj.io --ignore-not-found >/dev/null 2>&1
kubectl delete deploy guestbook-ui --ignore-not-found >/dev/null 2>&1
kubectl delete svc guestbook-ui --ignore-not-found >/dev/null 2>&1
rm -f /root/argocd-app.yaml
true
