cat <<'EOF2' > /root/exercise-49/ha-commands.sh
# 1. cp1
kubeadm init --control-plane-endpoint "lb.example.com:6443" --upload-certs --pod-network-cidr=192.168.0.0/16
# 2. certificates expire after 2h (Secret kubeadm-certs): upload again + new join command
kubeadm init phase upload-certs --upload-certs        # prints a new certificate key
kubeadm token create --print-join-command
# 3. cp2
kubeadm join lb.example.com:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash> \
  --control-plane --certificate-key <certificate-key>
# 4. etcd members
kubectl -n kube-system exec etcd-cp1 -- etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key member list -w table
EOF2
# 참고: etcd 는 과반(쿼럼)이 필요해서 실제 HA 는 컨트롤 플레인 3대 이상.
#       --control-plane-endpoint 없이 만든 단일 컨트롤 플레인은 나중에 HA 로 바꿀 수 없다.
#       현재 값: kubectl -n kube-system get cm kubeadm-config -o yaml | grep controlPlaneEndpoint
