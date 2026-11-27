kubectl run nginx-resolver -n exercise-43 --image=nginx
kubectl expose pod nginx-resolver -n exercise-43 --name=nginx-resolver-service --port=80 --target-port=80
kubectl run test-nslookup -n exercise-43 --image=busybox:1.28 --rm -it --restart=Never \
  -- nslookup nginx-resolver-service.exercise-43.svc.cluster.local > /root/CKA/nginx.svc
IP=$(kubectl get pod nginx-resolver -n exercise-43 -o jsonpath='{.status.podIP}'); echo $IP
kubectl run test-nslookup -n exercise-43 --image=busybox:1.28 --rm -it --restart=Never \
  -- nslookup ${IP//./-}.exercise-43.pod.cluster.local > /root/CKA/nginx.pod
cat /root/CKA/nginx.svc /root/CKA/nginx.pod
# 참고: 클러스터 DNS = kube-system 의 CoreDNS Deployment(라벨 k8s-app=kube-dns) + Service kube-dns,
#       설정은 ConfigMap coredns 의 Corefile. 이름 조회가 안 되면 Pod 의 /etc/resolv.conf 도 확인.
