#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
bash "$HERE/cleanup.sh"
kubectl create ns exercise-43 >/dev/null
mkdir -p /root/CKA
echo "Lab ready. Work in namespace exercise-43; save the files in /root/CKA/."
