#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
bash "$HERE/cleanup.sh"
B=/root/kustomize/base; mkdir -p $B /root/.cka-lab
kubectl create deployment web --image=nginx:1.26 --dry-run=client -o yaml > $B/deployment.yaml
kubectl create service clusterip web --tcp=80:80 --dry-run=client -o yaml > $B/service.yaml
printf 'apiVersion: kustomize.config.k8s.io/v1beta1\nkind: Kustomization\nresources:\n- deployment.yaml\n- service.yaml\n' > $B/kustomization.yaml
(cd $B && md5sum deployment.yaml service.yaml kustomization.yaml) > /root/.cka-lab/q34-base.md5
echo "Lab ready. Base: $B"
