#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
del_ns exercise-53
kubectl delete priorityclass high-priority user-low user-medium user-critical --ignore-not-found >/dev/null 2>&1
rm -f /root/.cka-lab/q53-web
true
