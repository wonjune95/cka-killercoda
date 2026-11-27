kubectl -n exercise-51 get deployment synergy-deployment -o yaml > synergy-backup.yaml     # backup first
kubectl -n exercise-51 edit deployment synergy-deployment
# add a shared emptyDir volume, mount it at /var/log in the existing container, and add the sidecar:
#     spec:
#       containers:
#       - name: synergy                      # existing container: only volumeMounts is new
#         ...
#         volumeMounts:
#         - name: logs
#           mountPath: /var/log
#       - name: sidecar
#         image: busybox:stable
#         command: ["/bin/sh", "-c", "tail -n+1 -f /var/log/synergy-deployment.log"]
#         volumeMounts:
#         - name: logs
#           mountPath: /var/log
#       volumes:
#       - name: logs
#         emptyDir: {}
# the same change as ONE command instead of kubectl edit (JSON patch):
kubectl -n exercise-51 patch deployment synergy-deployment --type=json -p='[
  {"op":"add","path":"/spec/template/spec/volumes","value":[{"name":"logs","emptyDir":{}}]},
  {"op":"add","path":"/spec/template/spec/containers/0/volumeMounts","value":[{"name":"logs","mountPath":"/var/log"}]},
  {"op":"add","path":"/spec/template/spec/containers/-","value":{"name":"sidecar","image":"busybox:stable","command":["/bin/sh","-c","tail -n+1 -f /var/log/synergy-deployment.log"],"volumeMounts":[{"name":"logs","mountPath":"/var/log"}]}}]'
kubectl -n exercise-51 rollout status deployment synergy-deployment
kubectl -n exercise-51 logs deploy/synergy-deployment -c sidecar | tail -3
# 참고: 두 컨테이너가 같은 emptyDir 을 /var/log 에 마운트해야 sidecar 가 로그 파일을 볼 수 있다.
#       tail -f 는 파일이 아직 없으면 바로 끝나므로(-F 는 기다림), 앱이 파일을 만든 뒤에야 sidecar 가 계속 돈다.
#       네이티브 sidecar(initContainers + restartPolicy: Always) 로 추가해도 된다.
