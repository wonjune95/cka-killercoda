#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
W=$(worker_node); R(){ on_node "$W" "$1" 2>/dev/null; }
banner "Validating Question 26 (on $W)"
if R "dpkg -s cri-dockerd" | grep -q 'Status: install ok installed'; then pass "cri-dockerd package installed"; else fail "cri-dockerd package not installed"; fi
if R "lsmod | grep -qw overlay"; then pass "overlay module loaded"; else fail "overlay module not loaded"; fi
if R "lsmod | grep -qw br_netfilter"; then pass "br_netfilter module loaded"; else fail "br_netfilter module not loaded"; fi
for kv in net.bridge.bridge-nf-call-iptables=1 net.ipv6.conf.all.forwarding=1 net.ipv4.ip_forward=1 net.netfilter.nf_conntrack_max=131072; do
  k=${kv%=*}; v=${kv#*=}
  eq "$k = $v" "$(R "sysctl -n $k")" "$v"
  # persisted: a file in /etc/sysctl.d/ (or sysctl.conf) sets exactly this value
  if R "grep -rhsE '^[[:space:]]*$k[[:space:]]*=' /etc/sysctl.d/ /etc/sysctl.conf | tail -1 | grep -qE '=[[:space:]]*$v[[:space:]]*\$'"; then pass "$k persisted"; else fail "$k = $v not persisted in /etc/sysctl.d/"; fi
done
eq "cri-docker.service active" "$(R 'systemctl is-active cri-docker.service')" active
eq "cri-docker.service enabled" "$(R 'systemctl is-enabled cri-docker.service')" enabled
if R "test -S /run/cri-dockerd.sock"; then pass "/run/cri-dockerd.sock exists"; else fail "/run/cri-dockerd.sock missing"; fi
if R "cat /var/lib/kubelet/kubeadm-flags.env /var/lib/kubelet/config.yaml /etc/default/kubelet" | grep -q 'cri-dockerd.sock'; then pass "kubelet configured with the cri-dockerd endpoint"; else fail "kubelet is not pointed at cri-dockerd.sock"; fi
eq "node $W Ready" "$(jp '{.status.conditions[?(@.type=="Ready")].status}' node $W)" True
RT=$(jp '{.status.nodeInfo.containerRuntimeVersion}' node $W)
if echo "$RT" | grep -q '^docker://'; then pass "node runtime is $RT"; else fail "node runtime is '$RT' (expected docker://...)"; fi
summary
