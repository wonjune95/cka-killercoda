# Question 49 - HA control plane with kubeadm (commands only)  (Cluster Architecture | Medium | 10 min)
# 한글: 2노드 환경에서는 HA를 만들 수 없어서, 실행할 명령을 파일로 써서 채점한다. (문서 3번)
#
# You must build a highly available kubeadm cluster with stacked etcd. A load balancer for the
# API server is ready at lb.example.com:6443. This cannot be built on the 2-node playground, so
# write the commands you would run into /root/exercise-49/ha-commands.sh:
#
# 1. On the first control plane node cp1: initialise the cluster with the load balancer as the
#    control plane endpoint, and upload the certificates so other control plane nodes can get them
# 2. If the uploaded certificates have expired (after 2 hours): upload them again and print a new
#    join command
# 3. On the second control plane node cp2: join it as a control plane node
# 4. Check that the etcd members of both nodes are listed
