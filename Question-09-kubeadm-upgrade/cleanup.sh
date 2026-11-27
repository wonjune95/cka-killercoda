#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
# An upgrade cannot be rolled back. Cleanup only makes sure both nodes are schedulable again.
for n in $(kubectl get nodes -o name 2>/dev/null); do kubectl uncordon "${n#node/}" >/dev/null 2>&1; done
# remove the apt source the setup added (installed packages stay)
for n in $(kubectl get nodes -o jsonpath='{.items[*].metadata.name}' 2>/dev/null); do
  on_node "$n" "rm -f /etc/apt/sources.list.d/kubernetes-cka-lab.list /etc/apt/keyrings/kubernetes-cka-lab.gpg" >/dev/null 2>&1
done
echo "Note: a kubeadm upgrade cannot be undone - start a fresh Killercoda session to practise it again."
