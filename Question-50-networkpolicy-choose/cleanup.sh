#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
del_ns exercise-50-frontend exercise-50-backend
rm -rf /root/netpol /root/.cka-lab/q50-denyall
true
