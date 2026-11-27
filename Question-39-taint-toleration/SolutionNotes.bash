kubectl taint nodes node01 env_type=production:NoSchedule
kubectl describe node node01 | grep -i taint
kubectl run prod-redis -n exercise-39 --image=redis:alpine --dry-run=client -o yaml > prod-redis.yaml
# add under spec:
#   tolerations:
#   - key: "env_type"
#     operator: "Equal"
#     value: "production"
#     effect: "NoSchedule"
kubectl apply -f prod-redis.yaml
kubectl get pod prod-redis -n exercise-39 -o wide
# 참고: effect 종류 - NoSchedule(새 Pod 금지), PreferNoSchedule(가급적 피함), NoExecute(실행 중인 Pod도 축출).
#       특정 노드에 꼭 보내려면 nodeSelector/nodeAffinity 를 같이 쓴다. taint 제거: kubectl taint nodes node01 env_type-
