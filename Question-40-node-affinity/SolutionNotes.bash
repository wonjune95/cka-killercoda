kubectl label node node01 disktype=ssd
kubectl get nodes -L disktype
cat <<'EOF2' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: affinity-pod
  namespace: exercise-40
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: disktype
            operator: In
            values: ["ssd"]
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 50
        preference:
          matchExpressions:
          - key: zone
            operator: In
            values: ["a"]
  containers:
  - name: nginx
    image: nginx
EOF2
kubectl get pod affinity-pod -n exercise-40 -o wide        # on node01
# 참고: nodeSelectorTerms 항목 여러 개 = OR, 한 항목 안의 matchExpressions 여러 개 = AND.
#       Pending 이면 describe 의 Events 에서 "didn't match Pod's node affinity" 확인.
