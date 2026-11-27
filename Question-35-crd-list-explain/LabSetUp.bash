#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
bash "$HERE/cleanup.sh"
CMV=v1.19.1
if ! kubectl get deploy cert-manager -n cert-manager >/dev/null 2>&1; then
  echo "Installing cert-manager $CMV ..."
  kubectl apply -f "https://github.com/cert-manager/cert-manager/releases/download/$CMV/cert-manager.yaml" >/dev/null || { echo "install failed"; exit 1; }
  mkdir -p /root/.cka-lab; echo $CMV > /root/.cka-lab/q35-cert-manager
fi
kubectl wait --for=condition=Available deploy --all -n cert-manager --timeout=300s >/dev/null
echo "Lab ready. cert-manager runs in namespace cert-manager."
