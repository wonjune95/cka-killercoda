# Question 27 - CNI Installation (Calico via the Tigera Operator)  (Services & Networking | Hard | 30 min)
#
# The lab setup removed the cluster's CNI. As in the real exam task, install and configure a Container
# Network Interface (CNI) of your choice that meets the requirements. Choose ONE of:
#   Flannel v0.26.1  https://github.com/flannel-io/flannel/releases/download/v0.26.1/kube-flannel.yml
#   Calico v3.30.3   https://raw.githubusercontent.com/projectcalico/calico/v3.30.3/manifests/tigera-operator.yaml
#                    https://raw.githubusercontent.com/projectcalico/calico/v3.30.3/manifests/custom-resources.yaml
# The CNI you choose must:
#   - let Pods communicate with each other
#   - support NetworkPolicy enforcement
#   - be installed from manifest files (do not use Helm)
#
# Tasks
# 1. Decide which of the two CNIs meets all requirements (the checker expects that one)
# 2. Find the cluster pod CIDR (kube-controller-manager --cluster-cidr)
# 3. Install the Tigera operator from its manifest and wait for the operator deployment
# 4. Create the Calico Installation custom resource:
#    - Set the IP pool CIDR to match the cluster CIDR
#    - Use VXLAN (or VXLANCrossSubnet) encapsulation
# 5. Wait for the calico-system pods to be Ready and the nodes to become Ready
# 6. Restart pods that were created before the CNI change (e.g. CoreDNS) so they get new IPs
# 7. Verify pods on different nodes can communicate
# 8. Test that NetworkPolicy blocking works
