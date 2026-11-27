#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
del_ns exercise-34
rm -rf /root/kustomize /root/.cka-lab/q34-base.md5
true
