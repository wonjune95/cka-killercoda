kubectl -n exercise-54 get pods -o wide                              # some Pending: Insufficient cpu / memory
kubectl -n exercise-54 scale deployment wordpress --replicas=0
# with wordpress at 0, "Allocated resources" shows what the OTHER pods on the node already request
kubectl describe node node01 | grep -A8 -E '^Allocatable:|^Allocated resources:'
#   example:  Allocatable  cpu 1 (1000m)  memory 1930Mi      other pods request  cpu 250m  memory 290Mi
#     cpu:    (1000m - 250m) / 3 = 250m  -> leave ~15% overhead -> 210m per Pod
#     memory: (1930Mi - 290Mi) / 3 = 546Mi -> leave ~15% overhead -> 460Mi per Pod
# the same calculation done by the shell:
A_CPU=$(kubectl get node node01 -o jsonpath='{.status.allocatable.cpu}'); case $A_CPU in *m) A_CPU=${A_CPU%m};; *) A_CPU=$((A_CPU*1000));; esac
A_MEM=$(( $(kubectl get node node01 -o jsonpath='{.status.allocatable.memory}' | tr -d 'Ki') / 1024 ))
O_CPU=$(kubectl describe node node01 | awk '/^Allocated resources:/{f=1} f && $1=="cpu"{print $2; exit}'); case $O_CPU in *m) O_CPU=${O_CPU%m};; *) O_CPU=$((O_CPU*1000));; esac
O_MEM=$(kubectl describe node node01 | awk '/^Allocated resources:/{f=1} f && $1=="memory"{print $2; exit}'); case $O_MEM in *Gi) O_MEM=$(( ${O_MEM%Gi} * 1024 ));; *Mi) O_MEM=${O_MEM%Mi};; *Ki) O_MEM=$(( ${O_MEM%Ki} / 1024 ));; *) O_MEM=$(( O_MEM / 1048576 ));; esac
CPU=$(( (A_CPU - O_CPU) * 85 / 100 / 3 ))m; MEM=$(( (A_MEM - O_MEM) * 85 / 100 / 3 ))Mi
echo "per Pod: cpu=$CPU memory=$MEM"
kubectl -n exercise-54 edit deployment wordpress      # set the SAME requests on initContainers[0] and containers[0]
# the same change as ONE command instead of kubectl edit (JSON patch):
kubectl -n exercise-54 patch deployment wordpress --type=json -p="[
  {\"op\":\"replace\",\"path\":\"/spec/template/spec/initContainers/0/resources/requests\",\"value\":{\"cpu\":\"$CPU\",\"memory\":\"$MEM\"}},
  {\"op\":\"replace\",\"path\":\"/spec/template/spec/containers/0/resources/requests\",\"value\":{\"cpu\":\"$CPU\",\"memory\":\"$MEM\"}}]"
kubectl -n exercise-54 scale deployment wordpress --replicas=3
kubectl -n exercise-54 rollout status deployment wordpress
kubectl -n exercise-54 get pods -o wide                              # 3/3 Running on node01
# 참고: Pod 의 실효 요청량은 max(init 컨테이너 중 최댓값, 일반 컨테이너 합)이라 둘을 같게 두면 Pod 요청량도 그 값이다.
#       스케줄링은 실제 사용량이 아니라 requests 합계 기준이다 (kubectl top 은 실제 사용량).
