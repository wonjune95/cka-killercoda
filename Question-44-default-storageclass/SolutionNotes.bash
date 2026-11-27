kubectl get storageclass                               # local-path (default)
cat <<'EOF2' | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: low-latency
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: rancher.io/local-path
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
EOF2
kubectl patch storageclass local-path -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
kubectl get storageclass                               # only low-latency (default)
# 참고: 기본 SC 가 둘이면 새 PVC 는 가장 최근 것을 쓰지만, 시험에서는 하나만 남기는 게 정답.
