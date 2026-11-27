#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
del_ns exercise-54
rm -f /root/.cka-lab/q54-initial
true
