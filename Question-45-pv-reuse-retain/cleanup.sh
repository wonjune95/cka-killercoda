#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
del_ns exercise-45
kubectl delete pv mariadb-pv --ignore-not-found >/dev/null 2>&1
rm -f /root/mariadb-deploy.yaml
for n in $(kubectl get nodes -o jsonpath='{.items[*].metadata.name}' 2>/dev/null); do on_node "$n" "rm -rf /mnt/exercise-45" >/dev/null 2>&1; done
true
