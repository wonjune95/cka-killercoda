#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
del_ns exercise-43
rm -f /root/CKA/nginx.svc /root/CKA/nginx.pod
true
