#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
M=/etc/kubernetes/manifests/kube-apiserver.yaml; B=/root/.cka-lab/kube-apiserver.yaml.bak
if [ -f $B ]; then
  # Restore only while the manifest differs from the backup in nothing but --etcd-servers
  # (i.e. this lab's break is still there). A manifest changed since (an upgrade, another lab) is kept.
  if ! cmp -s $B $M && diff -q <(grep -v -- '--etcd-servers=' $B) <(grep -v -- '--etcd-servers=' $M) >/dev/null; then
    cp $B $M
    echo "Restored kube-apiserver manifest - waiting for the API server ..."
    for i in $(seq 1 60); do kubectl get nodes >/dev/null 2>&1 && break; sleep 3; done
  fi
  rm -f $B
fi
true
