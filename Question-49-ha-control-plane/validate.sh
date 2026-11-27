#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
F=/root/exercise-49/ha-commands.sh
banner "Validating Question 49"
check "$F exists" test -s $F
# join continued lines (\) so one command is one line
C=$(sed -e ':a' -e '/\\$/N; s/\\\n//; ta' $F 2>/dev/null | grep -v '^[[:space:]]*#')
has(){ echo "$C" | grep -E -e "$2" | grep -qE -e "$3" && pass "$1" || fail "$1"; }
has "kubeadm init with --control-plane-endpoint lb.example.com:6443" 'kubeadm init ' 'control-plane-endpoint[= ]"?lb\.example\.com:6443'
has "kubeadm init uploads the certificates (--upload-certs)" 'kubeadm init .*control-plane-endpoint' '--upload-certs'
has "re-upload: kubeadm init phase upload-certs --upload-certs" 'kubeadm init phase upload-certs' '--upload-certs'
has "new join command: kubeadm token create --print-join-command" 'kubeadm token create' '--print-join-command'
has "cp2 joins with --control-plane" 'kubeadm join ' '--control-plane( |$)'
has "cp2 joins with --certificate-key" 'kubeadm join ' '--certificate-key'
has "etcd member list" 'etcdctl' 'member list'
summary
