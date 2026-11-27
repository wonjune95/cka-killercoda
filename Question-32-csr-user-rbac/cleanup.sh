#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
kubectl delete csr john-developer --ignore-not-found >/dev/null 2>&1
del_ns exercise-32
rm -rf /root/exercise-32
true
