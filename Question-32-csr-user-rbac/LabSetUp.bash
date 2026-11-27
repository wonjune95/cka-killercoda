#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
bash "$HERE/cleanup.sh"
kubectl create ns exercise-32 >/dev/null
mkdir -p /root/exercise-32
openssl genrsa -out /root/exercise-32/john.key 2048 >/dev/null 2>&1
openssl req -new -key /root/exercise-32/john.key -subj "/CN=john/O=developers" -out /root/exercise-32/john.csr >/dev/null 2>&1
echo "Lab ready. Key and CSR for user john are in /root/exercise-32/."
