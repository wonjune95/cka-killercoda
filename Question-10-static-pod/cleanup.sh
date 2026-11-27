#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
SP=$(grep staticPodPath /var/lib/kubelet/config.yaml 2>/dev/null | awk '{print $2}'); SP=${SP:-/etc/kubernetes/manifests}
# any manifest file (whatever its name) that defines the pod static-web
grep -lE "^[[:space:]]*name: static-web[[:space:]]*$" "$SP"/* 2>/dev/null | xargs -r rm -f
true
