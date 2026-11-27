#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
ensure_helm
bash "$HERE/cleanup.sh"
echo "Installing the Argo CD CRDs (v3.1.8) ..."
for c in application applicationset appproject; do
  kubectl apply --server-side --force-conflicts -f "https://raw.githubusercontent.com/argoproj/argo-cd/v3.1.8/manifests/crds/$c-crd.yaml" >/dev/null || { echo "CRD download failed"; exit 1; }
done
kubectl get crd | grep argoproj.io
echo "Lab ready."
