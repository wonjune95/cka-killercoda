kubectl get priorityclass --sort-by=.value                 # the highest value that is NOT system-*
MAX=$(kubectl get priorityclass -o jsonpath='{range .items[*]}{.metadata.name} {.value}{"\n"}{end}' | grep -v '^system-' | awk '{print $2}' | sort -n | tail -1)
echo "highest user-defined value: $MAX"
kubectl create priorityclass high-priority --value=$((MAX-1)) --description="high priority for user workloads"
kubectl -n exercise-53 patch deployment busybox-logger -p '{"spec":{"template":{"spec":{"priorityClassName":"high-priority"}}}}'
kubectl -n exercise-53 rollout status deployment busybox-logger
kubectl -n exercise-53 get pods -o custom-columns=NAME:.metadata.name,CLASS:.spec.priorityClassName,PRIORITY:.spec.priority
# 참고: system-cluster-critical(2000000000) / system-node-critical(2000001000) 은 기본 제공 클래스라 제외한다.
#       사용자 정의 PriorityClass 값은 최대 1000000000 까지 가능하다.
