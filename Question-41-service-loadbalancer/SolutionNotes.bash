kubectl create deployment lb-web -n exercise-41 --image=nginx --replicas=2 --port=80
kubectl expose deployment lb-web -n exercise-41 --name=lb-web-svc --type=LoadBalancer --port=80 --target-port=80
kubectl get svc lb-web-svc -n exercise-41                       # 80:3xxxx/TCP, EXTERNAL-IP <pending>
kubectl get endpointslices -n exercise-41 -l kubernetes.io/service-name=lb-web-svc
NP=$(kubectl get svc lb-web-svc -n exercise-41 -o jsonpath='{.spec.ports[0].nodePort}')
curl -s http://node01:$NP | grep title
# 참고: Endpoints API 는 v1.33 부터 deprecated - EndpointSlice 로 본다 (kubectl get endpoints 도 경고와 함께 동작).
#       Service 유형: ClusterIP(기본, 내부) ⊂ NodePort(30000-32767) ⊂ LoadBalancer.
