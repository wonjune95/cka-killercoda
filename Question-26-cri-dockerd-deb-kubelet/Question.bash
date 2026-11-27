# Question 26 - CRI-dockerd from the .deb package + switch the kubelet  (Cluster Architecture | Hard | 30 min)
#
# Do this on the worker node:  ssh node01
# The lab setup downloaded the package to /root/cri-dockerd.deb on node01.
#
# Tasks
# 1. SSH into node01
# 2. Install cri-dockerd from /root/cri-dockerd.deb using dpkg
# 3. Configure the system for cri-dockerd (as in the real exam task):
#    - Load the kernel modules overlay, br_netfilter and nf_conntrack
#    - Set these parameters persistently (in /etc/sysctl.d/) and apply them:
#        net.bridge.bridge-nf-call-iptables = 1
#        net.ipv6.conf.all.forwarding       = 1
#        net.ipv4.ip_forward                = 1
#        net.netfilter.nf_conntrack_max     = 131072
# 4. Enable and start the cri-docker service and socket
#    (the systemd units are called cri-docker.service / cri-docker.socket)
# 5. Verify the cri-dockerd socket /run/cri-dockerd.sock is available
# 6. Configure the kubelet on node01 to use cri-dockerd (unix:///run/cri-dockerd.sock)
# 7. Restart the kubelet and verify node01 is Ready and now reports a docker:// container runtime
#
# ./lab.sh 26 cleanup switches node01 back to containerd.
