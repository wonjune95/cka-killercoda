#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
bash "$HERE/cleanup.sh"
mkdir -p /root/CKA
cp /etc/kubernetes/admin.conf /root/CKA/admin.kubeconfig
sed -i -E 's#(server: https://[^:/]+):[0-9]+#\1:4380#' /root/CKA/admin.kubeconfig
echo "Lab ready. Broken file: /root/CKA/admin.kubeconfig"
