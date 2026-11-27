kubectl -n exercise-48 run tmp --rm -it --image=busybox:1.28 --restart=Never -- wget -qO- -T 3 web-svc   # times out
kubectl -n exercise-48 get svc web-svc -o wide                                       # SELECTOR app=webapp
kubectl -n exercise-48 get endpointslices -l kubernetes.io/service-name=web-svc      # no endpoints
kubectl -n exercise-48 get pods --show-labels -o wide                                # pods have app=web
kubectl -n exercise-48 edit svc web-svc
#   selector:   app: webapp  ->  app: web
#   targetPort: 8080         ->  80
kubectl -n exercise-48 get endpointslices -l kubernetes.io/service-name=web-svc      # 2 pods, port 80
kubectl -n exercise-48 run tmp --rm -it --image=busybox:1.28 --restart=Never -- wget -qO- -T 3 web-svc   # nginx page
# 참고: 그다음 점검 - Pod Ready 여부, NetworkPolicy, kube-proxy·CoreDNS Pod 상태.
