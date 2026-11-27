helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm search repo argo/argo-cd --versions | grep 8.6.4
helm show values argo/argo-cd --version 8.6.4 | grep -A3 '^crds:'     # crds.install: true by default
helm template argocd argo/argo-cd --version 8.6.4 --namespace argocd \
  --set crds.install=false > /root/argo-helm.yaml
grep -c 'kind: CustomResourceDefinition' /root/argo-helm.yaml          # 0
helm install argocd argo/argo-cd --version 8.6.4 --namespace argocd --create-namespace \
  --set crds.install=false
helm list -n argocd                                                    # argo-cd-8.6.4 deployed
kubectl get pods -n argocd
# 참고: 이미 설치된 CRD를 차트가 다시 만들려고 하면 소유권 충돌이 난다. 그래서 crds.install=false.
