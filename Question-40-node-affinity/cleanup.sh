#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
del_ns exercise-40
kubectl label nodes --all disktype- >/dev/null 2>&1
true
