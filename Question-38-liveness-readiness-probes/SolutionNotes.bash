kubectl create deployment probe-web -n exercise-38 --image=nginx --replicas=2 --port=80 --dry-run=client -o yaml > probe-web.yaml
# add the probes under the container. The finished container section:
#      containers:
#      - image: nginx
#        name: nginx
#        ports:
#        - containerPort: 80
#        readinessProbe:
#          httpGet: {path: /, port: 80}
#          initialDelaySeconds: 5
#          periodSeconds: 5
#        livenessProbe:
#          httpGet: {path: /, port: 80}
#          initialDelaySeconds: 10
#          periodSeconds: 10
#          failureThreshold: 3
kubectl apply -f probe-web.yaml
kubectl -n exercise-38 rollout status deploy probe-web
kubectl -n exercise-38 describe deploy probe-web | grep -E 'Liveness|Readiness'
kubectl -n exercise-38 delete pod $(kubectl -n exercise-38 get pod -l app=probe-web -o jsonpath='{.items[0].metadata.name}')
kubectl -n exercise-38 get pods -l app=probe-web          # a new pod replaces it
# 참고: 시작이 느린 앱은 startupProbe 로 liveness 를 늦춘다.
