#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
bash "$HERE/cleanup.sh"
kubectl create ns exercise-36 >/dev/null
kubectl -n exercise-36 create secret generic dotfile-secret --from-literal=.secret-file=dotfile-content >/dev/null
echo "Lab ready. Secret exercise-36/dotfile-secret exists."
