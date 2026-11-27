cat <<'EOF2' | kubectl apply -f -
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: apache-server
  namespace: exercise-37
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: apache-server
  minReplicas: 1
  maxReplicas: 4
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 30
EOF2
kubectl -n exercise-37 get hpa apache-server
kubectl -n exercise-37 get hpa apache-server -o yaml | grep -A2 scaleDown
# alternative: kubectl -n exercise-37 autoscale deployment apache-server --name=apache-server --cpu-percent=50 --min=1 --max=4
#              then kubectl -n exercise-37 edit hpa apache-server and add the behavior block
# 참고: 최신 kubectl 은 --cpu-percent 대신 --cpu=50% 를 쓸 수 있다 (kubectl autoscale -h 로 확인).
