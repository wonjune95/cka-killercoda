kubectl cluster-info --kubeconfig /root/CKA/admin.kubeconfig     # connection refused / timeout
grep server: /root/CKA/admin.kubeconfig
grep server: /etc/kubernetes/admin.conf                           # compare
ss -ltnp | grep 6443                                              # the API server listens on 6443
vi /root/CKA/admin.kubeconfig                                     # fix the port to 6443
kubectl get nodes --kubeconfig /root/CKA/admin.kubeconfig
# 참고: 문제마다 지정된 컨텍스트가 있으면 먼저 kubectl config use-context <name>.
