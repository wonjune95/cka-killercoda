#!/bin/bash
# Runs ON the worker node. Saves the kubelet files that select the container runtime (once),
# so lib/cri-reset.sh can put the node back on containerd whichever file the answer changed.
mkdir -p /root/.cka-lab
for f in /var/lib/kubelet/kubeadm-flags.env /var/lib/kubelet/config.yaml /etc/default/kubelet; do
  b=/root/.cka-lab/$(basename "$f").bak
  [ -f "$f" ] && [ ! -f "$b" ] && cp "$f" "$b"
done
true
