kubectl -n exercise-47 get pod orange                    # Init:CrashLoopBackOff / Init:Error
kubectl -n exercise-47 describe pod orange
kubectl -n exercise-47 logs orange -c init-myservice     # sh: sleeeep: not found
kubectl -n exercise-47 get pod orange -o yaml > orange.yaml
vi orange.yaml                                           # initContainers command: sleeeep 2 -> sleep 2
kubectl replace --force -f orange.yaml                   # delete + create in one step
kubectl -n exercise-47 get pod orange                    # Running
# 참고: init 컨테이너가 성공(exit 0)해야 본 컨테이너가 시작된다. 여러 개면 순서대로 하나씩.
