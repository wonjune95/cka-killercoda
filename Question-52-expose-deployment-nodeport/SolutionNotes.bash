kubectl -n exercise-52 edit deployment front-end
# add under the nginx container:
#        ports:
#        - containerPort: 80
#          protocol: TCP
# the same change as ONE command instead of kubectl edit (JSON patch):
kubectl -n exercise-52 patch deployment front-end --type=json -p='[{"op":"add","path":"/spec/template/spec/containers/0/ports","value":[{"containerPort":80,"protocol":"TCP"}]}]'
kubectl -n exercise-52 rollout status deployment front-end
kubectl -n exercise-52 expose deployment front-end --name=front-end-svc --port=80 --target-port=80 --protocol=TCP --type=NodePort
kubectl -n exercise-52 get svc front-end-svc                                    # 80:3xxxx/TCP
kubectl -n exercise-52 get endpointslices -l kubernetes.io/service-name=front-end-svc
NP=$(kubectl -n exercise-52 get svc front-end-svc -o jsonpath='{.spec.ports[0].nodePort}')
curl -s http://node01:$NP | grep title
# 참고: 특정 nodePort 값을 요구하면 expose 에는 옵션이 없으므로 만든 뒤 고친다:
#       kubectl -n exercise-52 patch svc front-end-svc -p '{"spec":{"ports":[{"port":80,"nodePort":30080}]}}'
