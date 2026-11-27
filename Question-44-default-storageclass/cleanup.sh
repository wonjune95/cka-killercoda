#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
del_ns exercise-44
kubectl delete sc low-latency --ignore-not-found >/dev/null 2>&1
F=/root/.cka-lab/q44-defaults
if [ -f $F ]; then                 # put the default marker back where it was before the lab
  for sc in $(kubectl get sc -o jsonpath='{.items[*].metadata.name}'); do
    if grep -qx "$sc" $F; then kubectl annotate sc "$sc" storageclass.kubernetes.io/is-default-class=true --overwrite >/dev/null
    else kubectl annotate sc "$sc" storageclass.kubernetes.io/is-default-class- >/dev/null 2>&1; fi
  done
  rm -f $F
fi
rm -f /root/.cka-lab/q44-deploy /root/.cka-lab/q44-pvc
true
