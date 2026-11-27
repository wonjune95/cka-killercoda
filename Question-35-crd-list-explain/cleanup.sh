#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
rm -f /root/resources.yaml /root/subject.yaml
if [ -f /root/.cka-lab/q35-cert-manager ]; then     # remove cert-manager only if this lab installed it
  kubectl delete -f "https://github.com/cert-manager/cert-manager/releases/download/$(cat /root/.cka-lab/q35-cert-manager)/cert-manager.yaml" --ignore-not-found >/dev/null 2>&1
  rm -f /root/.cka-lab/q35-cert-manager
fi
true
