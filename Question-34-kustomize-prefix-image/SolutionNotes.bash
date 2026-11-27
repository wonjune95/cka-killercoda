mkdir -p /root/kustomize/overlays/prod
cat <<'EOF2' > /root/kustomize/overlays/prod/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../../base
namespace: exercise-34
namePrefix: prod-
replicas:
- name: web          # the name BEFORE the prefix
  count: 3
images:
- name: nginx
  newTag: "1.27"
EOF2
kubectl kustomize /root/kustomize/overlays/prod        # preview
kubectl create namespace exercise-34                   # "namespace:" does not create the namespace
kubectl apply -k /root/kustomize/overlays/prod
kubectl -n exercise-34 get deploy,svc,pods
# 참고: 위 항목으로 못 바꾸는 필드는 patches 로 (target: kind/name + JSON patch 또는 strategic merge).
