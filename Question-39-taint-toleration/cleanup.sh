#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
del_ns exercise-39
for n in $(kubectl get nodes -o jsonpath="{.items[*].metadata.name}"); do kubectl taint node "$n" env_type- >/dev/null 2>&1; done
true
