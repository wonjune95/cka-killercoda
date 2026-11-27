kubectl -n kube-system get deploy,cm | grep coredns
kubectl -n kube-system get cm coredns -o yaml > /root/mock3/16/coredns_backup.yaml
kubectl -n kube-system edit cm coredns
#   kubernetes custom-domain cluster.local in-addr.arpa ip6.arpa {     <- add custom-domain on this line
kubectl -n kube-system rollout restart deploy coredns
kubectl -n kube-system get pod -l k8s-app=kube-dns          # Running = no syntax error
kubectl run bb --image=busybox:1 -- sh -c 'sleep 1d'
kubectl exec bb -- nslookup kubernetes.default.svc.custom-domain
kubectl exec bb -- nslookup kubernetes.default.svc.cluster.local
# restore if needed:
#   sed -E '/^  (resourceVersion|uid|creationTimestamp):/d' /root/mock3/16/coredns_backup.yaml | kubectl apply -f -
#   kubectl -n kube-system rollout restart deploy coredns
#   (applying the file as it is fails with "the object has been modified": it still holds the old resourceVersion)
