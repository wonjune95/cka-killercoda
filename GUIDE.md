# CKA Killercoda 랩 – 가이드

Killercoda CKA 플레이그라운드용 연습 랩 54개와 시간 제한 모의고사 3회분입니다. **풀이 보기**를 누르면 풀이가 열립니다.

## 1. 준비

1. https://killercoda.com/playgrounds/scenario/cka 를 열고 로그인한 뒤 **Start**를 누릅니다.
2. 터미널에서 저장소를 클론합니다.

```bash
git clone https://github.com/wonjune95/cka-killercoda.git
cd cka-killercoda
```

3. 스크립트 실행 시 *Permission denied*가 나오면 한 번만 실행합니다.

```bash
chmod +x lab.sh mock.sh lib/*.sh Question-*/*.sh Question-*/*.bash Mock-Exam-*/*/*.sh Mock-Exam-*/*/*.bash
```

## 2. 사용법

**연습 랩**

```bash
./lab.sh list            # 랩 54개 전체
./lab.sh 5               # 랩 5 셋업(또는 초기화) 후 문제 출력
./lab.sh 5 validate      # 답 채점
./lab.sh 5 solution      # 풀이 보기
./lab.sh 5 cleanup       # 랩 정리
```

**모의고사** (회차마다 Killercoda 새 세션 사용)

```bash
./mock.sh 1 start        # 15문제 전부 셋업, 120분 타이머 시작
./mock.sh 1 time         # 남은 시간
./mock.sh 1 4 question   # 4번 문제 다시 보기
./mock.sh 1 11           # 1회 Q11만: 그 문제에 도달했을 때 셋업
./mock.sh 1 score        # 전체 채점 후 점수 출력 (합격 = 10/15)
./mock.sh 1 cleanup      # 전부 정리
```

**모의고사 3회** (Killer Shell 스타일, 20문제, 합격 = 14/20)

```bash
./mock.sh 3 start        # 18문제 셋업; Q8과 Q20은 필요할 때 셋업
./mock.sh 3 8            # start 직후 맨 먼저 Q8 셋업 (클러스터에서 node01을 제거함)
./mock.sh 3 20           # Q20에 도달하면 셋업 (Service CIDR을 변경함)
./mock.sh 3 score
```

모의고사 문제에서 요구하는 답안 파일은 `/root/mock1/`, `/root/mock2/`, `/root/mock3/`에 둡니다.

**클러스터를 변경하는 랩:** 09, 18, 26, 27, 39, 40, 44 – 마지막에 하거나 새 세션에서 하세요 (27은 네트워크 플러그인을 제거합니다). 11과 29는 일부러 클러스터를 망가뜨립니다 – `./lab.sh 11 cleanup` / `./lab.sh 29 cleanup`으로 복구됩니다.

## 3. 연습 랩

### 랩 1 – Pod 기초  (워크로드와 스케줄링 | 쉬움 | 10분)

```bash
./lab.sh 1
```

```text
리소스 requests와 레이블을 지정한 Pod를 만들고 실행 중인지 확인하세요.

작업
1. exercise-01 네임스페이스를 만드세요
2. exercise-01 네임스페이스에 다음 조건으로 web Pod를 만드세요
   - 이미지: nginx:1.27
   - 레이블: app=web, tier=frontend
   - 리소스 requests: 메모리 64Mi, CPU 100m
   - 리소스 limits: 메모리 128Mi, CPU 250m
3. Pod가 실행 중이고 레이블이 올바른지 확인하세요
4. -o wide로 Pod의 IP 주소를 확인하세요
5. 실행 중인 Pod에 새 레이블 version=v1을 추가하세요
6. Pod에서 tier 레이블을 제거하세요
```

```bash
./lab.sh 1 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl create ns exercise-01
kubectl run web -n exercise-01 --image=nginx:1.27 --labels=app=web,tier=frontend --dry-run=client -o yaml > pod.yaml
# pod.yaml을 편집해 resources 블록을 추가한다 - 완성된 파일:
cat <<'EOF' > pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: web
  namespace: exercise-01
  labels:
    app: web
    tier: frontend
spec:
  containers:
  - name: web
    image: nginx:1.27
    resources:
      requests:
        memory: "64Mi"
        cpu: "100m"
      limits:
        memory: "128Mi"
        cpu: "250m"
EOF
kubectl apply -f pod.yaml
kubectl get pod web -n exercise-01 --show-labels
kubectl get pod web -n exercise-01 -o wide
kubectl label pod web -n exercise-01 version=v1
kubectl label pod web -n exercise-01 tier-
```

</details>

### 랩 2 – 멀티 컨테이너 Pod / 네이티브 sidecar  (워크로드와 스케줄링 | 보통 | 15분)

```bash
./lab.sh 2
```

```text
작업
1. exercise-02 네임스페이스를 만드세요
2. exercise-02 네임스페이스에 다음 조건으로 logger Pod를 만드세요
   - busybox:1.36을 쓰는 log-agent라는 init 컨테이너(sidecar)
     - init 컨테이너에 restartPolicy: Always를 설정해 네이티브 sidecar로 만드세요
     - 명령: tail -F /var/log/app/app.log   (대문자 F는 파일이 생길 때까지 기다림)
     - 공유 볼륨을 /var/log/app에 마운트하세요
   - busybox:1.36을 쓰는 app이라는 메인 컨테이너
     - 명령: 3초마다 /var/log/app/app.log에 한 줄씩 쓰기
     - 같은 공유 볼륨을 /var/log/app에 마운트하세요
   - log-volume이라는 emptyDir 볼륨을 사용하세요
3. 두 컨테이너가 모두 실행 중인지 확인하세요 (READY 2/2)
4. sidecar의 로그에서 스트리밍되는 출력을 확인하세요
```

```bash
./lab.sh 2 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl create ns exercise-02
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: logger
  namespace: exercise-02
spec:
  initContainers:
  - name: log-agent
    image: busybox:1.36
    restartPolicy: Always
    command: ["sh", "-c", "tail -F /var/log/app/app.log"]
    volumeMounts:
    - name: log-volume
      mountPath: /var/log/app
  containers:
  - name: app
    image: busybox:1.36
    command: ["sh", "-c", "while true; do echo \"$(date) - app running\" >> /var/log/app/app.log; sleep 3; done"]
    volumeMounts:
    - name: log-volume
      mountPath: /var/log/app
  volumes:
  - name: log-volume
    emptyDir: {}
EOF
kubectl get pod logger -n exercise-02          # READY 2/2
kubectl logs logger -n exercise-02 -c log-agent
```

</details>

### 랩 3 – ConfigMap과 Secret  (워크로드와 스케줄링 | 쉬움 | 10분)

```bash
./lab.sh 3
```

```text
작업
1. exercise-03 네임스페이스를 만드세요
2. 다음 내용으로 app-config ConfigMap을 만드세요
   - 키 APP_MODE = production
   - 키 LOG_LEVEL = debug
3. 다음 내용으로 db-creds Secret을 만드세요
   - 키 DB_USER = admin
   - 키 DB_PASS = s3cretP@ss
4. 다음 조건으로 app Pod를 만드세요
   - 이미지 busybox:1.36, 명령 sleep 3600
   - ConfigMap에서 APP_MODE와 LOG_LEVEL을 환경 변수로 불러오기
   - Secret에서 DB_USER와 DB_PASS를 환경 변수로 불러오기
   - ConfigMap 전체를 /etc/config/에 파일로 마운트하기
5. Pod 안에 환경 변수가 설정됐는지 확인하세요
6. /etc/config/에 마운트된 파일이 있는지 확인하세요
```

```bash
./lab.sh 3 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl create ns exercise-03
kubectl create configmap app-config -n exercise-03 --from-literal=APP_MODE=production --from-literal=LOG_LEVEL=debug
kubectl create secret generic db-creds -n exercise-03 --from-literal=DB_USER=admin --from-literal='DB_PASS=s3cretP@ss'
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: app
  namespace: exercise-03
spec:
  containers:
  - name: app
    image: busybox:1.36
    command: ["sleep", "3600"]
    envFrom:
    - configMapRef:
        name: app-config
    - secretRef:
        name: db-creds
    volumeMounts:
    - name: config-vol
      mountPath: /etc/config
  volumes:
  - name: config-vol
    configMap:
      name: app-config
EOF
kubectl exec app -n exercise-03 -- env | grep -E "APP_MODE|LOG_LEVEL|DB_USER|DB_PASS"
kubectl exec app -n exercise-03 -- ls /etc/config/
```

</details>

### 랩 4 – RBAC  (클러스터 아키텍처 | 보통 | 15분)

```bash
./lab.sh 4
```

```text
작업
1. exercise-04 네임스페이스를 만드세요
2. exercise-04 네임스페이스에 dev-sa ServiceAccount를 만드세요
3. exercise-04 네임스페이스에 다음을 허용하는 pod-manager Role을 만드세요
   - pods에 대해 get, list, watch, create, delete
   - services에 대해 get, list
4. pod-manager를 dev-sa에 바인딩하는 dev-pod-access RoleBinding을 만드세요
5. dev-sa가 exercise-04에서 pods를 list할 수 있는지 확인하세요
6. dev-sa가 default 네임스페이스에서는 pods를 list할 수 없는지 확인하세요
7. nodes에 대해 get, list를 허용하는 node-viewer ClusterRole을 만드세요
8. node-viewer를 dev-sa에 바인딩하는 dev-node-access ClusterRoleBinding을 만드세요
9. 이제 dev-sa가 nodes를 list할 수 있는지 확인하세요

실제 시험형 추가 시나리오
10. 한 개발자가 exercise-04에서 deployment를 삭제할 수 없다고 합니다. kubectl auth can-i로 원인을 찾으세요
11. dev-sa가 deployments에 대해 무엇을 할 수 있는지 확인하세요 ("no"가 나와야 함)
12. exercise-04 네임스페이스에서 dev-sa에 부여된 권한을 모두 나열하세요
```

```bash
./lab.sh 4 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl create ns exercise-04
kubectl create sa dev-sa -n exercise-04
cat <<'EOF' | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-manager
  namespace: exercise-04
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch", "create", "delete"]
- apiGroups: [""]
  resources: ["services"]
  verbs: ["get", "list"]
EOF
kubectl create rolebinding dev-pod-access -n exercise-04 --role=pod-manager --serviceaccount=exercise-04:dev-sa
AS=system:serviceaccount:exercise-04:dev-sa
kubectl auth can-i list pods -n exercise-04 --as=$AS       # yes
kubectl auth can-i list pods -n default --as=$AS           # no
kubectl create clusterrole node-viewer --verb=get,list --resource=nodes
kubectl create clusterrolebinding dev-node-access --clusterrole=node-viewer --serviceaccount=exercise-04:dev-sa
kubectl auth can-i list nodes --as=$AS                     # yes
kubectl auth can-i delete deployments -n exercise-04 --as=$AS   # no - Role에 apps/deployments 규칙이 없음
kubectl auth can-i --list -n exercise-04 --as=$AS
```

</details>

### 랩 5 – NetworkPolicy  (서비스와 네트워킹 | 보통 | 20분)

```bash
./lab.sh 5
```

```text
작업
1. exercise-05 네임스페이스를 만드세요
2. Pod 두 개를 배포하세요
   - 이미지 nginx:1.27, 레이블 role=frontend인 frontend
   - 이미지 nginx:1.27, 레이블 role=backend인 backend
3. frontend가 backend의 80번 포트에 접근할 수 있는지 확인하세요 (정책을 만들기 전에는 접근돼야 함)
4. 다음 조건으로 backend-policy NetworkPolicy를 만드세요
   - 레이블 role=backend인 Pod에 적용
   - 레이블 role=frontend인 Pod에서 80번 포트로 들어오는 ingress만 허용
   - DNS(UDP 53번 포트)로 나가는 egress 허용 - 빠뜨리면 DNS가 깨짐
5. frontend가 여전히 backend에 접근할 수 있는지 확인하세요
6. 세 번째 Pod attacker(이미지 nginx:1.27, 레이블 role=attacker)를 만들고 backend에 접근할 수 없는지 확인하세요
```

```bash
./lab.sh 5 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl create ns exercise-05
kubectl run frontend -n exercise-05 --image=nginx:1.27 --labels=role=frontend
kubectl run backend  -n exercise-05 --image=nginx:1.27 --labels=role=backend
kubectl run attacker -n exercise-05 --image=nginx:1.27 --labels=role=attacker
cat <<'EOF' | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-policy
  namespace: exercise-05
spec:
  podSelector:
    matchLabels:
      role: backend
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: frontend
    ports:
    - protocol: TCP
      port: 80
  egress:
  - ports:
    - protocol: UDP
      port: 53
EOF
BACKEND_IP=$(kubectl get pod backend -n exercise-05 -o jsonpath='{.status.podIP}')
kubectl exec frontend -n exercise-05 -- curl -m2 -s http://$BACKEND_IP     # 성공
kubectl exec attacker -n exercise-05 -- curl -m2 -s http://$BACKEND_IP     # 타임아웃
```

</details>

### 랩 6 – Deployment 롤링 업데이트와 롤백  (워크로드와 스케줄링 | 쉬움 | 10분)

```bash
./lab.sh 6
```

```text
작업
1. exercise-06 네임스페이스를 만드세요
2. 다음 조건으로 webapp Deployment를 만드세요
   - 레플리카 3개
   - 이미지: nginx:1.28
   - 전략: RollingUpdate, maxSurge=1, maxUnavailable=0
   - 변경 사유 기록 (어노테이션 kubernetes.io/change-cause)
3. 레플리카 3개가 모두 실행 중인지 확인하세요
4. 이미지를 nginx:1.29로 업데이트하고 변경 사유를 기록하세요
5. 롤아웃 상태를 지켜보세요
6. 롤아웃 히스토리를 확인하세요 - revision이 2개 보여야 합니다
7. 이전 버전(nginx:1.28)으로 롤백하세요
8. 이미지를 확인해 롤백이 됐는지 확인하세요
```

```bash
./lab.sh 6 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl create ns exercise-06
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
  namespace: exercise-06
spec:
  replicas: 3
  selector:
    matchLabels:
      app: webapp
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
      - name: nginx
        image: nginx:1.28
EOF
kubectl annotate deployment webapp -n exercise-06 kubernetes.io/change-cause="initial deploy nginx:1.28"
kubectl set image deployment/webapp nginx=nginx:1.29 -n exercise-06
kubectl annotate deployment webapp -n exercise-06 kubernetes.io/change-cause="update to nginx:1.29" --overwrite
kubectl rollout status deployment/webapp -n exercise-06
kubectl rollout history deployment/webapp -n exercise-06
kubectl rollout undo deployment/webapp -n exercise-06
kubectl get deploy webapp -n exercise-06 -o jsonpath='{.spec.template.spec.containers[0].image}'   # nginx:1.28
```

</details>

### 랩 7 – StatefulSet  (워크로드와 스케줄링 | 보통 | 15분)

```bash
./lab.sh 7
```

```text
default 네임스페이스에서 작업하세요.

작업
1. StatefulSet용 headless Service mysql을 만드세요 (포트 3306, 셀렉터 app=mysql)
2. nginx:1.28 이미지를 쓰는 레플리카 3개짜리 StatefulSet mysql을 만드세요
   - serviceName: mysql, 레이블 app=mysql, 이름이 mysql인 containerPort 3306
   - /data에 마운트되는 data라는 volumeClaimTemplate (ReadWriteOnce, 1Gi)
3. Pod가 순서대로 시작되는지 확인하세요 (mysql-0 먼저, 다음 mysql-1, 그다음 mysql-2)
4. 각 Pod에 PersistentVolumeClaim이 붙어 있는지 확인하세요
5. Pod 하나를 삭제하고 같은 이름과 스토리지로 다시 생기는 것을 확인하세요
6. kubectl scale로 StatefulSet을 늘렸다 줄여 보세요
7. StatefulSet을 삭제하고 PVC가 남아 있는지 확인하세요 (데이터 유지)
```

```bash
./lab.sh 7 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: mysql
  labels:
    app: mysql
spec:
  clusterIP: None
  selector:
    app: mysql
  ports:
  - port: 3306
    name: mysql
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
spec:
  serviceName: mysql
  replicas: 3
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: nginx
        image: nginx:1.28
        ports:
        - containerPort: 3306
          name: mysql
        volumeMounts:
        - name: data
          mountPath: /data
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 1Gi
EOF
kubectl get pods -l app=mysql -w            # mysql-0, mysql-1, mysql-2 순서대로
kubectl get pvc                             # data-mysql-0/1/2
kubectl run debug --image=busybox:1.36 --rm -it --restart=Never -- nslookup mysql-0.mysql.default.svc.cluster.local
kubectl delete pod mysql-1 && kubectl get pods -l app=mysql   # mysql-1이 다시 생김
kubectl scale statefulset mysql --replicas=4
kubectl scale statefulset mysql --replicas=2
kubectl delete statefulset mysql
kubectl get pvc                             # PVC는 그대로 남음
```

</details>

### 랩 8 – 노드 drain과 cordon  (클러스터 아키텍처 | 쉬움 | 10분)

```bash
./lab.sh 8
```

```text
default 네임스페이스에서 작업하세요. Killercoda의 워커 노드는 node01입니다.

작업
1. 노드를 모두 나열하고 워커 노드를 찾으세요
2. 워커 노드를 cordon하세요 (스케줄 불가로 표시)
3. 노드가 SchedulingDisabled로 표시되는지 확인하세요
4. drain-test Deployment(이미지 nginx:1.27, 레플리카 3개)를 만들고 Pod가 어디에 스케줄되는지 확인하세요
5. 워커 노드를 drain하세요 - DaemonSet과 로컬 데이터를 처리하세요
6. DaemonSet이 아닌 Pod가 모두 노드에서 축출됐는지 확인하세요
7. 노드를 uncordon하세요
8. Deployment를 레플리카 6개로 늘리고 uncordon한 노드에 Pod가 스케줄되는지 확인하세요
```

```bash
./lab.sh 8 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl get nodes
kubectl cordon node01
kubectl get nodes                                        # node01 SchedulingDisabled
kubectl create deployment drain-test --image=nginx:1.27 --replicas=3
kubectl get pods -o wide
kubectl drain node01 --ignore-daemonsets --delete-emptydir-data
kubectl get pods -A --field-selector spec.nodeName=node01   # DaemonSet Pod만 남음
kubectl uncordon node01
kubectl scale deployment drain-test --replicas=6
kubectl get pods -o wide                                 # 일부 Pod가 다시 node01에 배치됨
```

</details>

### 랩 9 – kubeadm 클러스터 업그레이드  (클러스터 아키텍처 | 어려움 | 25분)

```bash
./lab.sh 9
```

```text
랩 셋업에서 두 노드 모두에 apt 저장소를 준비해 두었습니다.
목표 버전:       cat /root/upgrade-target.txt          (예: v1.36.0)
apt 패키지:      cat /root/upgrade-target-package.txt  (예: 1.36.0-1.1)

작업
1. 현재 클러스터 버전을 확인하세요 (kubectl get nodes, kubeadm version)
2. 컨트롤 플레인 노드(controlplane)를 목표 버전으로 업그레이드하세요
   a. kubeadm 패키지를 목표 버전으로 업데이트
   b. kubeadm upgrade plan으로 가능한 업그레이드 확인
   c. kubeadm upgrade apply <목표 버전> 실행
   d. kubelet과 kubectl 패키지 업그레이드
   e. kubelet 재시작
3. 워커 노드(node01)를 업그레이드하세요
   a. 워커 노드 drain
   b. 워커에서 kubeadm, kubelet, kubectl 패키지 업데이트
   c. kubeadm upgrade node 실행
   d. kubelet 재시작
   e. 워커 uncordon
4. 모든 노드가 새 버전으로 표시되는지 확인하세요

참고: 업그레이드는 되돌릴 수 없습니다. 다시 연습하려면 Killercoda 새 세션을 시작하세요.
```

```bash
./lab.sh 9 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
VER=$(cat /root/upgrade-target.txt); PKG=$(cat /root/upgrade-target-package.txt)

# === 컨트롤 플레인 (controlplane) ===
kubectl drain controlplane --ignore-daemonsets          # 선택이지만 권장
apt-mark unhold kubeadm
apt-get update && apt-get install -y kubeadm=$PKG
apt-mark hold kubeadm
kubeadm version
kubeadm upgrade plan
kubeadm upgrade apply $VER -y
apt-mark unhold kubelet kubectl
apt-get install -y kubelet=$PKG kubectl=$PKG
apt-mark hold kubelet kubectl
systemctl daemon-reload && systemctl restart kubelet
kubectl uncordon controlplane
kubectl get nodes

# === 워커 (node01) ===
kubectl drain node01 --ignore-daemonsets --delete-emptydir-data
ssh node01
  PKG=<paste the package version>
  apt-mark unhold kubeadm kubelet kubectl
  apt-get update && apt-get install -y kubeadm=$PKG kubelet=$PKG kubectl=$PKG
  apt-mark hold kubeadm kubelet kubectl
  kubeadm upgrade node
  systemctl daemon-reload && systemctl restart kubelet
  exit
kubectl uncordon node01
kubectl get nodes          # 두 노드 모두 새 버전

# 기억할 것: 컨트롤 플레인 = kubeadm upgrade apply, 워커 = kubeadm upgrade node
```

</details>

### 랩 10 – static Pod  (워크로드와 스케줄링 | 쉬움 | 10분)

```bash
./lab.sh 10
```

```text
컨트롤 플레인 노드(controlplane)에서 작업하세요.

작업
1. 노드에서 static Pod 매니페스트 디렉터리를 찾으세요
2. 다음 조건으로 static-web이라는 Pod의 static Pod 매니페스트 파일을 만드세요
   - 이미지: nginx:1.27
   - 포트: 80
3. kubectl get pods에 static Pod가 나타나는지 확인하세요 (이름 뒤에 노드 이름이 붙음)
   -> 이 단계에서 ./lab.sh 10 validate를 실행해 이 부분을 채점하세요
4. kubectl로 static Pod를 삭제해 보고 어떻게 되는지 확인하세요
5. 매니페스트 파일을 지워 static Pod를 삭제하세요
6. Pod가 사라졌는지 확인하세요
   -> ./lab.sh 10 validate를 다시 실행하세요
```

```bash
./lab.sh 10 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
grep staticPodPath /var/lib/kubelet/config.yaml      # /etc/kubernetes/manifests
cat <<'EOF' > /etc/kubernetes/manifests/static-web.yaml
apiVersion: v1
kind: Pod
metadata:
  name: static-web
  labels:
    app: static-web
spec:
  containers:
  - name: web
    image: nginx:1.27
    ports:
    - containerPort: 80
EOF
kubectl get pods | grep static-web                   # static-web-controlplane
kubectl delete pod static-web-controlplane           # 다시 생김 (mirror Pod)
rm /etc/kubernetes/manifests/static-web.yaml
kubectl get pods | grep static-web                   # 사라짐
```

</details>

### 랩 11 – 클러스터 구성 요소 트러블슈팅  (트러블슈팅 | 어려움 | 25분)

```bash
./lab.sh 11
```

```text
랩 셋업이 클러스터를 망가뜨렸습니다. 문제를 모두 찾아 고치세요.

시나리오 A: 고장 난 kubelet
1. 워커 노드 하나가 NotReady입니다. 어느 노드인지, 왜 그런지 찾으세요
2. 그 노드에 SSH로 접속해 kubelet 서비스 상태와 로그를 확인하세요
3. 노드가 Ready가 되도록 고치고, 재부팅 후에도 유지되게 하세요

시나리오 B: CoreDNS 트러블슈팅
1. Pod를 만들어 서비스 이름(kubernetes.default)을 조회해 보세요 - 실패합니다
2. kube-system의 CoreDNS Pod를 확인하세요
3. kube-dns 서비스에 엔드포인트가 있는지 확인하세요
4. CoreDNS 로그에서 오류를 확인하세요
5. CoreDNS ConfigMap에 잘못된 설정이 있는지 확인하세요
6. 문제를 모두 고치고 DNS 조회가 되는지 확인하세요

시나리오 C: kube-proxy (조사만)
1. kube-proxy Pod가 모든 노드에서 실행 중인지 확인하세요
2. kube-proxy 로그를 확인하세요
3. kube-proxy ConfigMap을 확인하세요
4. 노드의 iptables 규칙을 확인하세요

시나리오 D: API 서버 audit 로그 (조사만)
1. kube-apiserver 매니페스트에서 audit 플래그(--audit-policy-file, --audit-log-path)를 확인하세요
2. Killercoda는 기본적으로 audit 로깅을 켜지 않습니다 - 켜려면 어떤 플래그와 볼륨
   마운트를 추가해야 하는지, 로그 파일이 어디에 쓰이는지 정리하세요
```

```bash
./lab.sh 11 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
# ---- 시나리오 A: kubelet ----
kubectl get nodes                              # node01 NotReady
ssh node01
  systemctl status kubelet                     # inactive (dead), disabled
  journalctl -u kubelet --no-pager | tail -20
  systemctl enable --now kubelet               # enable = 재부팅 후에도 유지
  exit
kubectl get nodes                              # node01 Ready

# ---- 시나리오 B: CoreDNS ----
kubectl run test-dns --image=busybox:1.36 --rm -it --restart=Never -- nslookup kubernetes.default   # 실패
kubectl get pods -n kube-system -l k8s-app=kube-dns        # Pod 없음
kubectl get endpoints kube-dns -n kube-system              # 엔드포인트 없음
kubectl get deploy coredns -n kube-system                  # 0/0 replicas
kubectl scale deploy coredns -n kube-system --replicas=2
kubectl get pods -n kube-system -l k8s-app=kube-dns        # CrashLoopBackOff
kubectl logs -n kube-system -l k8s-app=kube-dns            # Unknown directive 'kubernetess'
kubectl edit cm coredns -n kube-system                     # kubernetess -> kubernetes
kubectl rollout restart deploy coredns -n kube-system
kubectl get endpoints kube-dns -n kube-system              # IP가 표시됨
kubectl run test-dns --image=busybox:1.36 --rm -it --restart=Never -- nslookup kubernetes.default   # 성공

# ---- 시나리오 C: kube-proxy ----
kubectl get ds kube-proxy -n kube-system
kubectl get pods -n kube-system -l k8s-app=kube-proxy -o wide
kubectl logs -n kube-system -l k8s-app=kube-proxy --tail=20
kubectl get cm kube-proxy -n kube-system -o yaml
iptables-save | grep -c KUBE

# ---- 시나리오 D: audit 로그 ----
grep -i audit /etc/kubernetes/manifests/kube-apiserver.yaml   # Killercoda에서는 아무것도 없음
# 켜려면 예를 들어 다음을 추가한다:
#   - --audit-policy-file=/etc/kubernetes/audit-policy.yaml
#   - --audit-log-path=/var/log/kubernetes/audit/audit.log
#   - --audit-log-maxage=7
# 그리고 정책 파일과 로그 디렉터리용 hostPath 볼륨 + volumeMounts.
# 그다음: tail /var/log/kubernetes/audit/audit.log | jq 'select(.responseStatus.code>=400)'
```

</details>

### 랩 12 – 스토리지: PV, PVC와 Pod  (스토리지 | 보통 | 15분)

```bash
./lab.sh 12
```

```text
작업
1. exercise-12 네임스페이스를 만드세요
2. 다음 조건으로 my-pv PersistentVolume을 만드세요
   - 용량: 1Gi
   - 접근 모드: ReadWriteOnce
   - StorageClass: manual
   - hostPath: /data/exercise-12
   - 회수 정책: Retain
3. exercise-12 네임스페이스에 다음 조건으로 my-pvc PersistentVolumeClaim을 만드세요
   - 요청: 500Mi
   - 접근 모드: ReadWriteOnce
   - StorageClass: manual
4. my-pvc를 /data에 마운트하는 storage-consumer Pod(busybox, sleep 3600)를 만드세요
5. 다음을 확인하세요
   - PVC가 PV에 Bound 상태
   - Pod가 Running 상태 (Pending에 멈추지 않음)
6. Pod에서 마운트된 볼륨 안에 테스트 파일 /data/test.txt를 쓰세요
7. Pod를 삭제하고 같은 PVC로 새 Pod를 만든 뒤 파일이 남아 있는지 확인하세요
8. Pod와 PVC를 삭제하고 PV 상태를 확인하세요 (정책이 Retain이므로 Available이 아니라 Released여야 함)
```

```bash
./lab.sh 12 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl create ns exercise-12
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-pv
spec:
  capacity:
    storage: 1Gi
  accessModes: ["ReadWriteOnce"]
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  hostPath:
    path: /data/exercise-12
    type: DirectoryOrCreate
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
  namespace: exercise-12
spec:
  accessModes: ["ReadWriteOnce"]
  storageClassName: manual
  resources:
    requests:
      storage: 500Mi
EOF
kubectl get pvc my-pvc -n exercise-12          # Bound
cat <<'EOF' > pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: storage-consumer
  namespace: exercise-12
spec:
  nodeName: node01               # hostPath 데이터가 있는 같은 노드에 Pod를 고정
  containers:
  - name: consumer
    image: busybox:1.36
    command: ["sleep", "3600"]
    volumeMounts:
    - name: data
      mountPath: /data
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: my-pvc
EOF
kubectl apply -f pod.yaml
kubectl wait --for=condition=Ready pod/storage-consumer -n exercise-12
kubectl exec storage-consumer -n exercise-12 -- sh -c 'echo "data persists" > /data/test.txt'
kubectl delete pod storage-consumer -n exercise-12 && kubectl apply -f pod.yaml
kubectl wait --for=condition=Ready pod/storage-consumer -n exercise-12
kubectl exec storage-consumer -n exercise-12 -- cat /data/test.txt   # data persists
kubectl delete pod storage-consumer -n exercise-12
kubectl delete pvc my-pvc -n exercise-12
kubectl get pv my-pv                            # Released
# 참고: hostPath는 노드 로컬이다. Pod를 고정(nodeName/nodeSelector)하면 두 Pod가 같은 노드에 뜬다.
```

</details>

### 랩 13 – Helm 설치, 업그레이드와 롤백  (클러스터 아키텍처 | 보통 | 15분)

```bash
./lab.sh 13
```

```text
작업
1. Bitnami 차트 저장소(이름 bitnami, https://charts.bitnami.com/bitnami)를 추가하고 저장소 캐시를 업데이트하세요
2. Helm으로 exercise-13 네임스페이스에 NGINX(차트 bitnami/nginx)를 설치하세요
   - 릴리스 이름: web
   - replicaCount=2 설정
3. 릴리스가 deployed 상태이고 Pod 2개가 실행 중인지 확인하세요
4. 릴리스를 replicaCount=3으로 업그레이드하세요
5. 릴리스 히스토리를 확인하고 revision이 2개인지 확인하세요
6. revision 1로 롤백하세요
7. 레플리카 수가 다시 2인지 확인하세요
```

```bash
./lab.sh 13 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install web bitnami/nginx -n exercise-13 --create-namespace --set replicaCount=2
helm list -n exercise-13
kubectl get pods -n exercise-13
helm upgrade web bitnami/nginx -n exercise-13 --reuse-values --set replicaCount=3
helm history web -n exercise-13                # revision 2개
helm rollback web 1 -n exercise-13
kubectl get deploy -n exercise-13 -o jsonpath='{.items[0].spec.replicas}'   # 2
helm history web -n exercise-13                # 3줄, 마지막 = "Rollback to 1"

# Pod가 ImagePullBackOff에 멈춰 있다면: Bitnami가 2025년에 무료 이미지 대부분을
# docker.io/bitnamilegacy로 옮겼다. install/upgrade에 다음 플래그를 추가한다:
#   --set image.repository=bitnamilegacy/nginx --set global.security.allowInsecureImages=true
# 채점 대상은 Helm 작업(install/upgrade/history/rollback)이다.
```

</details>

### 랩 14 – Kustomize: base와 overlay  (클러스터 아키텍처 | 보통 | 15분)

```bash
./lab.sh 14
```

```text
작업
1. /root 아래에 다음 디렉터리 구조를 만드세요
     /root/kustomize-lab/
       base/
         deployment.yaml
         service.yaml
         kustomization.yaml
       overlays/
         staging/
           kustomization.yaml
2. base에는
   - 이미지 nginx:1.27, 레플리카 1개인 app Deployment
   - 80번 포트의 ClusterIP Service app-svc
   - 두 리소스를 나열한 kustomization.yaml
3. staging overlay에서는
   - 네임스페이스를 exercise-14로 설정
   - replicas를 3으로 패치
   - 공통 레이블 env: staging 추가
4. exercise-14 네임스페이스를 만드세요
5. kubectl apply -k로 staging overlay를 적용하세요
6. exercise-14 네임스페이스에 레이블 env=staging인 Pod 3개가 실행 중인지 확인하세요
```

```bash
./lab.sh 14 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
mkdir -p /root/kustomize-lab/base /root/kustomize-lab/overlays/staging
cd /root/kustomize-lab
cat <<'EOF' > base/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app
  template:
    metadata:
      labels:
        app: app
    spec:
      containers:
      - name: nginx
        image: nginx:1.27
        ports:
        - containerPort: 80
EOF
cat <<'EOF' > base/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: app-svc
spec:
  selector:
    app: app
  ports:
  - port: 80
    targetPort: 80
EOF
cat <<'EOF' > base/kustomization.yaml
resources:
- deployment.yaml
- service.yaml
EOF
cat <<'EOF' > overlays/staging/kustomization.yaml
resources:
- ../../base
namespace: exercise-14
labels:
- pairs:
    env: staging
  includeSelectors: true
  includeTemplates: true
replicas:
- name: app
  count: 3
EOF
kubectl create ns exercise-14
kubectl kustomize overlays/staging          # 미리 보기
kubectl apply -k overlays/staging
kubectl get pods -n exercise-14 -l env=staging
# (commonLabels: {env: staging}도 되지만 deprecated)
```

</details>

### 랩 15 – Gateway API: Gateway와 HTTPRoute  (서비스와 네트워킹 | 보통 | 20분)

```bash
./lab.sh 15
```

```text
랩 셋업에서 Envoy Gateway와 eg라는 GatewayClass를 설치해 두었습니다.

작업
1. exercise-15 네임스페이스를 만드세요
2. 클러스터에 GatewayClass가 있는지 확인하세요
3. exercise-15 네임스페이스에 web-gateway Gateway를 만드세요
   - 기존 GatewayClass를 참조
   - 80번 포트, HTTP 프로토콜로 수신
4. 이미지 nginx:1.28, 레플리카 2개인 web Deployment를 만드세요
5. 80번 포트의 ClusterIP Service web-svc로 노출하세요
6. 다음 조건으로 web-route HTTPRoute를 만드세요
   - web-gateway를 parent로 참조
   - 경로 접두사 / 매칭
   - web-svc의 80번 포트로 라우팅
7. Gateway 상태가 Programmed: True인지 확인하세요
8. HTTPRoute가 Gateway에 연결됐는지 확인하세요
보너스: 게이트웨이를 거쳐 요청을 보내 보세요 (Envoy는 envoy-gateway-system에 NodePort Service로 노출됨)
```

```bash
./lab.sh 15 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl create ns exercise-15
kubectl get gatewayclass                      # eg
cat <<'EOF' | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: web-gateway
  namespace: exercise-15
spec:
  gatewayClassName: eg
  listeners:
  - name: http
    port: 80
    protocol: HTTP
    allowedRoutes:
      namespaces:
        from: Same
EOF
kubectl create deployment web -n exercise-15 --image=nginx:1.28 --replicas=2
kubectl expose deployment web -n exercise-15 --name=web-svc --port=80 --target-port=80
cat <<'EOF' | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: web-route
  namespace: exercise-15
spec:
  parentRefs:
  - name: web-gateway
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: web-svc
      port: 80
EOF
kubectl get gateway web-gateway -n exercise-15          # PROGRAMMED True
kubectl describe httproute web-route -n exercise-15     # Accepted / ResolvedRefs True
# 보너스: 게이트웨이를 거친 테스트
SVC=$(kubectl get svc -n envoy-gateway-system -l gateway.envoyproxy.io/owning-gateway-name=web-gateway -o jsonpath='{.items[0].metadata.name}')
NP=$(kubectl get svc $SVC -n envoy-gateway-system -o jsonpath='{.spec.ports[?(@.port==80)].nodePort}')
curl -s http://node01:$NP | head -4
```

</details>

### 랩 16 – Horizontal Pod Autoscaler  (워크로드와 스케줄링 | 보통 | 15분)

```bash
./lab.sh 16
```

```text
랩 셋업에서 metrics-server를 설치해 두었습니다.

작업
1. exercise-16 네임스페이스를 만드세요
2. 클러스터에서 metrics-server가 실행 중인지 확인하세요
3. 다음 조건으로 load-app Deployment를 만드세요
   - 이미지: registry.k8s.io/hpa-example (또는 nginx:1.27)
   - 레플리카 1개
   - CPU request: 50m
   - CPU limit: 100m
4. 80번 포트의 ClusterIP Service load-svc로 노출하세요
5. load-app을 대상으로 하는 HPA를 만드세요
   - 최소 레플리카: 1
   - 최대 레플리카: 5
   - 목표 CPU 사용률: 50% (type: Utilization, averageUtilization: 50)
6. HPA YAML 구조가 올바른지 확인하세요 (target type이 AverageValue가 아니라 Utilization)
7. 서비스에 부하를 주고 HPA가 스케일 업하는 것을 확인하세요
8. 부하를 멈추고 HPA가 다시 스케일 다운하는 것을 확인하세요
```

```bash
./lab.sh 16 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl create ns exercise-16
kubectl get pods -n kube-system | grep metrics-server
kubectl top nodes
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: load-app
  namespace: exercise-16
spec:
  replicas: 1
  selector:
    matchLabels:
      app: load-app
  template:
    metadata:
      labels:
        app: load-app
    spec:
      containers:
      - name: app
        image: registry.k8s.io/hpa-example
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: "50m"
          limits:
            cpu: "100m"
EOF
kubectl expose deployment load-app -n exercise-16 --name=load-svc --port=80 --target-port=80
cat <<'EOF' | kubectl apply -f -
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: load-app
  namespace: exercise-16
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: load-app
  minReplicas: 1
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
EOF
# (명령형 대안: kubectl autoscale deployment load-app -n exercise-16 --cpu=50% --min=1 --max=5 ; 예전 kubectl: --cpu-percent=50)
kubectl get hpa load-app -n exercise-16 -o yaml | grep -A4 target:
# 터미널 1 - 부하 생성:
kubectl run load-gen -n exercise-16 --image=busybox:1.36 --rm -it --restart=Never -- sh -c "while true; do wget -q -O- http://load-svc; done"
# 터미널 2 - 관찰:
kubectl get hpa -n exercise-16 -w
# Ctrl+C로 부하를 멈추고 스케일 다운까지 약 5분 기다린다
```

</details>

### 랩 17 – kubectl debug: Pod와 노드  (트러블슈팅 | 보통 | 15분)

```bash
./lab.sh 17
```

```text
파트 A: Pod 디버그
1. exercise-17 네임스페이스를 만드세요
2. 이미지 nginx:1.27로 broken-app Pod를 만드세요
3. kubectl debug로 실행 중인 Pod에 디버그 컨테이너를 붙이세요
   - 이미지: busybox:1.36
   - broken-app 컨테이너를 대상으로 지정해 프로세스 네임스페이스를 공유
4. 디버그 컨테이너 안에서 프로세스 목록을 확인하세요 (nginx 프로세스가 보여야 함)
5. 디버그 컨테이너에서 파일 시스템과 네트워크를 확인하세요
6. 디버그 세션을 종료하세요

파트 B: 노드 디버그
7. 노드(예: node01)를 대상으로 kubectl debug를 실행해 호스트 파일 시스템에 접근할 수 있는 셸을 얻으세요
8. chroot /host로 실제 노드 루트에 접근하세요
9. 디버그 세션에서 kubelet 상태를 확인하세요
10. 디버그 세션을 종료하세요 (채점을 위해 node-debugger Pod는 남겨 두세요)
```

```bash
./lab.sh 17 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
# 파트 A
kubectl create ns exercise-17
kubectl run broken-app -n exercise-17 --image=nginx:1.27
kubectl wait --for=condition=Ready pod/broken-app -n exercise-17
kubectl debug broken-app -n exercise-17 -it --image=busybox:1.36 --target=broken-app
  ps aux                       # nginx master + workers
  ls /proc/1/root/etc/nginx/   # 대상 컨테이너의 파일 시스템
  wget -qO- localhost:80       # 네트워크 네임스페이스가 공유됨
  exit

# 파트 B
kubectl debug node/node01 -it --image=busybox:1.36
  chroot /host
  systemctl status kubelet
  journalctl -u kubelet --no-pager | tail -20
  crictl ps
  exit   # chroot 나가기
  exit   # 디버그 Pod 나가기
kubectl get pods | grep node-debugger
```

</details>

### 랩 18 – 릴리스 바이너리로 CRI-dockerd 설치  (클러스터 아키텍처 | 보통 | 15분)

```bash
./lab.sh 18
```

```text
워커 노드에서 작업하세요:  ssh node01

작업
1. 필요한 커널 모듈 overlay와 br_netfilter를 로드하세요
2. sysctl로 커널 네트워크 파라미터를 설정하세요 (/etc/sysctl.d/에 영구 설정)
   net.bridge.bridge-nf-call-iptables = 1, net.ipv4.ip_forward = 1, net.ipv6.conf.all.forwarding = 1
3. Docker를 설치하세요 (CRI-dockerd에 필요한 의존성) - 이미 설치돼 있으면 건너뛰세요
4. GitHub 릴리스에서 CRI-dockerd 바이너리(v0.3.20 .tgz)를 내려받아 /usr/local/bin에 설치하세요
5. cri-docker.service와 cri-docker.socket의 systemd 유닛 파일을 만드세요
6. cri-docker 서비스를 활성화하고 시작하세요
7. CRI-dockerd 소켓이 /run/cri-dockerd.sock에서 대기 중인지 확인하세요
```

```bash
./lab.sh 18 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
ssh node01
modprobe overlay && modprobe br_netfilter
cat <<'EOF' > /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
cat <<'EOF' > /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
EOF
sysctl --system
command -v docker || { apt-get update && apt-get install -y docker.io; }
systemctl enable --now docker

VER=0.3.20
wget -q https://github.com/Mirantis/cri-dockerd/releases/download/v${VER}/cri-dockerd-${VER}.amd64.tgz
tar xzf cri-dockerd-${VER}.amd64.tgz
install -m 0755 cri-dockerd/cri-dockerd /usr/local/bin/cri-dockerd
cri-dockerd --version

cat <<'EOF' > /etc/systemd/system/cri-docker.service
[Unit]
Description=CRI Interface for Docker Application Container Engine
After=network-online.target firewalld.service docker.service
Wants=network-online.target
Requires=cri-docker.socket

[Service]
Type=notify
ExecStart=/usr/local/bin/cri-dockerd --container-runtime-endpoint fd:// --network-plugin=cni
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutSec=0
RestartSec=2
Restart=always

[Install]
WantedBy=multi-user.target
EOF
cat <<'EOF' > /etc/systemd/system/cri-docker.socket
[Unit]
Description=CRI Docker Socket for the API
PartOf=cri-docker.service

[Socket]
ListenStream=%t/cri-dockerd.sock
SocketMode=0660
SocketUser=root
SocketGroup=docker

[Install]
WantedBy=sockets.target
EOF
systemctl daemon-reload
systemctl enable --now cri-docker.socket cri-docker.service
systemctl status cri-docker.service cri-docker.socket --no-pager
ls -la /run/cri-dockerd.sock
crictl --runtime-endpoint unix:///run/cri-dockerd.sock version
# kubeadm join ... --cri-socket unix:///run/cri-dockerd.sock   (사용하는 방법)
```

</details>

### 랩 19 – 클래식 Ingress  (서비스와 네트워킹 | 보통 | 15분)

```bash
./lab.sh 19
```

```text
랩 셋업에서 ingress-nginx 컨트롤러(IngressClass nginx)를 설치했습니다.

작업
1. exercise-19 네임스페이스를 만드세요
2. Deployment 두 개를 만드세요:
   - web-app: 이미지 nginx:1.28, 레플리카 2개, 포트 80으로 서비스
   - api-app: 이미지 nginx:1.28, 레플리카 2개
3. web-app을 포트 80(targetPort 80)의 ClusterIP Service web-service로 노출하세요
4. api-app을 포트 8080(targetPort 80)의 ClusterIP Service api-service로 노출하세요
5. 다음과 같이 라우팅하는 Ingress app-ingress(ingressClassName nginx)를 만드세요:
   - /    트래픽은 web-service:80으로
   - /api 트래픽은 api-service:8080으로
   - 기본 백엔드(일치하는 경로가 없을 때)는 web-service:80을 가리키도록
6. Ingress가 만들어졌고 주소가 할당되었는지 확인하세요
7. Ingress를 describe해서(규칙 확인) 그리고 컨트롤러 NodePort로 curl해서 경로 기반 라우팅을 테스트하세요
```

```bash
./lab.sh 19 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl create ns exercise-19
kubectl create deployment web-app -n exercise-19 --image=nginx:1.28 --replicas=2
kubectl create deployment api-app -n exercise-19 --image=nginx:1.28 --replicas=2
kubectl expose deployment web-app -n exercise-19 --name=web-service --port=80 --target-port=80
kubectl expose deployment api-app -n exercise-19 --name=api-service --port=8080 --target-port=80
kubectl get endpoints -n exercise-19
cat <<'EOF' | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  namespace: exercise-19
spec:
  ingressClassName: nginx
  defaultBackend:
    service:
      name: web-service
      port:
        number: 80
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 8080
EOF
kubectl get ingress -n exercise-19 -w          # ADDRESS가 채워짐
kubectl describe ingress app-ingress -n exercise-19
NP=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.spec.ports[?(@.port==80)].nodePort}')
curl -s -o /dev/null -w "%{http_code}\n" http://node01:$NP/        # 200
```

</details>

### 랩 20 – Pod Security Standards  (클러스터 아키텍처 | 보통 | 15분)

```bash
./lab.sh 20
```

```text
작업
1. exercise-20 네임스페이스를 만드세요
2. enforce 모드의 restricted 수준 Pod Security Standards 레이블을 붙이세요
3. exercise-20에서 privileged 컨테이너가 있는 Pod를 실행해 보세요 - 거부되어야 합니다
4. baseline PSS 수준(enforce)으로 두 번째 네임스페이스 exercise-20-baseline을 만드세요
5. baseline 네임스페이스에서 runAsNonRoot: true, runAsUser: 1000으로 Pod safe-pod(busybox:1.36, sleep 3600)를
   실행하세요 - 성공해야 합니다
6. baseline 네임스페이스에서 privileged: true인 Pod를 실행하세요 - 거부되어야 합니다
7. restricted 수준을 audit과 warn 모드로만(enforce 없이) 적용한 세 번째 네임스페이스 exercise-20-audit을 만드세요
8. exercise-20-audit에서 privileged Pod audit-pod(nginx:1.28)를 실행하세요 - 성공해야 하지만,
   kubectl이 경고를 출력하고 위반 사항이 API audit 로그에 기록됩니다
9. audit/warn 모드에서 Pod를 만들 때 반환된 경고를 확인하세요
```

```bash
./lab.sh 20 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl create ns exercise-20
kubectl label ns exercise-20 pod-security.kubernetes.io/enforce=restricted
kubectl run rogue --image=nginx:1.28 --privileged -n exercise-20          # 거부됨 (forbidden)

kubectl create ns exercise-20-baseline
kubectl label ns exercise-20-baseline pod-security.kubernetes.io/enforce=baseline
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: safe-pod
  namespace: exercise-20-baseline
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
  containers:
  - name: app
    image: busybox:1.36
    command: ["sleep", "3600"]
EOF
kubectl run priv-pod --image=nginx:1.28 --privileged -n exercise-20-baseline   # 거부됨

kubectl create ns exercise-20-audit
kubectl label ns exercise-20-audit pod-security.kubernetes.io/audit=restricted pod-security.kubernetes.io/warn=restricted
kubectl run audit-pod --image=nginx:1.28 --privileged -n exercise-20-audit    # 생성됨, "Warning: would violate PodSecurity restricted..." 경고 출력
kubectl get ns exercise-20 exercise-20-baseline exercise-20-audit --show-labels
```

</details>

### 랩 21 – Job과 CronJob  (워크로드와 스케줄링 | 보통 | 15분)

```bash
./lab.sh 21
```

```text
default 네임스페이스에서 작업하세요.

작업
1. 이미지 busybox:1.37로 명령 echo "Cleanup complete"를 실행하는 Job cleanup-job을 만드세요.
   3번(completions=3) 순차로(parallelism=1) 실행되게 하세요
2. Job이 완료(3/3)까지 실행되는지 확인하고 Pod 로그를 확인하세요
3. 매시간(0 * * * *) 실행되는 CronJob hourly-backup(이미지 busybox:1.37)을 만드세요
   명령: sh -c 'echo "Running backup-script.sh"; date'
   성공한 Job 기록은 3개 유지하세요(successfulJobsHistoryLimit=3)
4. CronJob 목록을 조회하고 다음 예약 시각을 확인하세요
5. CronJob으로부터 Job manual-backup을 만들어 수동으로 한 번 실행하세요
6. 수동 Job이 실행되어 출력을 남겼는지 확인하세요
```

```bash
./lab.sh 21 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl create job cleanup-job --image=busybox:1.37 --dry-run=client -o yaml -- echo "Cleanup complete" > job.yaml
# spec 아래에 추가:  completions: 3   parallelism: 1
cat <<'EOF' | kubectl apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: cleanup-job
spec:
  completions: 3
  parallelism: 1
  template:
    spec:
      restartPolicy: Never
      containers:
      - name: cleanup
        image: busybox:1.37
        command: ["echo", "Cleanup complete"]
EOF
kubectl get job cleanup-job -w                    # COMPLETIONS 3/3
kubectl logs -l job-name=cleanup-job

cat <<'EOF' | kubectl apply -f -
apiVersion: batch/v1
kind: CronJob
metadata:
  name: hourly-backup
spec:
  schedule: "0 * * * *"
  successfulJobsHistoryLimit: 3
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          containers:
          - name: backup
            image: busybox:1.37
            command: ["sh", "-c", "echo \"Running backup-script.sh\"; date"]
EOF
kubectl get cronjob hourly-backup                 # LAST SCHEDULE / 다음 실행
kubectl create job manual-backup --from=cronjob/hourly-backup
kubectl logs job/manual-backup
```

</details>

### 랩 22 – PriorityClass  (워크로드와 스케줄링 | 보통 | 15분)

```bash
./lab.sh 22
```

```text
default 네임스페이스에서 작업하세요.

작업
1. value 1000, preemptionPolicy PreemptLowerPriority인 PriorityClass high-priority를 만드세요
2. value 10, preemptionPolicy Never인 PriorityClass low-priority를 만드세요
3. nginx:1.28을 쓰는 Pod critical-app을 만들고 high-priority 클래스를 지정하세요
4. busybox:1.37로 sleep 3600을 실행하는 Pod background-job을 만들고 low-priority 클래스를 지정하세요
5. 두 Pod가 모두 실행 중인지 확인하세요. 우선순위 값(priority와 priorityClassName)을 확인하세요
6. 선택: 노드를 drain해서 선점을 일으키고 어느 Pod가 축출되는지 관찰하세요
```

```bash
./lab.sh 22 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority
value: 1000
preemptionPolicy: PreemptLowerPriority
globalDefault: false
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: low-priority
value: 10
preemptionPolicy: Never
globalDefault: false
---
apiVersion: v1
kind: Pod
metadata:
  name: critical-app
spec:
  priorityClassName: high-priority
  containers:
  - name: nginx
    image: nginx:1.28
---
apiVersion: v1
kind: Pod
metadata:
  name: background-job
spec:
  priorityClassName: low-priority
  containers:
  - name: job
    image: busybox:1.37
    command: ["sleep", "3600"]
EOF
kubectl get priorityclass
kubectl get pod -o custom-columns=NAME:.metadata.name,CLASS:.spec.priorityClassName,PRIORITY:.spec.priority
```

</details>

### 랩 23 – 리소스 requests 조정 (Pod가 스케줄되지 않음)  (워크로드와 스케줄링 | 어려움 | 20분)

```bash
./lab.sh 23
```

```text
랩 셋업에서 exercise-23 네임스페이스와 Deployment web(레플리카 3개, nginx:1.27)을 만들었습니다.
이 Deployment의 리소스 requests는 일부러 클러스터에 비해 너무 높게 잡혀 있습니다.

작업
1. Pending 상태인 Pod를 관찰하세요 - 모두 스케줄되지는 않습니다
2. 원인을 찾으세요(Pending Pod를 describe)
3. 노드 용량과 사용 가능한 리소스(allocatable에서 이미 요청된 양을 뺀 값)를 확인하세요
4. 여유를 남기면서 레플리카 3개가 들어가도록 알맞은 리소스 requests를 계산하세요
5. 새(더 낮은) requests로 Deployment를 수정하세요 - cpu와 memory requests를 둘 다 설정한 상태로 유지하세요
6. Pod 3개가 모두 스케줄되어 실행되는지 확인하세요
7. 계산 과정을 /root/exercise-23-calculation.txt에 기록하세요
```

```bash
./lab.sh 23 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl get pods -n exercise-23                         # 일부 Pending
kubectl describe pod -n exercise-23 <pending-pod>       # 0/2 nodes available: Insufficient cpu
kubectl describe nodes | grep -A8 -E "Allocatable|Allocated resources"
# 예: node01 allocatable cpu 1000m, 이미 요청된 양 250m -> 여유 750m
#     노드 전체에 Pod 3개, 약 20% 여유 -> Pod당 CPU 150m-200m, memory 128Mi 정도
kubectl set resources deployment web -n exercise-23 --requests=cpu=150m,memory=128Mi
kubectl rollout status deployment web -n exercise-23
kubectl get pods -n exercise-23 -o wide                 # 3/3 Running
cat <<'EOF' > /root/exercise-23-calculation.txt
node allocatable cpu / memory, minus requests already allocated, divided by 3 replicas,
minus ~20% headroom -> requests cpu=150m memory=128Mi
EOF
```

</details>

### 랩 24 – PriorityClass와 patch 작업  (워크로드와 스케줄링 | 보통 | 15분)

```bash
./lab.sh 24
```

```text
작업
1. exercise-24 네임스페이스를 만드세요
2. 다음 조건으로 PriorityClass를 만드세요:
   - 이름: high-priority
   - 값: 999999
   - 설명: "Critical workload"
3. exercise-24에 Deployment critical-app을 만드세요:
   - 레플리카 1개, 이미지 busybox:1.36, 명령 sleep 3600
   - 아직 priorityClassName은 지정하지 마세요
4. kubectl patch로 Deployment에 priorityClassName: high-priority를 추가하세요
5. Pod에 우선순위 클래스가 지정되었는지 확인하세요
6. 우선순위가 더 낮은 두 번째 Deployment normal-app(busybox:1.36, sleep 3600, 우선순위 클래스 없음)을 만드세요
7. 두 Pod의 .spec.priority를 비교하세요
```

```bash
./lab.sh 24 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl create ns exercise-24
kubectl create priorityclass high-priority --value=999999 --description="Critical workload"
kubectl create deployment critical-app -n exercise-24 --image=busybox:1.36 --replicas=1 -- sleep 3600
kubectl patch deployment critical-app -n exercise-24 -p '{"spec":{"template":{"spec":{"priorityClassName":"high-priority"}}}}'
# JSON patch로 하는 방법:
# kubectl patch deployment critical-app -n exercise-24 --type=json -p='[{"op":"add","path":"/spec/template/spec/priorityClassName","value":"high-priority"}]'
kubectl rollout status deployment critical-app -n exercise-24
kubectl get pod -n exercise-24 -l app=critical-app -o jsonpath='{.items[0].spec.priorityClassName}'
kubectl create deployment normal-app -n exercise-24 --image=busybox:1.36 -- sleep 3600
kubectl get pod -n exercise-24 -o custom-columns=NAME:.metadata.name,CLASS:.spec.priorityClassName,PRIORITY:.spec.priority
```

</details>

### 랩 25 – WaitForFirstConsumer 바인딩 스토리지  (스토리지 | 어려움 | 20분)

```bash
./lab.sh 25
```

```text
랩 셋업에서 모든 노드에 /tmp/k8s-pv 디렉터리를 만들었습니다.

작업
1. exercise-25 네임스페이스를 만드세요
2. 다음 조건으로 StorageClass local-storage를 만드세요:
   - 프로비저너: kubernetes.io/no-provisioner (로컬 볼륨)
   - 바인딩 모드: WaitForFirstConsumer
3. 다음 조건으로 PersistentVolume local-pv-1을 만드세요:
   - 크기: 1Gi, AccessMode: ReadWriteOnce, StorageClassName: local-storage
   - 로컬 경로: /tmp/k8s-pv, node01로 nodeAffinity 지정
4. exercise-25에 PersistentVolumeClaim local-pvc(1Gi, storageClassName local-storage)를 만드세요
5. 관찰: PVC가 Pending 상태로 남습니다(Bound 아님) - 왜일까요?
6. PVC를 /data에 마운트하는 Pod app-pod(busybox:1.36, sleep 3600)를 만드세요
7. 관찰: PVC가 Bound가 되고 Pod가 PV가 있는 노드에 스케줄됩니다
8. Pod에서 /data/test.txt를 써서 데이터가 유지되는지 확인하세요
```

```bash
./lab.sh 25 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl create ns exercise-25
cat <<'EOF' | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: local-pv-1
spec:
  capacity:
    storage: 1Gi
  accessModes: ["ReadWriteOnce"]
  storageClassName: local-storage
  local:
    path: /tmp/k8s-pv
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values: ["node01"]
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: local-pvc
  namespace: exercise-25
spec:
  accessModes: ["ReadWriteOnce"]
  storageClassName: local-storage
  resources:
    requests:
      storage: 1Gi
EOF
kubectl get pvc -n exercise-25      # Pending - WaitForFirstConsumer는 Pod가 사용할 때까지 바인딩을 미룸
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
  namespace: exercise-25
spec:
  containers:
  - name: app
    image: busybox:1.36
    command: ["sleep", "3600"]
    volumeMounts:
    - name: data
      mountPath: /data
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: local-pvc
EOF
kubectl get pvc -n exercise-25 -w   # Bound
kubectl wait --for=condition=Ready pod/app-pod -n exercise-25
kubectl get pod app-pod -n exercise-25 -o wide    # node01에 배치됨
kubectl exec app-pod -n exercise-25 -- sh -c 'echo "test data" > /data/test.txt'
kubectl exec app-pod -n exercise-25 -- cat /data/test.txt
```

</details>

### 랩 26 – .deb 패키지로 CRI-dockerd 설치 + kubelet 전환  (클러스터 아키텍처 | 어려움 | 30분)

```bash
./lab.sh 26
```

```text
워커 노드에서 진행하세요:  ssh node01
랩 셋업에서 node01의 /root/cri-dockerd.deb에 패키지를 내려받아 두었습니다.

작업
1. node01에 SSH로 접속하세요
2. dpkg로 /root/cri-dockerd.deb에서 cri-dockerd를 설치하세요
3. cri-dockerd를 위해 시스템을 설정하세요(실제 시험 작업과 같음):
   - 커널 모듈 overlay, br_netfilter, nf_conntrack을 로드하세요
   - 다음 파라미터를 영구적으로(/etc/sysctl.d/에) 설정하고 적용하세요:
       net.bridge.bridge-nf-call-iptables = 1
       net.ipv6.conf.all.forwarding       = 1
       net.ipv4.ip_forward                = 1
       net.netfilter.nf_conntrack_max     = 131072
4. cri-docker 서비스와 소켓을 활성화하고 시작하세요
   (systemd 유닛 이름은 cri-docker.service / cri-docker.socket)
5. cri-dockerd 소켓 /run/cri-dockerd.sock을 사용할 수 있는지 확인하세요
6. node01의 kubelet이 cri-dockerd(unix:///run/cri-dockerd.sock)를 쓰도록 설정하세요
7. kubelet을 재시작하고 node01이 Ready이며 컨테이너 런타임이 docker://로 표시되는지 확인하세요

./lab.sh 26 cleanup 은 node01을 다시 containerd로 되돌립니다.
```

```bash
./lab.sh 26 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
ssh node01
dpkg -i /root/cri-dockerd.deb             # docker 필요: 오류가 나면 apt-get install -y docker.io
modprobe overlay && modprobe br_netfilter && modprobe nf_conntrack
printf "overlay\nbr_netfilter\nnf_conntrack\n" > /etc/modules-load.d/k8s.conf
cat <<'EOF' > /etc/sysctl.d/kube.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv6.conf.all.forwarding = 1
net.ipv4.ip_forward = 1
net.netfilter.nf_conntrack_max = 131072
EOF
sysctl --system
sysctl net.bridge.bridge-nf-call-iptables net.ipv6.conf.all.forwarding net.ipv4.ip_forward net.netfilter.nf_conntrack_max
systemctl enable --now cri-docker.socket cri-docker.service
systemctl status cri-docker --no-pager
ls -la /run/cri-dockerd.sock

# kubelet 전환 (kubeadm은 런타임 플래그를 여기에 저장한다):
cat /var/lib/kubelet/kubeadm-flags.env
systemctl stop kubelet
crictl --runtime-endpoint unix:///run/containerd/containerd.sock rmp -fa   # 기존 containerd Pod 중지 (포트 충돌 방지)
sed -i 's#--container-runtime-endpoint=[^ "]*#--container-runtime-endpoint=unix:///run/cri-dockerd.sock#' /var/lib/kubelet/kubeadm-flags.env
cat /var/lib/kubelet/kubeadm-flags.env
systemctl daemon-reload && systemctl restart kubelet
exit
kubectl get nodes -o wide                  # node01 Ready, CONTAINER-RUNTIME docker://...
# node01의 Pod가 IP를 받지 못하면: /lib/systemd/system/cri-docker.service의 ExecStart에
# --network-plugin=cni를 추가한 뒤 daemon-reload + cri-docker 재시작.
```

</details>

### 랩 27 – CNI 설치 (Tigera Operator로 Calico 설치)  (서비스와 네트워킹 | 어려움 | 30분)

```bash
./lab.sh 27
```

```text
랩 셋업에서 클러스터의 CNI를 제거했습니다. 실제 시험 문제처럼, 요구 사항을 충족하는 CNI(Container Network Interface)를
직접 골라 설치하고 구성하세요. 다음 중 하나를 고르세요.
  Flannel v0.26.1  https://github.com/flannel-io/flannel/releases/download/v0.26.1/kube-flannel.yml
  Calico v3.30.3   https://raw.githubusercontent.com/projectcalico/calico/v3.30.3/manifests/tigera-operator.yaml
                   https://raw.githubusercontent.com/projectcalico/calico/v3.30.3/manifests/custom-resources.yaml
선택한 CNI는 다음을 만족해야 합니다.
  - Pod 간 통신이 가능할 것
  - NetworkPolicy 적용(enforcement)을 지원할 것
  - 매니페스트 파일로 설치할 것 (Helm 사용 금지)

작업
1. 두 CNI 중 모든 요구 사항을 충족하는 것을 정하세요 (채점기는 그 CNI를 기대합니다)
2. 클러스터 Pod CIDR(kube-controller-manager --cluster-cidr)을 찾으세요
3. 매니페스트로 Tigera operator를 설치하고 operator Deployment가 준비될 때까지 기다리세요
4. Calico Installation 커스텀 리소스를 만드세요:
   - IP 풀 CIDR을 클러스터 CIDR과 같게 설정하세요
   - VXLAN(또는 VXLANCrossSubnet) 캡슐화를 쓰세요
5. calico-system Pod가 Ready가 되고 노드가 Ready가 될 때까지 기다리세요
6. CNI 변경 전에 만들어진 Pod(예: CoreDNS)를 재시작해서 새 IP를 받게 하세요
7. 서로 다른 노드의 Pod끼리 통신되는지 확인하세요
8. NetworkPolicy 차단이 동작하는지 테스트하세요
```

```bash
./lab.sh 27 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
# Flannel은 NetworkPolicy를 적용하지 못하므로, 둘 중 요구 사항을 충족하는 것은 Calico뿐이다.
kubectl -n kube-system get pod -l component=kube-controller-manager -o yaml | grep cluster-cidr
# 또는: kubectl get cm kubeadm-config -n kube-system -o yaml | grep -i podSubnet
CIDR=<the value above, e.g. 192.168.0.0/16>
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.30.3/manifests/tigera-operator.yaml
kubectl wait --for=condition=Available deploy/tigera-operator -n tigera-operator --timeout=300s
cat <<EOF | kubectl create -f -
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
spec:
  calicoNetwork:
    ipPools:
    - name: default-ipv4-ippool
      blockSize: 26
      cidr: $CIDR
      encapsulation: VXLANCrossSubnet
      natOutgoing: Enabled
      nodeSelector: all()
---
apiVersion: operator.tigera.io/v1
kind: APIServer
metadata:
  name: default
spec: {}
EOF
watch kubectl get tigerastatus                # calico Available True
kubectl get pods -n calico-system
kubectl get nodes                             # Ready
kubectl -n kube-system rollout restart deploy coredns
# 노드 간 Pod 트래픽 테스트
kubectl run a --image=busybox:1.36 --overrides='{"spec":{"nodeName":"controlplane","tolerations":[{"operator":"Exists"}]}}' -- sleep 3600
kubectl run b --image=busybox:1.36 --overrides='{"spec":{"nodeName":"node01"}}' -- sleep 3600
kubectl exec a -- ping -c2 $(kubectl get pod b -o jsonpath='{.status.podIP}')
# NetworkPolicy 테스트: b로 들어오는 ingress를 모두 막고 다시 ping -> 실패
cat <<'EOF' | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-b
spec:
  podSelector:
    matchLabels:
      run: b
  policyTypes: [Ingress]
EOF
kubectl exec a -- ping -c2 -W2 $(kubectl get pod b -o jsonpath='{.status.podIP}')   # 실패
kubectl delete netpol deny-b; kubectl delete pod a b --now
```

</details>

### 랩 28 – 복잡한 NetworkPolicy (다중 네임스페이스)  (서비스와 네트워킹 | 어려움 | 25분)

```bash
./lab.sh 28
```

```text
랩 셋업에서 앱이 하나씩 있는 네임스페이스 3개를 만들었습니다(1~2단계는 완료됨):
  frontend : Deployment/Service frontend (nginx, 포트 80),   Pod 레이블 tier=frontend
  backend  : Deployment/Service backend  (8080에서 HTTP),    Pod 레이블 tier=backend
  database : Deployment/Service database (redis, 포트 6379), Pod 레이블 tier=database

작업
3. 다음 조건을 만족하는 NetworkPolicy를 만드세요:
   - 세 네임스페이스 모두 기본적으로 전부 거부(ingress와 egress 모두)
   - frontend -> backend는 TCP 8080으로만 허용
   - backend -> database는 TCP 6379로만 허용
   - DNS(kube-system의 kube-dns로 가는 UDP/TCP 53)는 모든 Pod에 허용
4. 정책이 적용되는지 연결을 직접 테스트하세요:
   - frontend는 backend 8080에 접근할 수 있어야 함
   - frontend는 database에 접근할 수 없어야 함
   - backend는 database 6379에 접근할 수 있어야 함
   - backend는 frontend에 접근할 수 없어야 함
   - default 네임스페이스의 Pod는 backend에 접근할 수 없어야 함
5. 모든 네임스페이스에서 DNS가 여전히 동작하는지 확인하세요
6. 정책이 적용되지 않으면 CNI가 NetworkPolicy를 지원하는지 확인하세요
```

```bash
./lab.sh 28 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
# 모든 네임스페이스에 기본 거부 + DNS 허용
for ns in frontend backend database; do
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: $ns
spec:
  podSelector: {}
  policyTypes: [Ingress, Egress]
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns
  namespace: $ns
spec:
  podSelector: {}
  policyTypes: [Egress]
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: kube-system
      podSelector:
        matchLabels:
          k8s-app: kube-dns
    ports:
    - {protocol: UDP, port: 53}
    - {protocol: TCP, port: 53}
EOF
done

cat <<'EOF' | kubectl apply -f -
# frontend는 backend:8080으로 보낼 수 있음
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: frontend-egress-to-backend
  namespace: frontend
spec:
  podSelector:
    matchLabels: {tier: frontend}
  policyTypes: [Egress]
  egress:
  - to:
    - namespaceSelector:
        matchLabels: {kubernetes.io/metadata.name: backend}
      podSelector:
        matchLabels: {tier: backend}
    ports: [{protocol: TCP, port: 8080}]
---
# backend는 frontend에서 오는 8080을 받음
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-ingress-from-frontend
  namespace: backend
spec:
  podSelector:
    matchLabels: {tier: backend}
  policyTypes: [Ingress]
  ingress:
  - from:
    - namespaceSelector:
        matchLabels: {kubernetes.io/metadata.name: frontend}
      podSelector:
        matchLabels: {tier: frontend}
    ports: [{protocol: TCP, port: 8080}]
---
# backend는 database:6379로 보낼 수 있음
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-egress-to-database
  namespace: backend
spec:
  podSelector:
    matchLabels: {tier: backend}
  policyTypes: [Egress]
  egress:
  - to:
    - namespaceSelector:
        matchLabels: {kubernetes.io/metadata.name: database}
      podSelector:
        matchLabels: {tier: database}
    ports: [{protocol: TCP, port: 6379}]
---
# database는 backend에서 오는 6379를 받음
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: database-ingress-from-backend
  namespace: database
spec:
  podSelector:
    matchLabels: {tier: database}
  policyTypes: [Ingress]
  ingress:
  - from:
    - namespaceSelector:
        matchLabels: {kubernetes.io/metadata.name: backend}
      podSelector:
        matchLabels: {tier: backend}
    ports: [{protocol: TCP, port: 6379}]
EOF

# 테스트
kubectl exec -n frontend deploy/frontend -- curl -s -m3 http://backend.backend.svc.cluster.local:8080          # backend-ok
kubectl exec -n frontend deploy/frontend -- timeout 3 bash -c '</dev/tcp/database.database.svc.cluster.local/6379' || echo blocked
kubectl exec -n backend deploy/backend -- sh -c 'echo PING | nc -w 3 database.database.svc.cluster.local 6379'   # +PONG
kubectl exec -n backend deploy/backend -- wget -q -T 3 -O- http://frontend.frontend.svc.cluster.local || echo blocked
kubectl run outsider --image=busybox:1.36 --rm -it --restart=Never -- wget -q -T 3 -O- http://backend.backend.svc.cluster.local:8080   # 차단됨
kubectl exec -n backend deploy/backend -- nslookup kubernetes.default.svc.cluster.local                         # DNS 동작
```

</details>

### 랩 29 – 고장 난 클러스터 트러블슈팅 (잘못된 etcd 엔드포인트)  (트러블슈팅 | 어려움 | 20분)

```bash
./lab.sh 29
```

```text
클러스터가 고장 났습니다: API 서버가 시작되지 않습니다(kubectl이 동작하지 않음).

작업
1. API 서버가 내려가 있는지 확인하세요
2. kube-apiserver 컨테이너 로그를 확인하세요(kubectl은 쓸 수 없으니 crictl이나 /var/log/pods를 사용)
3. 오류를 찾으세요: 잘못된 etcd 엔드포인트 IP 또는 포트
4. 컨트롤 플레인 노드에서 /etc/kubernetes/manifests/kube-apiserver.yaml을 편집하세요
5. --etcd-servers= 플래그의 etcd 엔드포인트를 바로잡으세요
6. IP/포트가 /etc/kubernetes/manifests/etcd.yaml의 client URL과 일치하는지 확인하세요
7. 저장하고 API 서버가 재시작될 때까지 기다리세요
8. 클러스터가 정상인지 확인하세요: kubectl get nodes, kubectl get pods -A, API 서버 Running

/etc/kubernetes/manifests 안에 백업 사본을 두지 마세요 - kubelet은 그 안의 모든 파일을 실행합니다.
```

```bash
./lab.sh 29 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl get nodes                                           # connection refused
crictl ps -a | grep kube-apiserver                          # Exited / 재시작 반복
crictl logs $(crictl ps -a --name kube-apiserver -q | head -1) 2>&1 | tail -20
#   ... dial tcp 10.0.0.5:2379: connect: connection refused / i/o timeout
ls /var/log/pods/ | grep apiserver                          # 다른 로그 위치
grep etcd-servers /etc/kubernetes/manifests/kube-apiserver.yaml
grep -E "listen-client-urls|advertise-client-urls" /etc/kubernetes/manifests/etcd.yaml
#   --listen-client-urls=https://127.0.0.1:2379,https://<node-ip>:2379
sed -i 's#--etcd-servers=.*#--etcd-servers=https://127.0.0.1:2379#' /etc/kubernetes/manifests/kube-apiserver.yaml
watch crictl ps --name kube-apiserver                       # 약 30-60초 후 Running
kubectl get nodes
kubectl get pods -A
```

</details>

### 랩 30 – TLS 설정 변경  (보안 | 어려움 | 20분)

```bash
./lab.sh 30
```

```text
랩 셋업에서 exercise-30 네임스페이스에 다음을 만들었습니다:
  Deployment tls-web (nginx) - Service tls-web (포트 443) - ConfigMap tls-config (nginx.conf) - Secret tls-web-cert
현재 서비스는 TLS 1.3만 지원합니다.

작업
1. Deployment에 마운트된 ConfigMap에서 TLS 설정을 찾으세요
2. TLS 1.2 지원을 추가하세요(TLSv1.2와 TLSv1.3이 모두 활성화되어야 함)
3. 새 설정이 쓰이도록 Deployment를 재시작하세요
4. 서비스가 TLS 1.2 연결을 받는지 확인하세요:
     curl -vk --tlsv1.2 --tls-max 1.2 https://<service-ip>
     또는: echo | openssl s_client -connect <service-ip>:443 -tls1_2
5. TLS 1.3도 여전히 동작하는지 확인하세요:  curl -vk --tlsv1.3 https://<service-ip>
```

```bash
./lab.sh 30 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl get deploy,svc,cm -n exercise-30
kubectl get cm tls-config -n exercise-30 -o yaml | grep ssl_protocols     # TLSv1.3만
kubectl edit cm tls-config -n exercise-30        # ssl_protocols TLSv1.2 TLSv1.3;
# 또는 한 줄로:
kubectl get cm tls-config -n exercise-30 -o yaml | sed 's/ssl_protocols TLSv1.3;/ssl_protocols TLSv1.2 TLSv1.3;/' | kubectl replace -f -
kubectl rollout restart deploy tls-web -n exercise-30      # subPath 마운트는 자동 갱신되지 않음
kubectl rollout status deploy tls-web -n exercise-30
IP=$(kubectl get svc tls-web -n exercise-30 -o jsonpath='{.spec.clusterIP}')
curl -sk --tlsv1.2 --tls-max 1.2 https://$IP          # Hello TLS
echo | openssl s_client -connect $IP:443 -tls1_2 2>/dev/null | grep Protocol
curl -sk --tlsv1.3 https://$IP                        # Hello TLS
```

</details>

### 랩 31 – Argo CD 셋업 (GitOps 배포)  (클러스터 아키텍처 | 어려움 | 25분)

```bash
./lab.sh 31
```

```text
작업
1. 클러스터에 Argo CD v3.1.9를 설치하세요:
   - argocd 네임스페이스를 만드세요
   - 공식 매니페스트를 적용하세요 (CRD가 포함되어 있으니 server-side apply로 한 번만 설치하세요):
     https://raw.githubusercontent.com/argoproj/argo-cd/v3.1.9/manifests/install.yaml
2. Application 매니페스트를 작성해 /root/argocd-app.yaml 에 저장하세요:
   - 이름 my-app, 네임스페이스 argocd, 프로젝트 default
   - source: https://github.com/argoproj/argocd-example-apps.git, revision HEAD, path guestbook
   - destination: https://kubernetes.default.svc, 네임스페이스 default
   - 자동 동기화 (prune + selfHeal)
3. Argo CD 서버가 Running인지 확인하세요
4. Application 매니페스트를 적용하세요
5. 애플리케이션이 동기화되고(상태 Synced) default에 guestbook-ui Deployment가 생기는지 확인하세요
6. 선택: Argo CD UI로 port-forward 해서 admin으로 로그인하세요
```

```bash
./lab.sh 31 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl create namespace argocd
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/v3.1.9/manifests/install.yaml
kubectl wait --for=condition=Available deploy --all -n argocd --timeout=600s
kubectl get pods -n argocd
cat <<'EOF' > /root/argocd-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/argoproj/argocd-example-apps.git
    targetRevision: HEAD
    path: guestbook
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF
kubectl apply -f /root/argocd-app.yaml
kubectl get application -n argocd -w          # SYNC STATUS Synced, HEALTH Healthy
kubectl get deploy,svc guestbook-ui
# UI (선택)
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 -d; echo
kubectl port-forward -n argocd svc/argocd-server 8080:443 --address 0.0.0.0
# 시험 변형 (다른 랩): CRD가 미리 설치되어 있으면 helm template ... --set crds.install=false
```

</details>

### 랩 32 – 사용자 인증서(CSR) + Role  (클러스터 아키텍처 | 보통 | 15분)

```bash
./lab.sh 32
```

```text
랩 셋업에서 사용자 john의 개인 키와 인증서 서명 요청을 만들어 두었습니다:
  /root/exercise-32/john.key   /root/exercise-32/john.csr

작업
1. /root/exercise-32/john.csr 로 john-developer 라는 CertificateSigningRequest를 만들고
   (signer kubernetes.io/kube-apiserver-client, usage client auth) 승인하세요
2. exercise-32 네임스페이스에 pods에 대해 create, list, get, update, delete를 허용하는
   developer 라는 Role을 만드세요
3. 사용자 john에게 이 Role을 부여하는 developer-role-binding 이라는 RoleBinding을 만드세요
4. kubectl auth can-i ... --as=john 으로 확인하세요
```

```bash
./lab.sh 32 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
cat <<EOF2 | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: john-developer
spec:
  request: $(base64 -w0 /root/exercise-32/john.csr)
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF2
kubectl get csr john-developer                       # Pending
kubectl certificate approve john-developer
kubectl get csr john-developer                       # Approved,Issued
kubectl create role developer -n exercise-32 --verb=create,list,get,update,delete --resource=pods
kubectl create rolebinding developer-role-binding -n exercise-32 --role=developer --user=john
kubectl auth can-i create pods -n exercise-32 --as=john   # yes
kubectl auth can-i create pods -n default --as=john       # no
# 참고: 발급된 인증서는 kubectl get csr john-developer -o jsonpath='{.status.certificate}' | base64 -d
#       request 는 줄바꿈 없는 base64 한 줄이어야 한다 (base64 -w0 또는 | tr -d '\n').
```

</details>

### 랩 33 – Helm으로 Argo CD 설치 (template + install, CRD 제외)  (클러스터 아키텍처 | 보통 | 15분)

```bash
./lab.sh 33
```

```text
(원본 시험 문제 · 한글 문제집 7번)

Argo CD CRD는 이미 클러스터에 설치되어 있습니다.

작업
1. 공식 Argo CD Helm 저장소를 argo 라는 이름으로 추가하세요:
     https://argoproj.github.io/argo-helm
2. Argo CD 차트(argo/argo-cd) 버전 8.6.4의 helm template을 네임스페이스 argocd 용으로 생성해
   /root/argo-helm.yaml 에 저장하세요. 차트가 CRD를 설치하지 않도록 설정하세요.
3. Helm으로 Argo CD를 설치하세요: 릴리스 이름 argocd, template과 같은 차트 버전과 설정,
   네임스페이스 argocd, 차트가 CRD를 설치하지 않도록
4. Argo CD 서버 UI 접근은 설정하지 않아도 됩니다

Argo CD는 RAM이 약 1.5 GB 필요합니다. 랩 31도 argocd 네임스페이스를 쓰므로 두 랩의 셋업은 서로를 정리합니다.
```

```bash
./lab.sh 33 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm search repo argo/argo-cd --versions | grep 8.6.4
helm show values argo/argo-cd --version 8.6.4 | grep -A3 '^crds:'     # 기본값 crds.install: true
helm template argocd argo/argo-cd --version 8.6.4 --namespace argocd \
  --set crds.install=false > /root/argo-helm.yaml
grep -c 'kind: CustomResourceDefinition' /root/argo-helm.yaml          # 0
helm install argocd argo/argo-cd --version 8.6.4 --namespace argocd --create-namespace \
  --set crds.install=false
helm list -n argocd                                                    # argo-cd-8.6.4 deployed
kubectl get pods -n argocd
# 참고: 이미 설치된 CRD를 차트가 다시 만들려고 하면 소유권 충돌이 난다. 그래서 crds.install=false.
```

</details>

### 랩 34 – Kustomize 오버레이: 네임스페이스, 접두사, 레플리카, 이미지  (클러스터 아키텍처 | 보통 | 15분)

```bash
./lab.sh 34
```

```text
/root/kustomize/base 에는 Deployment web (nginx:1.26, 레플리카 1개)과 Service web이 정의되어 있습니다.
base는 바꾸지 마세요. 다음을 하는 오버레이 /root/kustomize/overlays/prod 를 만드세요:
  - 모든 리소스를 네임스페이스 exercise-34 에 배포
  - 모든 리소스 이름에 접두사 prod- 추가
  - Deployment 레플리카 3개로 실행
  - nginx 이미지 태그 1.27 사용
그다음 오버레이를 클러스터에 배포하세요.
```

```bash
./lab.sh 34 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
mkdir -p /root/kustomize/overlays/prod
cat <<'EOF2' > /root/kustomize/overlays/prod/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../../base
namespace: exercise-34
namePrefix: prod-
replicas:
- name: web          # 접두사가 붙기 전 이름
  count: 3
images:
- name: nginx
  newTag: "1.27"
EOF2
kubectl kustomize /root/kustomize/overlays/prod        # 미리 보기
kubectl create namespace exercise-34                   # "namespace:"는 네임스페이스를 만들지 않음
kubectl apply -k /root/kustomize/overlays/prod
kubectl -n exercise-34 get deploy,svc,pods
# 참고: 위 항목으로 못 바꾸는 필드는 patches 로 (target: kind/name + JSON patch 또는 strategic merge).
```

</details>

### 랩 35 – CRD: 목록과 explain  (클러스터 아키텍처 | 쉬움 | 10분)

```bash
./lab.sh 35
```

```text
(원본 시험 문제 · 한글 문제집 10번)

클러스터에 cert-manager가 배포되어 있습니다 (네임스페이스 cert-manager).

작업
1. cert-manager 애플리케이션을 확인하세요
2. cert-manager의 모든 Custom Resource Definition(CRD) 목록을 만들어
   /root/resources.yaml 에 저장하세요. kubectl의 기본 출력 형식을 쓰고, 출력 형식(-o)은 지정하지 마세요.
3. kubectl로 Certificate 커스텀 리소스의 subject spec 필드 문서를 추출해
   /root/subject.yaml 에 저장하세요
   (여기서는 kubectl이 지원하는 어떤 출력 형식이든 괜찮습니다)
```

```bash
./lab.sh 35 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl get pods -n cert-manager
kubectl get crd | grep cert-manager > /root/resources.yaml       # -o 쓰지 않기!
cat /root/resources.yaml
kubectl explain certificate.spec.subject > /root/subject.yaml
cat /root/subject.yaml
# 참고: 화면에도 보면서 저장하려면 | tee /root/resources.yaml
#       CRD는 보통 오퍼레이터와 같이 설치된다: 오퍼레이터가 CR(Certificate 등)을 읽어 동작한다.
```

</details>

### 랩 36 – 볼륨으로 마운트한 Secret  (워크로드와 스케줄링 | 쉬움 | 10분)

```bash
./lab.sh 36
```

```text
네임스페이스 exercise-36 에 Secret dotfile-secret 이 있습니다.
네임스페이스 exercise-36 에 secret-1401 이라는 Pod를 만드세요:
  - 이미지 busybox, 명령: sleep 4800
  - 컨테이너 이름은 secret-admin (Pod 이름이 아님!)
  - Secret dotfile-secret 을 secret-volume 이라는 볼륨으로 /etc/secret-volume 에 읽기 전용으로 마운트
```

```bash
./lab.sh 36 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl -n exercise-36 get secret dotfile-secret
kubectl run secret-1401 -n exercise-36 --image=busybox --dry-run=client -o yaml --command -- sleep 4800 > secret-1401.yaml
# 수정: 컨테이너 이름 secret-admin, 볼륨과 마운트 추가. 완성된 파일:
cat <<'EOF2' > secret-1401.yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-1401
  namespace: exercise-36
spec:
  volumes:
  - name: secret-volume
    secret:
      secretName: dotfile-secret
  containers:
  - name: secret-admin
    image: busybox
    command: ["sleep", "4800"]
    volumeMounts:
    - name: secret-volume
      mountPath: /etc/secret-volume
      readOnly: true
EOF2
kubectl apply -f secret-1401.yaml
kubectl -n exercise-36 exec secret-1401 -c secret-admin -- ls -a /etc/secret-volume   # .secret-file
# 참고: 이름이 점(.)으로 시작하는 파일은 ls -a 로만 보인다. --command 뒤 인자는 명령 맨 끝에 둔다.
```

</details>

### 랩 37 – 스케일 다운 안정화 윈도우가 있는 HPA  (워크로드와 스케줄링 | 보통 | 10분)

```bash
./lab.sh 37
```

```text
(원본 시험 문제 · 한글 문제집 14번)

랩 셋업에서 metrics-server를 설치하고 네임스페이스 exercise-37 에 Deployment apache-server 를 만들어 두었습니다.

기존 Deployment apache-server 를 대상으로 하는 새 HorizontalPodAutoscaler apache-server 를
네임스페이스 exercise-37 에 만드세요:
  - Pod당 CPU 사용률 목표 50%
  - Pod 최소 1개, 최대 4개
  - 스케일 다운 안정화 윈도우 30초
```

```bash
./lab.sh 37 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
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
# 다른 방법: kubectl -n exercise-37 autoscale deployment apache-server --name=apache-server --cpu=50% --min=1 --max=4
#            후 kubectl -n exercise-37 edit hpa apache-server 로 behavior 블록 추가
# 참고: kubectl 1.37(시험 버전)은 --cpu=50% 형식을 쓴다. 예전 --cpu-percent=50 은 deprecated 라 경고가 나온다 (kubectl autoscale -h 로 확인).
```

</details>

### 랩 38 – liveness·readiness 프로브  (워크로드와 스케줄링 | 쉬움 | 10분)

```bash
./lab.sh 38
```

```text
네임스페이스 exercise-38 에 Deployment probe-web (이미지 nginx, 레플리카 2개)을 만들고 컨테이너에 다음을 넣으세요:
  - readinessProbe: 포트 80에 HTTP GET /, initialDelaySeconds 5, periodSeconds 5
  - livenessProbe:  포트 80에 HTTP GET /, initialDelaySeconds 10, periodSeconds 10, failureThreshold 3
Pod 하나를 지우고 Deployment가 스스로 레플리카 수를 2로 되돌리는지 확인하세요.
```

```bash
./lab.sh 38 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl create deployment probe-web -n exercise-38 --image=nginx --replicas=2 --port=80 --dry-run=client -o yaml > probe-web.yaml
# 컨테이너 아래에 프로브 추가. 완성된 containers 부분:
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
kubectl -n exercise-38 get pods -l app=probe-web          # 새 Pod가 대신 생성됨
# 참고: 시작이 느린 앱은 startupProbe 로 liveness 를 늦춘다.
```

</details>

### 랩 39 – taint와 toleration  (워크로드와 스케줄링 | 쉬움 | 10분)

```bash
./lab.sh 39
```

```text
1. node01에 taint를 추가하세요: 키 env_type, 값 production, effect NoSchedule
2. 네임스페이스 exercise-39 에 이 taint를 허용하는 Pod prod-redis (이미지 redis:alpine)를 만드세요

./lab.sh 39 cleanup 이 taint를 다시 제거합니다. 다른 랩에서는 node01에 스케줄링이 가능해야 합니다.
```

```bash
./lab.sh 39 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl taint nodes node01 env_type=production:NoSchedule
kubectl describe node node01 | grep -i taint
kubectl run prod-redis -n exercise-39 --image=redis:alpine --dry-run=client -o yaml > prod-redis.yaml
# spec 아래에 추가:
#   tolerations:
#   - key: "env_type"
#     operator: "Equal"
#     value: "production"
#     effect: "NoSchedule"
kubectl apply -f prod-redis.yaml
kubectl get pod prod-redis -n exercise-39 -o wide
# 참고: effect 종류 - NoSchedule(새 Pod 금지), PreferNoSchedule(가급적 피함), NoExecute(실행 중인 Pod도 축출).
#       특정 노드에 꼭 보내려면 nodeSelector/nodeAffinity 를 같이 쓴다. taint 제거: kubectl taint nodes node01 env_type-
```

</details>

### 랩 40 – node affinity (required + preferred)  (워크로드와 스케줄링 | 보통 | 10분)

```bash
./lab.sh 40
```

```text
1. node01에 레이블 disktype=ssd 를 추가하세요
2. 네임스페이스 exercise-40 에 다음 조건의 Pod affinity-pod (이미지 nginx)를 만드세요
   - 레이블 disktype=ssd 가 있는 노드에만 스케줄링 (required node affinity)
   - 레이블 zone=a 가 있는 노드를 선호 (preferred node affinity, weight 50)

./lab.sh 40 cleanup 이 레이블을 다시 제거합니다.
```

```bash
./lab.sh 40 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl label node node01 disktype=ssd
kubectl get nodes -L disktype
cat <<'EOF2' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: affinity-pod
  namespace: exercise-40
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: disktype
            operator: In
            values: ["ssd"]
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 50
        preference:
          matchExpressions:
          - key: zone
            operator: In
            values: ["a"]
  containers:
  - name: nginx
    image: nginx
EOF2
kubectl get pod affinity-pod -n exercise-40 -o wide        # node01에 배치됨
# 참고: nodeSelectorTerms 항목 여러 개 = OR, 한 항목 안의 matchExpressions 여러 개 = AND.
#       Pending 이면 describe 의 Events 에서 "didn't match Pod's node affinity" 확인.
```

</details>

### 랩 41 – LoadBalancer 유형 Service  (서비스와 네트워킹 | 쉬움 | 10분)

```bash
./lab.sh 41
```

```text
네임스페이스 exercise-41 에서:
1. Deployment lb-web (이미지 nginx, 레플리카 2개)을 만드세요
2. LoadBalancer 유형의 Service lb-web-svc 로 포트 80에 노출하세요
3. Service의 엔드포인트에 두 Pod가 모두 있고 NodePort로 응답하는지 확인하세요

Killercoda에는 클라우드 로드 밸런서가 없으므로 EXTERNAL-IP는 <pending> 으로 남습니다. 정상입니다.
```

```bash
./lab.sh 41 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl create deployment lb-web -n exercise-41 --image=nginx --replicas=2 --port=80
kubectl expose deployment lb-web -n exercise-41 --name=lb-web-svc --type=LoadBalancer --port=80 --target-port=80
kubectl get svc lb-web-svc -n exercise-41                       # 80:3xxxx/TCP, EXTERNAL-IP <pending>
kubectl get endpointslices -n exercise-41 -l kubernetes.io/service-name=lb-web-svc
NP=$(kubectl get svc lb-web-svc -n exercise-41 -o jsonpath='{.spec.ports[0].nodePort}')
curl -s http://node01:$NP | grep title
# 참고: Endpoints API 는 v1.33 부터 deprecated - EndpointSlice 로 본다 (kubectl get endpoints 도 경고와 함께 동작).
#       Service 유형: ClusterIP(기본, 내부) ⊂ NodePort(30000-32767) ⊂ LoadBalancer.
```

</details>

### 랩 42 – Ingress(TLS 포함)를 Gateway API로 이전  (서비스와 네트워킹 | 어려움 | 20분)

```bash
./lab.sh 42
```

```text
(원본 시험 문제 · 한글 문제집 23번)
실제 시험의 GatewayClass 이름은 nginx였지만, 이 랩은 Envoy Gateway의 eg를 씁니다.

네임스페이스 exercise-42 에서 Ingress web (TLS, 호스트 web.k8s.local)으로 노출된 웹 애플리케이션이 실행 중입니다.
GatewayClass eg 가 설치되어 있습니다. 애플리케이션을 Ingress에서 Gateway API로 옮기세요.
HTTPS 접속은 계속 동작해야 합니다.

1. 호스트 이름 gateway.web.k8s.local 을 쓰고, 기존 Ingress web 의 TLS와 리스너 설정을 유지하는
   Gateway web-gateway 를 만드세요
2. 호스트 이름 gateway.web.k8s.local 을 쓰고, 기존 Ingress web 의 라우팅 규칙을 유지하는
   HTTPRoute web-route 를 만드세요
3. 테스트하세요 (Envoy 프록시는 envoy-gateway-system 의 NodePort Service입니다). 예:
     curl -k --resolve gateway.web.k8s.local:<nodeport>:<node-ip> https://gateway.web.k8s.local:<nodeport>
4. 마지막으로 Ingress web 을 삭제하세요
```

```bash
./lab.sh 42 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl -n exercise-42 get ingress web -o yaml       # tls.secretName web-tls, rule / -> web:80
kubectl get gatewayclass                              # eg
cat <<'EOF2' | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: web-gateway
  namespace: exercise-42
spec:
  gatewayClassName: eg
  listeners:
  - name: https
    protocol: HTTPS
    port: 443
    hostname: gateway.web.k8s.local
    tls:
      mode: Terminate
      certificateRefs:
      - kind: Secret
        name: web-tls
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: web-route
  namespace: exercise-42
spec:
  parentRefs:
  - name: web-gateway
  hostnames:
  - gateway.web.k8s.local
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: web
      port: 80
EOF2
kubectl -n exercise-42 get gateway,httproute         # PROGRAMMED True
SVC=$(kubectl get svc -n envoy-gateway-system -l gateway.envoyproxy.io/owning-gateway-name=web-gateway -o jsonpath='{.items[0].metadata.name}')
NP=$(kubectl get svc $SVC -n envoy-gateway-system -o jsonpath='{.spec.ports[?(@.port==443)].nodePort}')
IP=$(kubectl get node node01 -o jsonpath='{.status.addresses[?(@.type=="InternalIP")].address}')
curl -k --resolve gateway.web.k8s.local:$NP:$IP https://gateway.web.k8s.local:$NP
kubectl -n exercise-42 delete ingress web
# 참고: 문법이 기억나지 않으면 kubectl explain gateway.spec.listeners.tls
```

</details>

### 랩 43 – Service와 Pod의 DNS 레코드  (서비스와 네트워킹 | 쉬움 | 10분)

```bash
./lab.sh 43
```

```text
네임스페이스 exercise-43 에서:
1. Pod nginx-resolver (이미지 nginx)를 만들고 포트 80의 ClusterIP Service
   nginx-resolver-service 로 노출하세요
2. 이미지 busybox:1.28 의 임시 Pod에서 nslookup으로 Service와 Pod를 조회하고
   출력을 /root/CKA/nginx.svc 와 /root/CKA/nginx.pod 에 저장하세요
```

```bash
./lab.sh 43 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl run nginx-resolver -n exercise-43 --image=nginx
kubectl expose pod nginx-resolver -n exercise-43 --name=nginx-resolver-service --port=80 --target-port=80
kubectl run test-nslookup -n exercise-43 --image=busybox:1.28 --rm -it --restart=Never \
  -- nslookup nginx-resolver-service.exercise-43.svc.cluster.local > /root/CKA/nginx.svc
IP=$(kubectl get pod nginx-resolver -n exercise-43 -o jsonpath='{.status.podIP}'); echo $IP
kubectl run test-nslookup -n exercise-43 --image=busybox:1.28 --rm -it --restart=Never \
  -- nslookup ${IP//./-}.exercise-43.pod.cluster.local > /root/CKA/nginx.pod
cat /root/CKA/nginx.svc /root/CKA/nginx.pod
# 참고: 클러스터 DNS = kube-system 의 CoreDNS Deployment(라벨 k8s-app=kube-dns) + Service kube-dns,
#       설정은 ConfigMap coredns 의 Corefile. 이름 조회가 안 되면 Pod 의 /etc/resolv.conf 도 확인.
```

</details>

### 랩 44 – 새 기본 StorageClass  (스토리지 | 보통 | 10분)

```bash
./lab.sh 44
```

```text
(원본 시험 문제 · 한글 문제집 26번)

1. 기존 프로비저너 rancher.io/local-path 를 쓰는 새 StorageClass low-latency 를
   만드세요
2. VolumeBindingMode를 WaitForFirstConsumer 로 설정하세요 (필수)
3. low-latency 를 클러스터의 기본 StorageClass로 만드세요
4. 기존 Deployment나 PersistentVolumeClaim은 수정하지 마세요
   (네임스페이스 exercise-44 에 현재 기본 클래스를 쓰는 것들이 있습니다)

./lab.sh 44 cleanup 이 low-latency 를 제거하고 원래 기본 클래스를 되돌립니다.
```

```bash
./lab.sh 44 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl get storageclass                               # local-path (default)
cat <<'EOF2' | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: low-latency
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: rancher.io/local-path
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
EOF2
kubectl patch storageclass local-path -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
kubectl get storageclass                               # low-latency (default) 하나만
# 참고: 기본 SC 가 둘이면 새 PVC 는 가장 최근 것을 쓰지만, 시험에서는 하나만 남기는 게 정답.
```

</details>

### 랩 45 – Retain된 PersistentVolume 재사용  (스토리지 | 보통 | 15분)

```bash
./lab.sh 45
```

```text
(원본 시험 문제 · 한글 문제집 28번)

사용자가 실수로 네임스페이스 exercise-45 의 MariaDB Deployment를 삭제했습니다. 이 Deployment는
영구 스토리지를 쓰고 있었습니다. 기존 PersistentVolume을 재사용해 데이터를 유지한 채로 복구하세요.
PersistentVolume은 남아 있고 재사용을 위해 Retain되어 있습니다 (PV는 하나뿐입니다).

1. 네임스페이스 exercise-45 에 PersistentVolumeClaim mariadb 를 만드세요:
     접근 모드 ReadWriteOnce, 스토리지 250Mi
2. MariaDB Deployment 파일 /root/mariadb-deploy.yaml 이 이 PVC를 쓰도록 수정하세요
3. 수정한 Deployment 파일을 클러스터에 적용하세요
4. MariaDB Deployment가 실행 중이고 안정적인지 확인하세요
```

```bash
./lab.sh 45 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl get pv                                        # mariadb-pv  250Mi RWO Retain Released
kubectl get pv mariadb-pv -o yaml | grep -A6 -E 'claimRef|storageClassName'
kubectl patch pv mariadb-pv -p '{"spec":{"claimRef":null}}'     # Released -> Available
cat <<'EOF2' | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mariadb
  namespace: exercise-45
spec:
  accessModes: ["ReadWriteOnce"]
  storageClassName: ""          # PV와 같게 (PV에 클래스가 없음); ""로 두면 기본 클래스가 붙지 않음
  resources:
    requests:
      storage: 250Mi
EOF2
kubectl -n exercise-45 get pvc mariadb                # mariadb-pv에 Bound
vi /root/mariadb-deploy.yaml                           # emptyDir를 다음으로 교체:
#      volumes:
#      - name: mariadb-storage
#        persistentVolumeClaim:
#          claimName: mariadb
kubectl apply -f /root/mariadb-deploy.yaml
kubectl -n exercise-45 rollout status deployment mariadb
kubectl -n exercise-45 get pods,pvc
# 참고: PVC 의 storageClassName 은 PV 와 같아야 한다. PV 에 클래스가 없으면 "" 를 명시.
```

</details>

### 랩 46 – 깨진 kubeconfig 고치기  (트러블슈팅 | 쉬움 | 10분)

```bash
./lab.sh 46
```

```text
kubeconfig 파일 /root/CKA/admin.kubeconfig 로 이 클러스터에 접속되지 않습니다.
원인을 찾아 파일을 고쳐서
  kubectl --kubeconfig /root/CKA/admin.kubeconfig get nodes
가 동작하게 하세요. /etc/kubernetes/admin.conf 는 건드리지 마세요.
```

```bash
./lab.sh 46 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl cluster-info --kubeconfig /root/CKA/admin.kubeconfig     # connection refused / timeout
grep server: /root/CKA/admin.kubeconfig
grep server: /etc/kubernetes/admin.conf                           # 비교
ss -ltnp | grep 6443                                              # API 서버는 6443에서 대기
vi /root/CKA/admin.kubeconfig                                     # 포트를 6443으로 수정
kubectl get nodes --kubeconfig /root/CKA/admin.kubeconfig
# 참고: 문제마다 지정된 컨텍스트가 있으면 먼저 kubectl config use-context <name>.
```

</details>

### 랩 47 – init 컨테이너가 실패하는 Pod  (트러블슈팅 | 쉬움 | 10분)

```bash
./lab.sh 47
```

```text
네임스페이스 exercise-47 의 Pod orange 가 시작되지 않습니다. 원인을 찾아 고치세요.
Pod 이름은 그대로 유지하고, 메인 컨테이너는 바꾸지 마세요.
```

```bash
./lab.sh 47 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl -n exercise-47 get pod orange                    # Init:CrashLoopBackOff / Init:Error
kubectl -n exercise-47 describe pod orange
kubectl -n exercise-47 logs orange -c init-myservice     # sh: sleeeep: not found
kubectl -n exercise-47 get pod orange -o yaml > orange.yaml
vi orange.yaml                                           # initContainers command: sleeeep 2 -> sleep 2
kubectl replace --force -f orange.yaml                   # 삭제 + 생성을 한 번에
kubectl -n exercise-47 get pod orange                    # Running
# 참고: init 컨테이너가 성공(exit 0)해야 본 컨테이너가 시작된다. 여러 개면 순서대로 하나씩.
```

</details>

### 랩 48 – 접속되지 않는 Service  (트러블슈팅 | 보통 | 15분)

```bash
./lab.sh 48
```

```text
네임스페이스 exercise-48 의 Service web-svc 가 응답하지 않습니다. Deployment web 의 Pod
(nginx, 컨테이너 포트 80)는 정상 실행 중입니다.
원인을 찾아 Service를 고치고, 클러스터 안에서 web-svc 가 응답하는지 확인하세요.
Deployment는 수정하지 마세요.
```

```bash
./lab.sh 48 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl -n exercise-48 run tmp --rm -it --image=busybox:1.28 --restart=Never -- wget -qO- -T 3 web-svc   # 타임아웃
kubectl -n exercise-48 get svc web-svc -o wide                                       # SELECTOR app=webapp
kubectl -n exercise-48 get endpointslices -l kubernetes.io/service-name=web-svc      # 엔드포인트 없음
kubectl -n exercise-48 get pods --show-labels -o wide                                # Pod 레이블은 app=web
kubectl -n exercise-48 edit svc web-svc
#   selector:   app: webapp  ->  app: web
#   targetPort: 8080         ->  80
kubectl -n exercise-48 get endpointslices -l kubernetes.io/service-name=web-svc      # Pod 2개, 포트 80
kubectl -n exercise-48 run tmp --rm -it --image=busybox:1.28 --restart=Never -- wget -qO- -T 3 web-svc   # nginx 페이지
# 참고: 그다음 점검 - Pod Ready 여부, NetworkPolicy, kube-proxy·CoreDNS Pod 상태.
```

</details>

### 랩 49 – kubeadm HA 컨트롤 플레인 (명령만 작성)  (클러스터 아키텍처 | 보통 | 10분)

```bash
./lab.sh 49
```

```text
stacked etcd를 쓰는 고가용성 kubeadm 클러스터를 구성해야 합니다. API 서버용 로드 밸런서는
lb.example.com:6443 에 준비되어 있습니다. 2노드 실습 환경에서는 만들 수 없으므로,
실행할 명령을 /root/exercise-49/ha-commands.sh 에 작성하세요:

1. 첫 번째 컨트롤 플레인 노드 cp1: 로드 밸런서를 컨트롤 플레인 엔드포인트로 클러스터를 초기화하고,
   다른 컨트롤 플레인 노드가 받아 갈 수 있도록 인증서를 업로드하세요
2. 업로드한 인증서가 만료되었으면 (2시간 후): 다시 업로드하고 새 join 명령을
   출력하세요
3. 두 번째 컨트롤 플레인 노드 cp2: 컨트롤 플레인 노드로 join 하세요
4. 두 노드의 etcd 멤버가 모두 보이는지 확인하세요
```

```bash
./lab.sh 49 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
cat <<'EOF2' > /root/exercise-49/ha-commands.sh
# 1. cp1
kubeadm init --control-plane-endpoint "lb.example.com:6443" --upload-certs --pod-network-cidr=192.168.0.0/16
# 2. 인증서는 2시간 후 만료 (Secret kubeadm-certs): 다시 업로드 + 새 join 명령
kubeadm init phase upload-certs --upload-certs        # 새 certificate key 출력
kubeadm token create --print-join-command
# 3. cp2
kubeadm join lb.example.com:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash> \
  --control-plane --certificate-key <certificate-key>
# 4. etcd 멤버
kubectl -n kube-system exec etcd-cp1 -- etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key member list -w table
EOF2
# 참고: etcd 는 과반(쿼럼)이 필요해서 실제 HA 는 컨트롤 플레인 3대 이상.
#       --control-plane-endpoint 없이 만든 단일 컨트롤 플레인은 나중에 HA 로 바꿀 수 없다.
#       현재 값: kubectl -n kube-system get cm kubeadm-config -o yaml | grep controlPlaneEndpoint
```

</details>

### 랩 50 – 최소 권한 NetworkPolicy 고르기  (서비스와 네트워킹 | 보통 | 15분)

```bash
./lab.sh 50
```

```text
(원본 시험 문제 · 한글 문제집 24번)

Deployment frontend 는 네임스페이스 exercise-50-frontend 에서, Deployment backend 는 네임스페이스
exercise-50-backend 에서 실행 중입니다. 둘은 서로 통신할 수 있어야 합니다 (frontend -> backend).

1. frontend와 backend Deployment를 분석해 어떤 통신이 필요한지 알아내세요
2. /root/netpol 의 NetworkPolicy 파일 중 하나만 골라 적용하세요. 그 정책은
   - frontend에서 backend로의 통신을 허용해야 하고
   - 가능한 한 제한적이어야 합니다 (최소 권한)
3. 기존 deny-all NetworkPolicy는 삭제하거나 바꾸지 마세요
```

```bash
./lab.sh 50 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl get ns --show-labels | grep exercise-50
kubectl -n exercise-50-frontend get deploy,pods --show-labels
kubectl -n exercise-50-backend get deploy,pods --show-labels
kubectl -n exercise-50-backend get deploy backend -o yaml | grep -A3 ports:     # containerPort 80
kubectl get netpol -A | grep exercise-50                                         # deny-all
cat /root/netpol/*.yaml
#  netpol-1: 모든 네임스페이스에서 허용 (namespaceSelector: {})             -> 너무 넓음
#  netpol-2: namespaceSelector와 podSelector가 별도 목록 항목 두 개 = OR    -> 너무 넓음
#  netpol-3: ipBlock 0.0.0.0/0                                              -> 너무 넓음
#  netpol-4: frontend ns AND app=frontend, 하지만 모든 포트                 -> 필요 이상으로 넓음
#  netpol-5: frontend ns AND app=frontend, TCP 80만                         -> 정답
kubectl apply -f /root/netpol/netpol-5.yaml
kubectl -n exercise-50-frontend exec deploy/frontend -- curl -s -m3 backend.exercise-50-backend | grep title
# 참고: from 아래 한 항목에 namespaceSelector 와 podSelector 를 함께 = AND, "-" 로 나누면 = OR.
```

</details>
### 랩 51 – 기존 Deployment에 로깅 sidecar 추가  (트러블슈팅 | 보통 | 15분)

```bash
./lab.sh 51
```

```text
(원본 시험 문제 · 한글 문제집 34번)

레거시 앱을 Kubernetes 기본 로깅 구조(kubectl logs)에 통합해야 합니다. 로그를 스트리밍하는 보조 컨테이너를
같은 Pod에 추가하는 것이 일반적이고 좋은 방법입니다.

exercise-51 네임스페이스에 Deployment synergy-deployment가 실행 중입니다. 이 Deployment의 컨테이너는 컨테이너 안의
/var/log/synergy-deployment.log 파일에 로그를 씁니다.

1. 기존 Deployment synergy-deployment를 수정해, busybox:stable 이미지를 쓰는 sidecar라는 컨테이너를
   기존 Pod에 추가하세요. 새 컨테이너는 다음 명령을 실행해야 합니다.
     /bin/sh -c "tail -n+1 -f /var/log/synergy-deployment.log"
2. /var/log에 마운트한 볼륨을 써서 sidecar 컨테이너가 synergy-deployment.log 파일을 읽을 수 있게 하세요
3. 기존 컨테이너의 사양은 필요한 볼륨 마운트를 추가하는 것 말고는 수정하지 마세요
```

```bash
./lab.sh 51 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl -n exercise-51 get deployment synergy-deployment -o yaml > synergy-backup.yaml     # 먼저 백업
kubectl -n exercise-51 edit deployment synergy-deployment
# 공유 emptyDir 볼륨을 추가해 기존 컨테이너의 /var/log에 마운트하고, sidecar를 추가한다:
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
# kubectl edit 대신 명령 하나로 같은 변경을 하는 방법 (JSON patch):
kubectl -n exercise-51 patch deployment synergy-deployment --type=json -p='[
  {"op":"add","path":"/spec/template/spec/volumes","value":[{"name":"logs","emptyDir":{}}]},
  {"op":"add","path":"/spec/template/spec/containers/0/volumeMounts","value":[{"name":"logs","mountPath":"/var/log"}]},
  {"op":"add","path":"/spec/template/spec/containers/-","value":{"name":"sidecar","image":"busybox:stable","command":["/bin/sh","-c","tail -n+1 -f /var/log/synergy-deployment.log"],"volumeMounts":[{"name":"logs","mountPath":"/var/log"}]}}]'
kubectl -n exercise-51 rollout status deployment synergy-deployment
kubectl -n exercise-51 logs deploy/synergy-deployment -c sidecar | tail -3
# 참고: 두 컨테이너가 같은 emptyDir 을 /var/log 에 마운트해야 sidecar 가 로그 파일을 볼 수 있다.
#       tail -f 는 파일이 아직 없으면 바로 끝나므로(-F 는 기다림), 앱이 파일을 만든 뒤에야 sidecar 가 계속 돈다.
#       네이티브 sidecar(initContainers + restartPolicy: Always) 로 추가해도 된다.
```

</details>

### 랩 52 – 기존 Deployment 노출: 컨테이너 포트 + NodePort Service  (서비스와 네트워킹 | 쉬움 | 10분)

```bash
./lab.sh 52
```

```text
(원본 시험 문제 · 한글 문제집 20번)

exercise-52 네임스페이스에 Deployment front-end(컨테이너 nginx)가 실행 중입니다.

1. 기존 Deployment front-end를 수정해 기존 컨테이너 nginx의 포트 80/tcp를 노출하세요
2. 컨테이너 포트 80/tcp를 노출하는 새 Service front-end-svc를 만드세요
3. 새 Service가 NodePort로 개별 Pod도 노출하도록 설정하세요
```

```bash
./lab.sh 52 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl -n exercise-52 edit deployment front-end
# nginx 컨테이너 아래에 추가:
#        ports:
#        - containerPort: 80
#          protocol: TCP
# kubectl edit 대신 명령 하나로 같은 변경을 하는 방법 (JSON patch):
kubectl -n exercise-52 patch deployment front-end --type=json -p='[{"op":"add","path":"/spec/template/spec/containers/0/ports","value":[{"containerPort":80,"protocol":"TCP"}]}]'
kubectl -n exercise-52 rollout status deployment front-end
kubectl -n exercise-52 expose deployment front-end --name=front-end-svc --port=80 --target-port=80 --protocol=TCP --type=NodePort
kubectl -n exercise-52 get svc front-end-svc                                    # 80:3xxxx/TCP
kubectl -n exercise-52 get endpointslices -l kubernetes.io/service-name=front-end-svc
NP=$(kubectl -n exercise-52 get svc front-end-svc -o jsonpath='{.spec.ports[0].nodePort}')
curl -s http://node01:$NP | grep title
# 참고: 특정 nodePort 값을 요구하면 expose 에는 옵션이 없으므로 만든 뒤 고친다:
#       kubectl -n exercise-52 patch svc front-end-svc -p '{"spec":{"ports":[{"port":80,"nodePort":30080}]}}'
```

</details>

### 랩 53 – 최댓값보다 1 작은 PriorityClass + Deployment patch  (워크로드와 스케줄링 | 보통 | 10분)

```bash
./lab.sh 53
```

```text
(원본 시험 문제 · 한글 문제집 17번)

1. 사용자 워크로드용 PriorityClass high-priority를 새로 만드세요. 값은 기존 사용자 정의 PriorityClass 중
   가장 높은 값보다 정확히 1 작아야 합니다 (기본 제공 system-* 클래스는 사용자 정의가 아닙니다)
2. exercise-53 네임스페이스의 기존 Deployment busybox-logger가 PriorityClass high-priority를 쓰도록 patch하세요
3. 새 PriorityClass가 적용된 busybox-logger Deployment가 정상적으로 롤아웃되는지 확인하세요
4. exercise-53 네임스페이스의 다른 Deployment는 수정하지 마세요

(시험에서는 high-priority Pod가 뜰 때 다른 Pod가 축출될 수 있습니다. 예상된 동작입니다.)
```

```bash
./lab.sh 53 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl get priorityclass --sort-by=.value                 # system-* 가 아닌 것 중 가장 높은 값
MAX=$(kubectl get priorityclass -o jsonpath='{range .items[*]}{.metadata.name} {.value}{"\n"}{end}' | grep -v '^system-' | awk '{print $2}' | sort -n | tail -1)
echo "highest user-defined value: $MAX"
kubectl create priorityclass high-priority --value=$((MAX-1)) --description="high priority for user workloads"
kubectl -n exercise-53 patch deployment busybox-logger -p '{"spec":{"template":{"spec":{"priorityClassName":"high-priority"}}}}'
kubectl -n exercise-53 rollout status deployment busybox-logger
kubectl -n exercise-53 get pods -o custom-columns=NAME:.metadata.name,CLASS:.spec.priorityClassName,PRIORITY:.spec.priority
# 참고: system-cluster-critical(2000000000) / system-node-critical(2000001000) 은 기본 제공 클래스라 제외한다.
#       사용자 정의 PriorityClass 값은 최대 1000000000 까지 가능하다.
```

</details>

### 랩 54 – 노드 자원을 Pod 3개에 분배 (init 컨테이너 포함)  (워크로드와 스케줄링 | 어려움 | 20분)

```bash
./lab.sh 54
```

```text
(원본 시험 문제 · 한글 문제집 16번)

exercise-54 네임스페이스에 WordPress 애플리케이션이 실행 중입니다: Deployment wordpress, 레플리카 3개, 모두
node01 노드에 묶여 있습니다. 리소스 requests가 너무 커서 Pod가 전부 실행되지 못합니다.

Deployment의 리소스 requests를 다음과 같이 조정하세요.
1. node01의 리소스를 Pod 3개에 균등하게 나누세요
2. 각 Pod에 CPU와 메모리를 공평하게 배분하세요
3. 노드가 안정적으로 유지되도록 충분한 여유분(overhead)을 남기세요 (node01에는 다른 Pod도 실행됩니다)
4. 컨테이너와 init 컨테이너 모두에 정확히 같은 requests를 쓰세요 (limits는 바꾸지 않아도 됩니다)
5. 조정 후 레플리카 3개가 모두 node01에서 Running·Ready 상태여야 합니다

힌트: requests를 고치는 동안 Deployment를 잠시 레플리카 0개로 줄이면 도움이 됩니다.
```

```bash
./lab.sh 54 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl -n exercise-54 get pods -o wide                              # 일부 Pending: Insufficient cpu / memory
kubectl -n exercise-54 scale deployment wordpress --replicas=0
# wordpress가 0개일 때 "Allocated resources"는 그 노드의 다른 Pod들이 이미 요청한 양이다
kubectl describe node node01 | grep -A8 -E '^Allocatable:|^Allocated resources:'
#   예:  Allocatable  cpu 1 (1000m)  memory 1930Mi      다른 Pod 요청량  cpu 250m  memory 290Mi
#     cpu:    (1000m - 250m) / 3 = 250m  -> 여유분 약 15% -> Pod당 210m
#     memory: (1930Mi - 290Mi) / 3 = 546Mi -> 여유분 약 15% -> Pod당 460Mi
# 같은 계산을 셸로 하면:
A_CPU=$(kubectl get node node01 -o jsonpath='{.status.allocatable.cpu}'); case $A_CPU in *m) A_CPU=${A_CPU%m};; *) A_CPU=$((A_CPU*1000));; esac
A_MEM=$(( $(kubectl get node node01 -o jsonpath='{.status.allocatable.memory}' | tr -d 'Ki') / 1024 ))
O_CPU=$(kubectl describe node node01 | awk '/^Allocated resources:/{f=1} f && $1=="cpu"{print $2; exit}'); case $O_CPU in *m) O_CPU=${O_CPU%m};; *) O_CPU=$((O_CPU*1000));; esac
O_MEM=$(kubectl describe node node01 | awk '/^Allocated resources:/{f=1} f && $1=="memory"{print $2; exit}'); case $O_MEM in *Gi) O_MEM=$(( ${O_MEM%Gi} * 1024 ));; *Mi) O_MEM=${O_MEM%Mi};; *Ki) O_MEM=$(( ${O_MEM%Ki} / 1024 ));; *) O_MEM=$(( O_MEM / 1048576 ));; esac
CPU=$(( (A_CPU - O_CPU) * 85 / 100 / 3 ))m; MEM=$(( (A_MEM - O_MEM) * 85 / 100 / 3 ))Mi
echo "per Pod: cpu=$CPU memory=$MEM"
kubectl -n exercise-54 edit deployment wordpress      # initContainers[0]과 containers[0]에 같은 requests를 넣는다
# kubectl edit 대신 명령 하나로 같은 변경을 하는 방법 (JSON patch):
kubectl -n exercise-54 patch deployment wordpress --type=json -p="[
  {\"op\":\"replace\",\"path\":\"/spec/template/spec/initContainers/0/resources/requests\",\"value\":{\"cpu\":\"$CPU\",\"memory\":\"$MEM\"}},
  {\"op\":\"replace\",\"path\":\"/spec/template/spec/containers/0/resources/requests\",\"value\":{\"cpu\":\"$CPU\",\"memory\":\"$MEM\"}}]"
kubectl -n exercise-54 scale deployment wordpress --replicas=3
kubectl -n exercise-54 rollout status deployment wordpress
kubectl -n exercise-54 get pods -o wide                              # node01에서 3/3 Running
# 참고: Pod 의 실효 요청량은 max(init 컨테이너 중 최댓값, 일반 컨테이너 합)이라 둘을 같게 두면 Pod 요청량도 그 값이다.
#       스케줄링은 실제 사용량이 아니라 requests 합계 기준이다 (kubectl top 은 실제 사용량).
```

</details>

## 4. 모의고사 1회

시험 전체는 `./mock.sh 1 start`로 시작하고 `./mock.sh 1 score`로 채점합니다.

### 1회 · Q1 – Pod 배포 트러블슈팅  (트러블슈팅 | 8분)

```bash
./mock.sh 1 1
```

```text
production 네임스페이스의 Pod app-frontend가 CrashLoopBackOff 상태입니다. 이 컨테이너는
/etc/app/config.yaml 설정 파일이 있어야 하는데, 이미지에는 이 파일이 없습니다.
Pod 매니페스트는 /root/mock1/app-frontend.yaml에 있습니다.

작업
1. production 네임스페이스에 app-config ConfigMap을 만드세요. 키는 config.yaml이고
   내용은 다음과 같습니다:   database_host: postgres.production.svc.cluster.local
2. 컨테이너 안에서 /etc/app/config.yaml 파일이 보이도록 ConfigMap을 마운트하세요
   (매니페스트를 수정하고 Pod를 다시 만드세요)
3. Pod가 시작되어 계속 Running 상태인지 확인하세요
```

```bash
./mock.sh 1 1 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl -n production logs app-frontend                 # ERROR: /etc/app/config.yaml not found
kubectl create configmap app-config -n production \
  --from-literal=config.yaml='database_host: postgres.production.svc.cluster.local'

# 매니페스트에 볼륨과 마운트를 추가한다. 완성된 파일:
cat <<'EOF' > /root/mock1/app-frontend.yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-frontend
  namespace: production
  labels:
    app: app-frontend
spec:
  containers:
  - name: app
    image: busybox:1.37
    command: ["sh", "-c", "if [ ! -f /etc/app/config.yaml ]; then echo 'ERROR: /etc/app/config.yaml not found'; exit 1; fi; echo 'config loaded:'; cat /etc/app/config.yaml; exec sleep 3600"]
    volumeMounts:
    - name: config
      mountPath: /etc/app            # 키 config.yaml이 /etc/app/config.yaml이 됨
  volumes:
  - name: config
    configMap:
      name: app-config
      items:
      - key: config.yaml
        path: config.yaml
EOF
# 실행 중인 Pod에는 볼륨을 새로 붙일 수 없으므로 다시 만든다
kubectl replace --force -f /root/mock1/app-frontend.yaml
kubectl get pod app-frontend -n production
kubectl exec app-frontend -n production -- cat /etc/app/config.yaml
# 다른 방법: mountPath /etc/app/config.yaml + subPath config.yaml로 그 파일 하나만 마운트
# (단, subPath 마운트는 ConfigMap 변경이 반영되지 않는다).
```

</details>

### 1회 · Q2 – RBAC  (클러스터 아키텍처 | 7분)

```bash
./mock.sh 1 2
```

```text
사용자 dev-user는 staging 네임스페이스에서 Pod와 Deployment를 list할 수 있어야 하고,
다른 네임스페이스에서는 아무것도 할 수 없어야 합니다.

작업
1. staging 네임스페이스에 Pod와 Deployment의 list를 허용하는 Role staging-reader를 만드세요
2. 이 Role을 사용자 dev-user에게 부여하는 RoleBinding staging-reader-dev-user를 만드세요
3. kubectl auth can-i로 확인하세요 (dev-user가 default 네임스페이스에서는 pods를 list할 수 없는지도 확인하세요)
```

```bash
./mock.sh 1 2 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl create role staging-reader -n staging --verb=list --resource=pods,deployments
kubectl create rolebinding staging-reader-dev-user -n staging --role=staging-reader --user=dev-user
kubectl auth can-i list pods --as=dev-user -n staging              # yes
kubectl auth can-i list deployments --as=dev-user -n staging       # yes
kubectl auth can-i list pods --as=dev-user -n default              # no
# --resource=deployments는 apps API 그룹으로 해석되므로 Deployment에 맞는 규칙이 된다.
```

</details>

### 1회 · Q3 – 노드 유지보수  (클러스터 아키텍처 | 6분)

```bash
./mock.sh 1 3
```

```text
노드 node01을 유지보수해야 합니다. maintenance 네임스페이스에서 node01에 다음이 실행 중입니다:
  - Deployment web (레플리카 3개)
  - 노드 로컬 스토리지(emptyDir)에 데이터를 두는 단독 Pod database

작업
1. node01에 새 Pod가 스케줄되지 않게 하세요
2. web Pod들을 node01에서 옮기세요
3. database Pod는 축출되거나 삭제되면 안 됩니다. 같은 Pod 그대로 node01에서 Running이어야 합니다
4. node01을 그 상태로 두세요 (유지보수 자체는 아직 시작하지 않았습니다)

참고: node01이 스케줄 불가 상태인 동안 다른 문제의 새 Pod는 컨트롤 플레인에만 배치됩니다.
```

```bash
./mock.sh 1 3 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl get pods -n maintenance -o wide
kubectl cordon node01
# 그냥 drain하면 거부된다: database는 컨트롤러가 관리하지 않고 emptyDir을 쓴다.
#   kubectl drain node01 --ignore-daemonsets
#   error: cannot delete Pods that declare no controller (use --force to override): maintenance/database
# --force --delete-emptydir-data를 쓰면 database Pod와 데이터가 삭제됨 - 여기서는 허용 안 됨.
# web Pod만 옮긴다: node01이 cordon된 상태라 Deployment가 다른 곳에 다시 만든다.
kubectl delete pod -n maintenance -l app=web --field-selector spec.nodeName=node01
# 다른 방법: kubectl drain node01 --ignore-daemonsets --pod-selector=app=web
#   단, --pod-selector는 모든 네임스페이스의 Pod에 매칭되므로 관리되지 않는 다른 app=web Pod가 있으면 실패한다.
kubectl get pods -n maintenance -o wide      # database는 node01에 그대로, web Pod는 다른 곳(또는 Pending)
kubectl get node node01                      # Ready,SchedulingDisabled
# 유지보수가 끝나면:  kubectl uncordon node01
```

</details>

### 1회 · Q4 – PersistentVolume 구성  (스토리지 | 10분)

```bash
./mock.sh 1 4
```

```text
databases 네임스페이스의 Deployment db-app에 여러 Pod가 동시에 쓸 수 있는 영구 스토리지가
필요합니다. 이 클러스터에는 동적 SSD 프로비저너가 없으므로 정적으로 프로비저닝합니다.

작업
1. 프로비저너 kubernetes.io/no-provisioner로 StorageClass fast-ssd를 만드세요
2. PersistentVolume db-pv를 만드세요: 5Gi, 접근 모드 ReadWriteMany, storageClassName fast-ssd,
   hostPath /mnt/fast-ssd
3. databases 네임스페이스에 PersistentVolumeClaim db-storage를 만드세요: 5Gi, ReadWriteMany,
   storageClassName fast-ssd - db-pv에 Bound되어야 합니다
4. db-app 컨테이너의 /data에 이 클레임을 마운트하고 롤아웃이 완료되는지 확인하세요
```

```bash
./mock.sh 1 4 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd
provisioner: kubernetes.io/no-provisioner
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: db-pv
spec:
  capacity:
    storage: 5Gi
  accessModes: ["ReadWriteMany"]
  storageClassName: fast-ssd
  hostPath:
    path: /mnt/fast-ssd
    type: DirectoryOrCreate
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: db-storage
  namespace: databases
spec:
  accessModes: ["ReadWriteMany"]
  storageClassName: fast-ssd
  resources:
    requests:
      storage: 5Gi
EOF
kubectl get pvc db-storage -n databases            # Bound to db-pv
# (kubectl에는 "set volume"이 없다 - 그건 OpenShift의 oc 명령). patch나 kubectl edit을 쓴다:
kubectl patch deployment db-app -n databases --type=json -p='[
  {"op":"add","path":"/spec/template/spec/volumes","value":[{"name":"data","persistentVolumeClaim":{"claimName":"db-storage"}}]},
  {"op":"add","path":"/spec/template/spec/containers/0/volumeMounts","value":[{"name":"data","mountPath":"/data"}]}]'
kubectl rollout status deployment/db-app -n databases
kubectl exec deploy/db-app -n databases -- df -h /data
# 참고: hostPath는 노드 로컬이다. 이 랩에서는 ReadWriteMany 조건을 만족하지만, 노드 간에 RWX가
# 의미 있으려면 실제 공유 스토리지(NFS, CephFS, EFS, Filestore ...)가 필요하다.
```

</details>

### 1회 · Q5 – NetworkPolicy  (서비스와 네트워킹 | 10분)

```bash
./mock.sh 1 5
```

```text
shop 네임스페이스에서는 현재 모든 Pod가 서로 통신할 수 있습니다. Pod 목록:
  frontend (tier=frontend, 포트 80)   backend (tier=backend, 포트 3000)
  database (tier=database, 포트 5432) outsider (tier 레이블 없음 - 테스트용)

shop 네임스페이스에 NetworkPolicy를 만들어 다음을 만족하게 하세요:
1. tier=frontend Pod는 TCP 포트 80으로 들어오는 트래픽만 받습니다 (출발지 제한 없음)
2. tier=backend Pod는 tier=frontend Pod에서 TCP 포트 3000으로 들어오는 트래픽만 받습니다
3. tier=database Pod는 tier=backend Pod에서 TCP 포트 5432로 들어오는 트래픽만 받습니다
나가는 트래픽은 제한하면 안 됩니다.
```

```bash
./mock.sh 1 5 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: frontend-policy
  namespace: shop
spec:
  podSelector:
    matchLabels:
      tier: frontend
  policyTypes: ["Ingress"]
  ingress:
  - ports:                       # "from"이 없으면 모든 출발지
    - protocol: TCP
      port: 80
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-policy
  namespace: shop
spec:
  podSelector:
    matchLabels:
      tier: backend
  policyTypes: ["Ingress"]
  ingress:
  - from:
    - podSelector:
        matchLabels:
          tier: frontend
    ports:
    - protocol: TCP
      port: 3000
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: database-policy
  namespace: shop
spec:
  podSelector:
    matchLabels:
      tier: database
  policyTypes: ["Ingress"]
  ingress:
  - from:
    - podSelector:
        matchLabels:
          tier: backend
    ports:
    - protocol: TCP
      port: 5432
EOF
B=$(kubectl get pod backend -n shop -o jsonpath='{.status.podIP}')
kubectl exec frontend -n shop -- curl -s -m3 -o /dev/null -w '%{http_code}\n' http://$B:3000   # 200
kubectl exec outsider -n shop -- curl -s -m3 http://$B:3000 || echo blocked                     # blocked
# policyTypes에 Ingress만 있으므로 egress는 열려 있다 (DNS 등은 계속 동작).
# 참고: "protocol"은 각 "ports" 항목 안에 들어간다 - ingress 규칙에는 "from"과 "ports"만 있다.
```

</details>

### 1회 · Q6 – Helm 차트 배포  (클러스터 아키텍처 | 8분)

```bash
./mock.sh 1 6
```

```text
로컬 Helm 차트 monitoring이 /root/helm-charts/monitoring에 있습니다.

작업
1. 이 차트를 monitoring 네임스페이스에 릴리스 monitoring-stack으로 설치하세요 (네임스페이스가
   없으면 만드세요). 차트 값은 다음으로 덮어쓰세요:
     replica_count = 3
     storage_size  = 50Gi
     persistence   = true   (불리언)
2. 릴리스가 deployed 상태이고 Deployment의 ready 레플리카가 3개인지 확인하세요
```

```bash
./mock.sh 1 6 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
cat /root/helm-charts/monitoring/values.yaml          # 값 이름 확인
helm install monitoring-stack /root/helm-charts/monitoring \
  -n monitoring --create-namespace \
  --set replica_count=3 \
  --set storage_size=50Gi \
  --set persistence=true
helm list -n monitoring
helm get values monitoring-stack -n monitoring
kubectl get deploy,pvc -n monitoring
# values 파일로 해도 같다:  helm install ... -f my-values.yaml
# --set은 "true"를 불리언으로 바꾼다. 문자열 "true"가 필요하면 --set-string을 쓴다.
```

</details>

### 1회 · Q7 – 컨테이너 런타임 설정  (클러스터 아키텍처 | 8분)

```bash
./mock.sh 1 7
```

```text
워커 노드 node01이 containerd 대신 cri-dockerd를 쓰도록 해야 합니다.
Docker와 cri-dockerd는 node01에 이미 설치되어 실행 중입니다
(cri-docker.socket / cri-docker.service, 소켓 unix:///run/cri-dockerd.sock).

작업
1. node01의 kubelet이 cri-dockerd 소켓을 쓰도록 설정하고 재시작하세요
2. node01이 Ready이고 컨테이너 런타임이 docker://로 표시되는지 확인하세요
3. node01에 스케줄된 Pod가 시작되는지 확인하세요

이 작업은 세션이 끝날 때까지 node01을 바꿔 둡니다. ./mock.sh 1 7 cleanup으로 되돌립니다.
```

```bash
./mock.sh 1 7 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
ssh node01
systemctl status cri-docker.socket cri-docker.service --no-pager
ls -la /run/cri-dockerd.sock
# kubeadm은 런타임 플래그를 /var/lib/kubelet/kubeadm-flags.env에 둔다
# (/etc/kubernetes/kubelet.conf는 kubelet의 kubeconfig일 뿐 - 여기서 바꿀 곳이 아님)
cat /var/lib/kubelet/kubeadm-flags.env
systemctl stop kubelet
crictl --runtime-endpoint unix:///run/containerd/containerd.sock rmp -fa   # 기존 containerd Pod 정리
sed -i 's#--container-runtime-endpoint=[^ "]*#--container-runtime-endpoint=unix:///run/cri-dockerd.sock#' /var/lib/kubelet/kubeadm-flags.env
cat /var/lib/kubelet/kubeadm-flags.env
systemctl daemon-reload && systemctl restart kubelet
exit
kubectl get nodes -o wide                 # node01 Ready, CONTAINER-RUNTIME docker://...
kubectl run rt-test --image=busybox:1.37 --overrides='{"spec":{"nodeName":"node01"}}' -- sleep 300
kubectl get pod rt-test -o wide           # Running
kubectl delete pod rt-test --force
# kubeadm-flags.env에 엔드포인트가 없으면 /var/lib/kubelet/config.yaml의 containerRuntimeEndpoint를 설정한다.
```

</details>

### 1회 · Q8 – API 서버 audit 로그  (트러블슈팅 | 10분)

```bash
./mock.sh 1 8
```

```text
누군가 default 네임스페이스의 ConfigMap을 계속 읽고 있습니다. audit 로그로 누구인지 찾으세요.

작업
1. kube-apiserver(컨트롤 플레인 노드)에서 audit 로그를 켜세요:
   - audit 정책 파일 /etc/kubernetes/audit/policy.yaml: ConfigMap 요청을 Metadata 레벨
     (또는 그 이상)로 기록합니다. 나머지는 None 레벨이어도 됩니다.
   - audit 로그 파일 /var/log/kubernetes/audit/audit.log
   - --audit-log-maxbackup=2, --audit-log-maxsize=10
2. 새 요청이 들어올 때까지 기다리세요. default 네임스페이스의 ConfigMap을 계속 list하는
   ServiceAccount를 찾아 audit 사용자 이름을 /root/mock1/q08-user.txt에 쓰세요
   (kubelet도 ConfigMap을 watch하므로 system:node:* 사용자는 무시하세요)
3. 그 요청들이 받는 HTTP 응답 코드를 /root/mock1/q08-code.txt에 쓰세요
4. 그 요청 중 하나의 requestReceivedTimestamp를 /root/mock1/q08-time.txt에 쓰세요

/etc/kubernetes/manifests 안에 백업 사본을 두지 마세요 - kubelet은 그 안의 파일을 모두 실행합니다.
```

```bash
./mock.sh 1 8 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
mkdir -p /etc/kubernetes/audit /var/log/kubernetes/audit
cat <<'EOF' > /etc/kubernetes/audit/policy.yaml
apiVersion: audit.k8s.io/v1
kind: Policy
omitStages: ["RequestReceived"]
rules:
- level: Metadata
  resources:
  - group: ""
    resources: ["configmaps"]
- level: None
EOF
# /etc/kubernetes/manifests/kube-apiserver.yaml을 수정한다 (백업은 manifests 디렉터리 밖에 둔다):
#   command:
#   - --audit-policy-file=/etc/kubernetes/audit/policy.yaml
#   - --audit-log-path=/var/log/kubernetes/audit/audit.log
#   - --audit-log-maxbackup=2
#   - --audit-log-maxsize=10
#   volumeMounts:
#   - name: audit-policy
#     mountPath: /etc/kubernetes/audit
#     readOnly: true
#   - name: audit-log
#     mountPath: /var/log/kubernetes/audit
#   volumes:
#   - name: audit-policy
#     hostPath: {path: /etc/kubernetes/audit, type: DirectoryOrCreate}
#   - name: audit-log
#     hostPath: {path: /var/log/kubernetes/audit, type: DirectoryOrCreate}
# 같은 수정을 sed로:
M=/etc/kubernetes/manifests/kube-apiserver.yaml
cp $M /root/kube-apiserver.yaml.bak
sed -i '/- kube-apiserver$/a\    - --audit-policy-file=/etc/kubernetes/audit/policy.yaml\n    - --audit-log-path=/var/log/kubernetes/audit/audit.log\n    - --audit-log-maxbackup=2\n    - --audit-log-maxsize=10' $M
sed -i '0,/^    volumeMounts:$/s##    volumeMounts:\n    - mountPath: /etc/kubernetes/audit\n      name: audit-policy\n      readOnly: true\n    - mountPath: /var/log/kubernetes/audit\n      name: audit-log#' $M
sed -i '0,/^  volumes:$/s##  volumes:\n  - hostPath:\n      path: /etc/kubernetes/audit\n      type: DirectoryOrCreate\n    name: audit-policy\n  - hostPath:\n      path: /var/log/kubernetes/audit\n      type: DirectoryOrCreate\n    name: audit-log#' $M
# API 서버가 다시 뜰 때까지 기다린다 (30-90초)
until kubectl get --raw=/readyz >/dev/null 2>&1; do sleep 5; done
until grep -q 'serviceaccount:ops' /var/log/kubernetes/audit/audit.log 2>/dev/null; do sleep 5; done
# audit 로그는 한 줄이 JSON 이벤트 하나다 (하나의 큰 배열이 아니라 JSON lines):
grep '"resource":"configmaps"' /var/log/kubernetes/audit/audit.log | grep '"namespace":"default"' | tail -3
grep '"resource":"configmaps"' /var/log/kubernetes/audit/audit.log | grep '"namespace":"default"' | grep -v system:node: \
  | jq -r '[.user.username, .verb, .responseStatus.code, .requestReceivedTimestamp] | @tsv' | sort | uniq -c | tail
L=$(grep '"resource":"configmaps"' /var/log/kubernetes/audit/audit.log | grep 'system:serviceaccount:ops:config-sync' | tail -1)
echo "$L" | jq -r .user.username > /root/mock1/q08-user.txt          # system:serviceaccount:ops:config-sync
echo "$L" | jq -r .responseStatus.code > /root/mock1/q08-code.txt     # 403 - RBAC 권한이 없음
echo "$L" | jq -r .requestReceivedTimestamp > /root/mock1/q08-time.txt
```

</details>

### 1회 · Q9 – HPA와 애플리케이션 스케일링  (워크로드와 스케줄링 | 7분)

```bash
./mock.sh 1 9
```

```text
production 네임스페이스의 Deployment web-app이 레플리카 2개로 실행 중입니다. metrics-server는 설치되어 있습니다.

작업
1. Deployment web-app에 대해 HorizontalPodAutoscaler web-app을 만드세요. 평균 CPU 사용률을
   70%로 유지하고, 레플리카는 최소 2개, 최대 10개입니다
2. HPA가 CPU 메트릭을 읽는지 확인하세요 (TARGETS에 <unknown>이 아니라 백분율이 표시되어야 합니다)
```

```bash
./mock.sh 1 9 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl autoscale deployment web-app -n production --min=2 --max=10 --cpu=70%
# (예전 kubectl: --cpu-percent=70 - deprecated, kubectl 1.37은 경고와 함께 아직 받아 준다. kubectl autoscale -h 로 확인)
kubectl get hpa web-app -n production          # TARGETS cpu: 0%/70% after ~30-60s
kubectl describe hpa web-app -n production
# YAML 버전:
# apiVersion: autoscaling/v2
# kind: HorizontalPodAutoscaler
# metadata: {name: web-app, namespace: production}
# spec:
#   scaleTargetRef: {apiVersion: apps/v1, kind: Deployment, name: web-app}
#   minReplicas: 2
#   maxReplicas: 10
#   metrics:
#   - type: Resource
#     resource: {name: cpu, target: {type: Utilization, averageUtilization: 70}}
# 사용률은 Pod의 CPU *requests* 대비로 계산된다 - requests가 없으면 HPA에 <unknown>이 표시된다.
```

</details>

### 1회 · Q10 – TLS를 쓰는 Ingress  (서비스와 네트워킹 | 8분)

```bash
./mock.sh 1 10
```

```text
Service api(default 네임스페이스, 포트 80)를 ingress-nginx(IngressClass nginx, 이미 설치됨)로
외부에 공개해야 합니다. TLS Secret api-tls-cert는 default에 이미 있습니다.

작업
1. 호스트 api.example.com에 대한 Ingress api-ingress를 만드세요:
   - Secret api-tls-cert로 TLS 적용
   - 경로 /api (pathType Prefix) -> Service api 포트 80
2. 호스트 api.example.com의 /health도 Service api 포트 80으로 라우팅하세요. 로드 밸런서 헬스
   체크가 평문 HTTP로 호출하므로 /health로 오는 HTTP 요청은 (HTTPS로 리다이렉트하지 말고)
   바로 응답해야 하며, /api로 오는 HTTP 요청은 계속 리다이렉트되어야 합니다.
   힌트: ingress-nginx 어노테이션은 Ingress 객체 전체에 적용됩니다.
3. ingress-nginx NodePort로 curl 테스트를 하세요 (--resolve 또는 Host 헤더 사용)
```

```bash
./mock.sh 1 10 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-ingress
  namespace: default
spec:
  ingressClassName: nginx
  tls:
  - hosts: ["api.example.com"]
    secretName: api-tls-cert
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api
            port:
              number: 80
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-health
  namespace: default
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "false"     # 이 Ingress의 경로에만 적용
spec:
  ingressClassName: nginx
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /health
        pathType: Exact
        backend:
          service:
            name: api
            port:
              number: 80
EOF
IP=$(kubectl get node controlplane -o jsonpath='{.status.addresses[?(@.type=="InternalIP")].address}')
HP=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')
SP=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
curl -sk --resolve api.example.com:$SP:$IP https://api.example.com:$SP/api/                          # api says hello
curl -s -o /dev/null -w '%{http_code}\n' --resolve api.example.com:$HP:$IP http://api.example.com:$HP/api/    # 308
curl -s --resolve api.example.com:$HP:$IP http://api.example.com:$HP/health                          # api says hello
# Ingress를 둘로 나누는 이유: 호스트에 TLS가 있으면 ingress-nginx는 HTTP를 HTTPS로 리다이렉트한다 (308).
# ssl-redirect 어노테이션은 Ingress 단위이므로 /health는 리다이렉트를 끈 별도 Ingress에 둔다.
```

</details>

### 1회 · Q11 – 클러스터 트러블슈팅  (트러블슈팅 | 12분)

```bash
./mock.sh 1 11
```

```text
kube-scheduler가 멈췄습니다. default 네임스페이스의 Pod sched-test가 계속 Pending입니다.

작업
1. 컨트롤 플레인 구성 요소의 상태를 확인하세요
2. kube-scheduler가 실행되지 않는 원인을 찾으세요 (static Pod - kubelet / 컨테이너 로그)
3. 스케줄러가 다시 실행되고 sched-test가 스케줄되도록 고치세요
4. 근본 원인을 /root/mock1/q11-cause.txt에 한 줄로 적으세요

/etc/kubernetes/manifests 안에 백업 사본을 두지 마세요 - kubelet은 그 안의 파일을 모두 실행합니다.
(./mock.sh 1 start는 스케줄러를 망가뜨리지 않습니다 - 이 문제에 오면 ./mock.sh 1 11을 실행하세요.)
```

```bash
./mock.sh 1 11 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl get pods -n kube-system | grep scheduler           # CrashLoopBackOff (또는 없음)
kubectl get pod sched-test                                 # Pending, 노드 미배정
crictl ps -a --name kube-scheduler                         # Exited
crictl logs $(crictl ps -a --name kube-scheduler -q | head -1) 2>&1 | tail -5
#   ... stat /etc/kubernetes/scheduler.config: no such file or directory
journalctl -u kubelet --no-pager | grep -i scheduler | tail -5
ls /etc/kubernetes/*.conf                                  # 실제 파일은 scheduler.conf
grep kubeconfig /etc/kubernetes/manifests/kube-scheduler.yaml
sed -i 's#/etc/kubernetes/scheduler.config#/etc/kubernetes/scheduler.conf#g' /etc/kubernetes/manifests/kube-scheduler.yaml
sleep 30; crictl ps --name kube-scheduler                  # Running
kubectl get pod sched-test -o wide                         # 스케줄됨, Running
echo "kube-scheduler manifest pointed --kubeconfig/--authentication-kubeconfig/--authorization-kubeconfig at /etc/kubernetes/scheduler.config (does not exist); fixed to scheduler.conf" > /root/mock1/q11-cause.txt
# kubelet을 재시작할 필요는 없다: 매니페스트 변경을 스스로 감지한다.
```

</details>

### 1회 · Q12 – 영구 스토리지를 쓰는 StatefulSet  (워크로드와 스토리지 | 10분)

```bash
./mock.sh 1 12
```

```text
작업 (default 네임스페이스)
1. 포트 5432를 노출하고 app=database-cluster를 선택하는 headless Service database-cluster를 만드세요
2. StatefulSet database-cluster를 만드세요:
   - 레플리카 3개, serviceName database-cluster, Pod 레이블 app=database-cluster
   - 컨테이너 postgres, 이미지 postgres:17-alpine, 포트 5432, env POSTGRES_PASSWORD=mockexam
   - volumeClaimTemplate data: 10Gi, ReadWriteOnce, storageClassName local-path,
     /var/lib/postgresql/data에 마운트
3. Pod 3개가 모두 Ready이고 각자 Bound된 PVC를 가지며, 다른 Pod에서 고정 DNS 이름
   database-cluster-0.database-cluster가 해석되는지 확인하세요
```

```bash
./mock.sh 1 12 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: database-cluster
  namespace: default
spec:
  clusterIP: None
  selector:
    app: database-cluster
  ports:
  - port: 5432
    targetPort: 5432
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: database-cluster
  namespace: default
spec:
  serviceName: database-cluster
  replicas: 3
  selector:
    matchLabels:
      app: database-cluster
  template:
    metadata:
      labels:
        app: database-cluster
    spec:
      containers:
      - name: postgres
        image: postgres:17-alpine
        env:
        - name: POSTGRES_PASSWORD
          value: mockexam
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: data
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: local-path
      resources:
        requests:
          storage: 10Gi
EOF
kubectl rollout status sts database-cluster
kubectl get pods -l app=database-cluster -o wide
kubectl get pvc                         # data-database-cluster-0/1/2, 모두 Bound
kubectl exec database-cluster-1 -- nslookup database-cluster-0.database-cluster
# PVC 이름은 <템플릿 이름>-<Pod 이름>이다. postgres는 POSTGRES_PASSWORD가 없으면 종료된다.
```

</details>

### 1회 · Q13 – ResourceQuota와 LimitRange  (워크로드와 스케줄링 | 8분)

```bash
./mock.sh 1 13
```

```text
test 네임스페이스가 리소스를 너무 많이 씁니다.

작업
1. test 네임스페이스에 ResourceQuota test-quota를 만드세요: CPU requests 합계 4코어, 메모리
   requests 합계 8Gi (limits도 같은 값으로 제한해도 됩니다)
2. test 네임스페이스에 LimitRange test-limits를 만들어 모든 컨테이너가 최소 CPU 100m,
   메모리 128Mi를 request하도록 하세요
3. CPU 6개 / 4Gi를 request하는 Pod(limits도 같음)가 거부되고, CPU 50m / 64Mi를 request하는
   Pod도 거부되는지 확인하세요. CPU 6개 Pod의 에러를 /root/mock1/q13-rejected.txt에 저장하세요
```

```bash
./mock.sh 1 13 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: test-quota
  namespace: test
spec:
  hard:
    requests.cpu: "4"
    requests.memory: 8Gi
    limits.cpu: "4"
    limits.memory: 8Gi
---
apiVersion: v1
kind: LimitRange
metadata:
  name: test-limits
  namespace: test
spec:
  limits:
  - type: Container
    min:
      cpu: 100m
      memory: 128Mi
EOF
kubectl describe quota test-quota -n test
kubectl describe limitrange test-limits -n test
# kubectl run에는 이제 --requests 플래그가 없다 (1.24에서 제거) - --overrides나 YAML을 쓴다:
kubectl run big -n test --image=nginx:1.27 --restart=Never --overrides='{"spec":{"containers":[{"name":"big","image":"nginx:1.27","resources":{"requests":{"cpu":"6","memory":"4Gi"},"limits":{"cpu":"6","memory":"4Gi"}}}]}}' 2> /root/mock1/q13-rejected.txt
cat /root/mock1/q13-rejected.txt     # forbidden: exceeded quota: test-quota, requested: ... cpu=6 ...
kubectl run tiny -n test --image=nginx:1.27 --restart=Never --overrides='{"spec":{"containers":[{"name":"tiny","image":"nginx:1.27","resources":{"requests":{"cpu":"50m","memory":"64Mi"},"limits":{"cpu":"50m","memory":"64Mi"}}}]}}'
#   forbidden: minimum cpu usage per Container is 100m, but request is 50m
# 참고: CPU 2개 / 2Gi Pod(원래 문제 문구)는 4 CPU / 8Gi 쿼터 안에 들어가므로 승인된다.
# 쿼터에 limits.*가 있으면 모든 Pod가 limits도 설정해야 한다 (또는 LimitRange 기본값으로 받아야 한다).
```

</details>

### 1회 · Q14 – Pod Security Standards  (클러스터 아키텍처 | 8분)

```bash
./mock.sh 1 14
```

```text
restricted 네임스페이스에 Pod Security Admission으로 보안 정책을 강제해야 합니다.

작업
1. restricted 네임스페이스에 restricted Pod Security Standard를 enforce로 적용하세요
2. 같은 네임스페이스에 baseline 레벨로 audit을 설정하세요
3. restricted에 privileged: true Pod를 만들어 보고 거부되는지 확인하세요.
   에러 메시지를 /root/mock1/q14-denied.txt에 저장하세요
```

```bash
./mock.sh 1 14 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl label ns restricted \
  pod-security.kubernetes.io/enforce=restricted \
  pod-security.kubernetes.io/audit=baseline --overwrite
kubectl get ns restricted --show-labels
kubectl run priv-pod -n restricted --image=nginx:1.27 --privileged 2> /root/mock1/q14-denied.txt
cat /root/mock1/q14-denied.txt
#   Error from server (Forbidden): pods "priv-pod" is forbidden: violates PodSecurity "restricted:latest":
#   privileged (container "priv-pod" must not set securityContext.privileged=true), allowPrivilegeEscalation != false, ...
# enforce는 거부하고, audit은 audit 로그에 어노테이션만 남기며, warn은 클라이언트에 경고를 출력한다.
# restricted는 runAsNonRoot, allowPrivilegeEscalation=false, 모든 capability drop(ALL),
# seccompProfile 등을 요구한다 - 읽기 전용 루트 파일시스템은 요구하지 않는다. (PodSecurityPolicy는 1.25에서 제거됨.)
```

</details>

### 1회 · Q15 – sidecar가 있는 멀티 컨테이너 Pod  (워크로드와 스케줄링 | 8분)

```bash
./mock.sh 1 15
```

```text
작업 (default 네임스페이스)
다음 조건으로 Pod app-with-logger를 만드세요:
1. 컨테이너 nginx, 이미지 nginx:1.28
2. 컨테이너 logger, 이미지 busybox:1.37, nginx access 로그를 따라 읽습니다:  tail -F /logs/access.log
3. 두 컨테이너가 공유하는 emptyDir 볼륨: nginx에서는 /var/log/nginx, logger에서는 /logs에 마운트
4. 두 컨테이너 모두 재시작 없이 계속 실행되고, nginx로 보낸 요청이
   kubectl logs app-with-logger -c logger에 나타나야 합니다
```

```bash
./mock.sh 1 15 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: app-with-logger
  namespace: default
spec:
  containers:
  - name: nginx
    image: nginx:1.28
    volumeMounts:
    - name: logs
      mountPath: /var/log/nginx
  - name: logger
    image: busybox:1.37
    command: ["sh", "-c", "tail -F /logs/access.log"]
    volumeMounts:
    - name: logs
      mountPath: /logs
  volumes:
  - name: logs
    emptyDir: {}
EOF
kubectl get pod app-with-logger
kubectl exec app-with-logger -c nginx -- curl -s localhost >/dev/null
kubectl logs app-with-logger -c logger
# nginx 이미지는 access.log를 /dev/stdout에 링크해 둔다. /var/log/nginx 위에 emptyDir을 마운트하면
# 그 링크가 가려지므로 nginx가 sidecar가 읽을 수 있는 실제 파일에 기록한다.
# tail -F(대문자 F)는 파일이 아직 없어도 계속 재시도한다 - tail -f는 종료되어 crash-loop에 빠진다.
# 네이티브 sidecar(initContainers + restartPolicy: Always)를 써도 된다.
```

</details>
## 5. 모의고사 2회

`./mock.sh 2 start`로 시험 전체를 시작하고, `./mock.sh 2 score`로 채점합니다.

### 2회 · Q1 – Service 디스커버리와 DNS  (서비스와 네트워킹 | 6분)

```bash
./mock.sh 2 1
```

```text
frontend 네임스페이스의 Service web-ui가 포트 3000을 노출합니다. backend 네임스페이스의 애플리케이션이
DNS로 이 Service를 호출해야 합니다.

작업
1. Service의 FQDN(전체 DNS 이름)을 /root/mock2/q01-fqdn.txt에 쓰세요
2. backend 네임스페이스에 Pod dns-test를 만드세요 (이미지 busybox:1.37, 명령: sleep 3600)
3. dns-test에서 nslookup으로 Service 이름을 조회하고, 조회된 IP를
   /root/mock2/q01-ip.txt에 쓰세요
4. dns-test에서 http://web-ui.frontend:3000 을 호출해 응답을 확인하세요
```

```bash
./mock.sh 2 1 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
echo web-ui.frontend.svc.cluster.local > /root/mock2/q01-fqdn.txt     # <service>.<namespace>.svc.cluster.local
kubectl run dns-test -n backend --image=busybox:1.37 -- sleep 3600
kubectl wait --for=condition=Ready pod/dns-test -n backend
kubectl exec dns-test -n backend -- nslookup web-ui.frontend.svc.cluster.local
kubectl get svc web-ui -n frontend -o jsonpath='{.spec.clusterIP}' > /root/mock2/q01-ip.txt
kubectl exec dns-test -n backend -- wget -qO- http://web-ui.frontend:3000           # hello from web-ui
# 다른 네임스페이스에서는 짧은 이름 "web-ui"가 조회되지 않는다 - 최소한 web-ui.frontend까지 써야 한다.
# 일반 Service는 DNS가 ClusterIP를 돌려준다 (Pod IP는 headless Service일 때만).
```

</details>

### 2회 · Q2 – Deployment 롤링 업데이트와 롤백  (워크로드 | 8분)

```bash
./mock.sh 2 2
```

```text
payments 네임스페이스의 Deployment payment-service가 동작하지 않는 버전으로 업데이트되었습니다.

작업
1. payment-service의 롤아웃 히스토리를 확인하세요
2. 문제가 있는 revision 번호를 /root/mock2/q02-bad-revision.txt에 쓰세요
3. 마지막으로 정상 동작한 버전(이미지 nginx:1.27)으로 롤백하세요
4. 롤백이 끝났고 레플리카 3개가 모두 available인지 확인하세요
```

```bash
./mock.sh 2 2 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl rollout history deployment/payment-service -n payments
#   1  v1.0 initial release (nginx:1.25)
#   2  v1.1 performance fixes (nginx:1.26)
#   3  v1.2 stable (nginx:1.27)
#   4  v1.3 hotfix
kubectl rollout history deployment/payment-service -n payments --revision=4     # image nginx:1.27-payments-hotfix
kubectl get pods -n payments                                                     # ErrImagePull / ImagePullBackOff
echo 4 > /root/mock2/q02-bad-revision.txt
kubectl rollout undo deployment/payment-service -n payments                      # 직전 revision(3)으로 되돌림
#   또는: kubectl rollout undo deployment/payment-service -n payments --to-revision=3
kubectl rollout status deployment/payment-service -n payments
kubectl get deploy payment-service -n payments -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
kubectl rollout history deployment/payment-service -n payments                   # revision 3이 이제 revision 5가 됨
```

</details>

### 2회 · Q3 – Secret과 환경 변수  (워크로드 | 7분)

```bash
./mock.sh 2 3
```

```text
secrets-demo 네임스페이스의 Deployment app-deploy(컨테이너 app)에 데이터베이스 접속 정보가 필요합니다.

작업
1. secrets-demo에 다음 키를 가진 Secret db-creds를 만드세요:
     username=dbuser   password=secret123   database=appdb
2. 이 값들을 Secret에서 가져와 app 컨테이너에 환경 변수 DB_USERNAME, DB_PASSWORD,
   DB_DATABASE로 넣으세요 (파일로 넣지 말고, Deployment에 값을 직접 쓰지도 마세요)
3. 새 Pod에서 변수가 보이는지 확인하세요. 단, Pod 로그에 값이 나오면 안 됩니다
```

```bash
./mock.sh 2 3 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl create secret generic db-creds -n secrets-demo \
  --from-literal=username=dbuser --from-literal=password=secret123 --from-literal=database=appdb
# 빠른 방법: 키마다 secretKeyRef 하나씩, 이름은 대문자로 바뀌고 접두어가 붙는다
kubectl set env deployment/app-deploy -n secrets-demo --from=secret/db-creds --prefix=DB_
kubectl get deploy app-deploy -n secrets-demo -o yaml | grep -A4 'name: DB_'
# YAML로 쓰면 같은 결과 (app 컨테이너 아래):
#   env:
#   - name: DB_USERNAME
#     valueFrom: {secretKeyRef: {name: db-creds, key: username}}
#   - name: DB_PASSWORD
#     valueFrom: {secretKeyRef: {name: db-creds, key: password}}
#   - name: DB_DATABASE
#     valueFrom: {secretKeyRef: {name: db-creds, key: database}}
kubectl rollout status deployment/app-deploy -n secrets-demo
kubectl exec deploy/app-deploy -n secrets-demo -- env | grep DB_
kubectl logs deploy/app-deploy -n secrets-demo                  # "app started"만 나옴
# Secret은 base64 인코딩일 뿐 암호화가 아니다. Pod에 exec하거나 Secret을 읽을 권한이 있으면
# 누구나 값을 볼 수 있다 - RBAC(그리고 etcd 저장 시 암호화)로 통제한다.
```

</details>

### 2회 · Q4 – DaemonSet 설정  (워크로드와 스케줄링 | 8분)

```bash
./mock.sh 2 4
```

```text
monitoring 네임스페이스의 DaemonSet monitoring-agent는 컨트롤 플레인을 포함한 모든 노드에서 실행되어야 합니다.
지금은 컨트롤 플레인 노드의 taint 때문에 그 노드에 agent가 없습니다.

작업
1. DaemonSet이 node-role.kubernetes.io/control-plane:NoSchedule 을 tolerate하도록 수정하세요
   (이미지는 busybox:1.37 그대로 유지)
2. 모든 노드에서 agent Pod가 하나씩 실행되는지 확인하세요
```

```bash
./mock.sh 2 4 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl describe node controlplane | grep Taints        # node-role.kubernetes.io/control-plane:NoSchedule
kubectl get ds monitoring-agent -n monitoring           # DESIRED = 워커 노드 수만큼
kubectl patch ds monitoring-agent -n monitoring --type=json -p='[{"op":"add","path":"/spec/template/spec/tolerations","value":[{"key":"node-role.kubernetes.io/control-plane","operator":"Exists","effect":"NoSchedule"}]}]'
# 또는 kubectl edit ds monitoring-agent -n monitoring 으로 spec.template.spec 아래에 추가:
#   tolerations:
#   - key: node-role.kubernetes.io/control-plane
#     operator: Exists
#     effect: NoSchedule
kubectl rollout status ds monitoring-agent -n monitoring
kubectl get pods -n monitoring -o wide                  # 노드마다 Pod 하나, controlplane 포함
# (원래 문제는 datadog/agent:latest를 썼는데, 1 GB가 넘는 이미지에 API 키도 필요해서
#  이 랩에서는 busybox를 쓴다.)
```

</details>

### 2회 · Q5 – API 서버 디버깅  (트러블슈팅 | 9분)

```bash
./mock.sh 2 5
```

```text
API 서버가 느립니다. audit 로그는 이미 켜져 있습니다:
  policy /etc/kubernetes/audit/policy.yaml, log /var/log/kubernetes/audit/audit.log

작업 (컨트롤 플레인 노드)
1. kube-apiserver 로그의 마지막 50줄을 /root/mock2/q05-apiserver.log에 저장하세요
2. kube-apiserver가 포트 6443에서 리슨 중임을 보여 주는 ss/netstat 줄을 /root/mock2/q05-listen.txt에 저장하세요
3. API 서버의 상세 readiness 확인(/readyz?verbose) 출력을 /root/mock2/q05-readyz.txt에 저장하세요
4. audit 로그에서 요청을 가장 많이 보내는 사용자를 찾아 사용자 이름을
   /root/mock2/q05-top-user.txt에 쓰세요
5. 그 사용자가 받는 HTTP 응답 코드를 /root/mock2/q05-code.txt에 쓰세요
6. 그 클라이언트를 멈추세요: 해당 Deployment를 찾아 레플리카를 0으로 scale하세요
```

```bash
./mock.sh 2 5 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
# 1. 로그 - kubectl은 API 서버가 떠 있을 때만, crictl은 API 서버가 죽어 있어도 된다
kubectl logs -n kube-system kube-apiserver-controlplane --tail=50 > /root/mock2/q05-apiserver.log
#   또는: crictl logs --tail=50 $(crictl ps --name kube-apiserver -q) > /root/mock2/q05-apiserver.log 2>&1
#   (kubeadm은 static Pod로 실행하므로 journalctl로 볼 kube-apiserver systemd 유닛이 없다)
# 2. 리슨 소켓
ss -tlnp | grep 6443 > /root/mock2/q05-listen.txt            # ... *:6443 ... users:(("kube-apiserver",pid=...))
# 3. 상태
kubectl get --raw='/readyz?verbose' > /root/mock2/q05-readyz.txt
# 4. 누가 요청을 가장 많이 보내나? audit 로그는 JSON lines 형식 - 한 줄에 이벤트 하나.
jq -r '.user.username' /var/log/kubernetes/audit/audit.log | sort | uniq -c | sort -rn | head -5
#   jq 없이: grep -o '"username":"[^"]*"' /var/log/kubernetes/audit/audit.log | sort | uniq -c | sort -rn | head
echo system:serviceaccount:reports:report-bot > /root/mock2/q05-top-user.txt
# 5. 그 사용자의 응답 코드
grep 'system:serviceaccount:reports:report-bot' /var/log/kubernetes/audit/audit.log | jq -r '.responseStatus.code' | sort | uniq -c
echo 403 > /root/mock2/q05-code.txt
# 6. 사용자 이름이 알려 준다: reports 네임스페이스의 ServiceAccount report-bot
kubectl get deploy -n reports -o wide
kubectl scale deploy report-bot -n reports --replicas=0
# 이것도 유용하다: kubectl get --raw /metrics | grep apiserver_request_total, 그리고 APF:
# kubectl get --raw /debug/api_priority_and_fairness/dump_priority_levels
```

</details>

### 2회 · Q6 – ConfigMap 업데이트  (워크로드 | 8분)

```bash
./mock.sh 2 6
```

```text
config-demo 네임스페이스에 ConfigMap app-config(키 mode=blue)와 이를 사용하는 Deployment 두 개가 있습니다:
  volume-app - ConfigMap을 /config에 볼륨으로 마운트
  env-app    - 키를 환경 변수 MODE로 읽음

작업
1. ConfigMap app-config의 mode를 green으로 바꾸세요
2. volume-app은 Pod를 재시작하지 않고 변경을 반영해야 합니다: 실행 중인 Pod의 /config/mode가
   green인지 확인하세요 (최대 1분 정도 걸릴 수 있음)
3. env-app은 여전히 blue를 봅니다. 롤링 재시작으로 새 값을 반영하세요
   (Deployment를 삭제하거나 다시 만들지 마세요)
```

```bash
./mock.sh 2 6 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl patch configmap app-config -n config-demo -p '{"data":{"mode":"green"}}'
#   또는: kubectl edit cm app-config -n config-demo
# 볼륨 마운트(subPath 없이)는 kubelet이 다음 sync 때 갱신한다 - 보통 1분 이내.
P=$(kubectl get pod -n config-demo -l app=volume-app -o name)
sleep 60; kubectl exec -n config-demo $P -- cat /config/mode            # green, 같은 Pod
kubectl logs -n config-demo deploy/volume-app --tail=3
# 환경 변수는 컨테이너가 시작될 때 고정된다 - 새 Pod만 새 값을 받는다:
kubectl exec -n config-demo deploy/env-app -- printenv MODE              # 여전히 blue
kubectl rollout restart deployment/env-app -n config-demo
kubectl rollout status deployment/env-app -n config-demo
kubectl exec -n config-demo deploy/env-app -- printenv MODE              # green
# 자동으로 갱신되지 않는 것: 환경 변수, envFrom, subPath 마운트.
# 변경 시 완전 자동 재시작을 하려면 Stakater Reloader 같은 컨트롤러나, ConfigMap이 바뀔 때마다
# 함께 바뀌는 config 해시 어노테이션을 Pod 템플릿에 두어야 한다.
```

</details>

### 2회 · Q7 – PriorityClass와 축출 순서  (워크로드와 스케줄링 | 9분)

```bash
./mock.sh 2 7
```

```text
작업
1. value 1000인 PriorityClass critical-workload와 value 100인 PriorityClass standard-workload를
   만드세요. 둘 다 preemptionPolicy PreemptLowerPriority를 쓰고, 둘 다 global default가 아니어야 합니다.
2. priority-demo 네임스페이스에 Pod critical-pod-1, critical-pod-2(priority class
   critical-workload)와 standard-pod(priority class standard-workload)를 만드세요. 이미지는 모두 nginx:1.27
3. 노드 메모리가 부족해지고 세 Pod 모두 request보다 메모리를 더 쓰고 있다면, kubelet은 어느 Pod를
   먼저 축출할까요? 그 이름을 /root/mock2/q07-first-evicted.txt에 쓰세요
```

```bash
./mock.sh 2 7 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: critical-workload
value: 1000
globalDefault: false
preemptionPolicy: PreemptLowerPriority
description: "Critical workloads"
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: standard-workload
value: 100
globalDefault: false
preemptionPolicy: PreemptLowerPriority
description: "Standard workloads"
EOF
for p in critical-pod-1 critical-pod-2; do
  kubectl run $p -n priority-demo --image=nginx:1.27 --overrides='{"spec":{"priorityClassName":"critical-workload"}}'
done
kubectl run standard-pod -n priority-demo --image=nginx:1.27 --overrides='{"spec":{"priorityClassName":"standard-workload"}}'
kubectl get pods -n priority-demo -o custom-columns=NAME:.metadata.name,PRIORITY:.spec.priority
echo standard-pod > /root/mock2/q07-first-evicted.txt
# 서로 다른 두 메커니즘:
# - 선점(스케줄러): 대기 중인 높은 우선순위 Pod가 자리를 만들려고 낮은 우선순위 Pod를 축출할 수 있다.
#   preemptionPolicy: Never = 큐에서 기다리기만 하고 다른 Pod를 선점하지 않는다.
# - 노드 압박 축출(kubelet): (1) requests 초과 사용 여부, (2) 우선순위, (3) requests 대비 사용량
#   순으로 Pod를 정렬한다. 여기서는 셋 다 requests를 넘으므로 우선순위가 가장 낮은
#   Pod - standard-pod - 가 먼저 축출된다.
# globalDefault: true로 하면 클래스를 지정하지 않은 새 Pod가 모두 그 우선순위를 받는다 - 여기서는 피한다.
```

</details>

### 2회 · Q8 – Service 타입과 노출  (서비스와 네트워킹 | 7분)

```bash
./mock.sh 2 8
```

```text
legacy 네임스페이스의 Deployment legacy-app(Pod 레이블 app=legacy)은 포트 3000에서 리슨합니다.
Ingress 없이 클러스터 밖에서 접근할 수 있어야 합니다.

작업
1. legacy 네임스페이스에 NodePort 타입의 Service legacy-app을 만드세요:
   service port 8080 -> targetPort 3000, nodePort 30080
2. Pod 네트워크 밖에서 <node-ip>:30080 으로 응답하는지 확인하세요

(원래 문제는 노드 포트 8080을 요구했습니다. NodePort는 노드 포트 범위(기본 30000-32767) 안이어야
 하므로 여기서는 8080을 service port로 씁니다.)
```

```bash
./mock.sh 2 8 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: legacy-app
  namespace: legacy
spec:
  type: NodePort
  selector:
    app: legacy
  ports:
  - protocol: TCP
    port: 8080          # 클러스터 안에서 쓰는 ClusterIP 포트
    targetPort: 3000    # 컨테이너 포트
    nodePort: 30080     # 모든 노드에 열림 (30000-32767)
EOF
kubectl get svc legacy-app -n legacy                  # 8080:30080/TCP
kubectl get endpointslices -n legacy
IP=$(kubectl get node node01 -o jsonpath='{.status.addresses[?(@.type=="InternalIP")].address}')
curl http://$IP:30080                                 # legacy-app OK
# kubectl expose deploy legacy-app -n legacy --type=NodePort --port=8080 --target-port=3000
# 도 되지만 nodePort가 임의로 정해진다 - 나중에 30080으로 patch한다.
```

</details>

### 2회 · Q9 – CronJob 스케줄링  (워크로드 | 7분)

```bash
./mock.sh 2 9
```

```text
작업 (네임스페이스 backup)
1. CronJob backup-job을 만드세요: 이미지 busybox:1.37, 명령  sh -c 'echo Running backup; date; sleep 5'
   - 매일 02:00에 실행
   - 성공한 Job은 최근 3개만 보관
   - restartPolicy OnFailure
2. CronJob을 일시 중지하세요 (다음 한 달 동안 실행되면 안 됨)
3. 일시 중지된 상태에서 수동으로 한 번 실행하세요: CronJob으로부터 Job backup-manual을 만들고
   완료되는지 확인하세요
```

```bash
./mock.sh 2 9 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl create cronjob backup-job -n backup --image=busybox:1.37 --schedule="0 2 * * *" \
  --dry-run=client -o yaml -- sh -c 'echo Running backup; date; sleep 5' > backup-job.yaml
# successfulJobsHistoryLimit + suspend 추가 (restartPolicy OnFailure는 kubectl create cronjob이 이미 넣어 줌)
sed -i 's/^spec:$/spec:\n  successfulJobsHistoryLimit: 3\n  suspend: true/' backup-job.yaml
kubectl apply -f backup-job.yaml
kubectl get cronjob backup-job -n backup              # SUSPEND True, SCHEDULE 0 2 * * *
# 기존 CronJob 일시 중지 / 재개:
#   kubectl patch cronjob backup-job -n backup -p '{"spec":{"suspend":true}}'
#   kubectl patch cronjob backup-job -n backup -p '{"spec":{"suspend":false}}'
kubectl create job backup-manual -n backup --from=cronjob/backup-job
kubectl wait --for=condition=Complete job/backup-manual -n backup
kubectl logs job/backup-manual -n backup
# Cron 필드: 분 시 일 월 요일. spec.timeZone(예: "Etc/UTC")을 지정하지 않으면
# controller-manager의 시간대를 따른다.
```

</details>

### 2회 · Q10 – 클러스터 인증서 갱신  (클러스터 아키텍처 | 10분)

```bash
./mock.sh 2 10
```

```text
컨트롤 플레인 인증서가 곧 만료됩니다. 컨트롤 플레인 노드에서:

작업
1. 현재 만료 현황(kubeadm)을 /root/mock2/q10-before.txt에 저장하세요
2. kubeadm이 관리하는 인증서를 모두 갱신하세요
3. 컨트롤 플레인 구성 요소가 새 인증서를 쓰게 하세요 - 포트 6443의 API 서버가
   갱신된 인증서를 제공해야 합니다
4. 그 뒤에도 kubectl이 동작하는지 확인하세요
```

```bash
./mock.sh 2 10 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubeadm certs check-expiration | tee /root/mock2/q10-before.txt
kubeadm certs renew all
#   "Done renewing certificates. You must restart the kube-apiserver, kube-controller-manager,
#    kube-scheduler and etcd, so that they can use the new certificates."
kubeadm certs check-expiration                       # 새 날짜
# static Pod 재시작: 매니페스트를 밖으로 옮기고, 컨테이너가 사라질 때까지 기다렸다가, 다시 넣는다.
# (systemctl restart kubelet으로는 실행 중인 static Pod 컨테이너가 재시작되지 않고,
#  mirror Pod에 kubectl delete pod를 해도 컨테이너는 재시작되지 않는다.)
mkdir -p /root/manifests-tmp
mv /etc/kubernetes/manifests/*.yaml /root/manifests-tmp/
sleep 20; crictl ps | grep -E 'kube-apiserver|etcd|kube-scheduler|kube-controller' || echo "all stopped"
mv /root/manifests-tmp/*.yaml /etc/kubernetes/manifests/
until kubectl get --raw=/readyz >/dev/null 2>&1; do sleep 5; done
# admin.conf도 갱신되었으므로 kubeconfig를 새로 복사한다
cp /etc/kubernetes/admin.conf /root/.kube/config
kubectl get nodes
echo | openssl s_client -connect 127.0.0.1:6443 2>/dev/null | openssl x509 -noout -dates
# CA 인증서(10년)는 "renew all"로 갱신되지 않는다. kubelet 클라이언트 인증서는 자동으로 교체된다.
```

</details>

### 2회 · Q11 – Pod Disruption Budget  (워크로드와 스케줄링 | 8분)

```bash
./mock.sh 2 11
```

```text
pdb-demo 네임스페이스의 Deployment my-app은 레플리카 10개(레이블 app=my-app)로 실행됩니다. 노드 drain 같은
자발적 중단으로 한 번에 Pod를 2개보다 많이 잃으면 안 됩니다.

작업
1. 이를 강제하는 PodDisruptionBudget app-pdb를 pdb-demo에 만드세요
2. 테스트하세요: node01을 drain하고(DaemonSet 무시, app=my-app Pod만, --timeout=60s 사용)
   축출이 막히는 것을 확인하세요. --force는 쓰지 마세요: node01에는 다른 문제의 Pod도 실행 중입니다
3. 그 뒤 node01을 uncordon하고 레플리카 10개가 모두 다시 available인지 확인하세요
```

```bash
./mock.sh 2 11 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl create pdb app-pdb -n pdb-demo --selector=app=my-app --min-available=8
#   (같은 의미: --max-unavailable=2)
kubectl get pdb app-pdb -n pdb-demo                 # ALLOWED DISRUPTIONS 2
kubectl drain node01 --ignore-daemonsets --pod-selector=app=my-app --timeout=60s
#   (그냥 drain하면 node01에 다른 문제의 Pod가 있어서 "cannot delete Pods that declare no controller"에서
#    멈춘다; --force를 쓰면 그 Pod들이 삭제된다)
#   evicting pod pdb-demo/my-app-...
#   error when evicting pods/"my-app-..." -n "pdb-demo" (will retry after 5s): Cannot evict pod as it
#   would violate the pod's disruption budget.
# drain은 Pod 2개를 축출한 뒤, 대체 Pod가 다른 곳에서 Ready가 될 때까지 기다렸다가 더 축출한다.
# 대체 Pod가 뜨지 못하면(예: 컨트롤 플레인에 taint가 있음) drain은 budget에서 멈춘다.
kubectl get pods -n pdb-demo -o wide
kubectl uncordon node01
kubectl rollout status deploy/my-app -n pdb-demo
kubectl get pdb app-pdb -n pdb-demo
# PDB는 Eviction API를 쓰는 자발적 중단(drain, kubectl evict)만 제한한다.
# kubectl delete pod와 노드 장애에는 적용되지 않는다.
```

</details>

### 2회 · Q12 – Custom Resource Definition  (클러스터 아키텍처 | 7분)

```bash
./mock.sh 2 12
```

```text
팀에서 kind Database용 CRD를 설치했습니다.

작업
1. CRD를 찾아 전체 이름을 /root/mock2/q12-crd.txt에 쓰세요
2. crd-demo 네임스페이스에 다음 값으로 Database prod-db를 만드세요
     spec.engine=postgres  spec.version="15"  spec.storage=100Gi
3. prod-db가 etcd에 저장되었음을 보이세요: 해당 키에 대한 etcdctl get 출력
   (--keys-only면 충분)을 /root/mock2/q12-etcd.txt에 저장하세요
4. crd-demo의 Database old-db를 삭제하세요
```

```bash
./mock.sh 2 12 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl get crd | grep -i database
kubectl get crd databases.example.com -o jsonpath='{.metadata.name}' > /root/mock2/q12-crd.txt
kubectl explain database.spec                     # 필드: engine (postgres|mysql), version, storage
cat <<'EOF' | kubectl apply -f -
apiVersion: example.com/v1
kind: Database
metadata:
  name: prod-db
  namespace: crd-demo
spec:
  engine: postgres
  version: "15"          # 따옴표 필요 - 스키마상 string
  storage: 100Gi
EOF
kubectl get databases -n crd-demo                 # 짧은 이름: kubectl get db -n crd-demo
# etcd 키: /registry/<group>/<plural>/<namespace>/<name>
# etcd 컨테이너의 etcdctl 사용 (노드에 etcdctl이 설치되어 있지 않아도 동작):
ETCD=$(crictl ps --name etcd -q | head -1)
crictl exec $ETCD etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key \
  get /registry/example.com/databases/crd-demo/prod-db --keys-only | tee /root/mock2/q12-etcd.txt
kubectl delete database old-db -n crd-demo
kubectl get databases -n crd-demo
```

</details>

### 2회 · Q13 – Pod Security 예외  (클러스터 아키텍처 | 9분)

```bash
./mock.sh 2 13
```

```text
restricted 네임스페이스는 restricted Pod Security Standard를 강제합니다. 레거시 Pod root-app
(이미지 nginx:1.27, root로 실행해야 함)은 이 네임스페이스에서 거부됩니다.

Pod Security Admission에는 Pod 단위 예외 레이블이 없습니다: 예외는 API 서버의 admission 설정
(사용자, runtimeClass, 네임스페이스 기준)에만 있습니다. 대신 네임스페이스로 해결하세요:

작업
1. baseline Pod Security Standard를 강제하는 네임스페이스 legacy-root를 만드세요
   (root는 허용, privileged 컨테이너는 불가)
2. 그 네임스페이스에서 Pod root-app(nginx:1.27)을 실행하고 uid 0으로 실행되는지 확인하세요
3. restricted 네임스페이스는 그대로 두세요: 여전히 root Pod를 거부해야 합니다
```

```bash
./mock.sh 2 13 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl run root-app -n restricted --image=nginx:1.27      # forbidden: violates PodSecurity "restricted:latest"
kubectl create ns legacy-root
kubectl label ns legacy-root pod-security.kubernetes.io/enforce=baseline
kubectl run root-app -n legacy-root --image=nginx:1.27
kubectl exec root-app -n legacy-root -- id                 # uid=0(root)
kubectl run p -n legacy-root --image=nginx:1.27 --privileged --dry-run=server   # forbidden (baseline)
# Pod에 pod-security.kubernetes.io/exempt=true 같은 레이블을 붙여도 아무 효과가 없다.
# 진짜 예외는 API 서버의 AdmissionConfiguration(--admission-control-config-file)에서
# PodSecurity 플러그인 -> exemptions: usernames / runtimeClasses / namespaces 로 설정한다.
# 조건에 맞는 모든 대상에 클러스터 전체로 적용되므로, 보통은 전용 네임스페이스가 낫다.
```

</details>

### 2회 · Q14 – StorageClass와 동적 프로비저닝  (스토리지 | 8분)

```bash
./mock.sh 2 14
```

```text
클러스터에서 local-path 프로비저너(프로비저너 이름 rancher.io/local-path)가 실행 중입니다.

작업
1. StorageClass ssd를 만드세요: provisioner rancher.io/local-path, reclaimPolicy Delete,
   volumeBindingMode WaitForFirstConsumer
2. storage-demo 네임스페이스에 PVC my-ssd-claim을 만드세요: 20Gi, ReadWriteOnce, storageClassName ssd
3. storage-demo에 claim을 /data에 마운트하는 Pod app-using-ssd(이미지 nginx:1.27)를 만드세요
4. PersistentVolume이 자동으로 만들어지고 claim이 Bound 상태인지 확인하세요
```

```bash
./mock.sh 2 14 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ssd
provisioner: rancher.io/local-path
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-ssd-claim
  namespace: storage-demo
spec:
  accessModes: ["ReadWriteOnce"]
  storageClassName: ssd
  resources:
    requests:
      storage: 20Gi
EOF
kubectl get pvc -n storage-demo              # Pending - WaitForFirstConsumer라서 Pod를 기다림
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: app-using-ssd
  namespace: storage-demo
spec:
  containers:
  - name: app
    image: nginx:1.27
    volumeMounts:
    - name: data
      mountPath: /data
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: my-ssd-claim
EOF
kubectl wait --for=condition=Ready pod/app-using-ssd -n storage-demo
kubectl get pvc,pv -n storage-demo           # Bound, 프로비저너가 만든 PV pvc-<uid>
# 클라우드 클러스터라면 프로비저너는 CSI 드라이버다. 예: ebs.csi.aws.com (type: gp3)
# 또는 pd.csi.storage.gke.io (type: pd-ssd). local-path는 20Gi 크기를 강제하지 않는다.
```

</details>

### 2회 · Q15 – 네임스페이스 Quota와 리소스 관리  (워크로드와 스케줄링 | 10분)

```bash
./mock.sh 2 15
```

```text
batch-jobs 네임스페이스에 리소스 관리 정책을 설정하세요.

작업
1. ResourceQuota batch-quota: 전체 CPU 10코어, 전체 메모리 20Gi
   (requests 기준; limits도 같은 값으로 제한해도 됩니다)
2. LimitRange batch-limits, 컨테이너당: 최소 500m CPU / 256Mi 메모리,
   최대 4 CPU / 8Gi 메모리
3. requests(와 limits)가 5 CPU / 2Gi인 Pod를 만들어 보세요 - 거부되어야 합니다.
   오류를 /root/mock2/q15-rejected.txt에 저장하세요
4. requests 1 CPU / 1Gi, limits 2 CPU / 2Gi인 Pod는 허용되는지 확인하세요
```

```bash
./mock.sh 2 15 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: batch-quota
  namespace: batch-jobs
spec:
  hard:
    requests.cpu: "10"
    requests.memory: 20Gi
    limits.cpu: "10"
    limits.memory: 20Gi
---
apiVersion: v1
kind: LimitRange
metadata:
  name: batch-limits
  namespace: batch-jobs
spec:
  limits:
  - type: Container
    min:
      cpu: 500m
      memory: 256Mi
    max:
      cpu: "4"
      memory: 8Gi
EOF
kubectl describe quota batch-quota -n batch-jobs
kubectl describe limitrange batch-limits -n batch-jobs
# kubectl run의 --requests/--limits는 1.24에서 없어졌다 - --overrides(또는 YAML)를 쓴다:
kubectl run too-big -n batch-jobs --image=nginx:1.27 --restart=Never --overrides='{"spec":{"containers":[{"name":"too-big","image":"nginx:1.27","resources":{"requests":{"cpu":"5","memory":"2Gi"},"limits":{"cpu":"5","memory":"2Gi"}}}]}}' 2> /root/mock2/q15-rejected.txt
cat /root/mock2/q15-rejected.txt     # forbidden: maximum cpu usage per Container is 4, but limit is 5
kubectl run fits -n batch-jobs --image=nginx:1.27 --restart=Never --overrides='{"spec":{"containers":[{"name":"fits","image":"nginx:1.27","resources":{"requests":{"cpu":"1","memory":"1Gi"},"limits":{"cpu":"2","memory":"2Gi"}}}]}}'
kubectl get pod fits -n batch-jobs
# default 없이 LimitRange max만 있으면: limits가 없는 컨테이너는 limits = max(4 CPU / 8Gi)가 되고,
# requests도 없으면 requests = 그 limits가 된다.
```

</details>

## 6. 모의고사 3회 (Killer Shell 스타일)

전체 시험은 `./mock.sh 3 start`로 시작하고 `./mock.sh 3 score`로 채점합니다.
Q8과 Q20은 클러스터를 크게 바꾸므로 `start`에서 제외됩니다. Q8은 맨 먼저(`start` 직후 `./mock.sh 3 8`), Q20은 맨 마지막에 푸세요.

### 3회 · Q1 – 컨텍스트  (kubeconfig로 클러스터 접근 | 4%)

```bash
./mock.sh 3 1
```

```text
kubeconfig 파일 /root/mock3/1/kubeconfig는 다른 클러스터의 것입니다(이 클러스터에는
사용할 수 없음). kubectl로 이 파일에서 정보를 뽑아내세요:

1. 모든 컨텍스트 이름을 한 줄에 하나씩 /root/mock3/1/contexts에 쓰세요
2. 현재 컨텍스트 이름을 /root/mock3/1/current-context에 쓰세요
3. 사용자 account-0027@internal의 클라이언트 인증서를 base64 디코딩해서
   /root/mock3/1/cert에 쓰세요
```

```bash
./mock.sh 3 1 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
K="kubectl --kubeconfig /root/mock3/1/kubeconfig"
$K config get-contexts                                   # 전체 보기
$K config get-contexts -o name > /root/mock3/1/contexts
$K config current-context > /root/mock3/1/current-context
# 주의: account-0027은 .users의 첫 항목이 아니다 - 이름으로 골라야 한다
$K config view --raw -o jsonpath='{.users[?(@.name=="account-0027@internal")].user.client-certificate-data}' \
  | base64 -d > /root/mock3/1/cert
openssl x509 -in /root/mock3/1/cert -noout -subject     # CN = account-0027@internal
```

</details>

### 3회 · Q2 – CRD, Helm, cert-manager  (Helm / CRD | 6%)

```bash
./mock.sh 3 2
```

```text
Helm으로 cert-manager 오퍼레이터를 설치하고 이를 위한 ClusterIssuer를 만드세요.
Helm 저장소 jetstack은 이미 설정되어 있습니다.

1. 네임스페이스 cert-manager를 만드세요
2. 차트 jetstack/cert-manager를 그 네임스페이스에 릴리스 이름 cert-manager로 설치하세요.
   값은 crds.enabled=true로 하세요
3. /root/mock3/2/cluster-issuer.yaml을 고쳐서 spec.selfSigned에
   crlDistributionPoints: ["http://example.com/crl"]가 들어가게 하세요
4. /root/mock3/2/cluster-issuer.yaml로 ClusterIssuer를 만드세요

실제 인증서 발급은 하지 않아도 됩니다.
```

```bash
./mock.sh 3 2 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl create ns cert-manager
helm search repo jetstack
helm -n cert-manager install cert-manager jetstack/cert-manager --set crds.enabled=true
kubectl -n cert-manager rollout status deploy/cert-manager-webhook   # 4단계 전에 webhook이 뜰 때까지 기다린다
kubectl get crd | grep cert-manager
kubectl explain clusterissuer.spec.selfSigned                       # crlDistributionPoints <[]string> 이 보임
cat > /root/mock3/2/cluster-issuer.yaml <<'YAML'
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: course-issuer
spec:
  selfSigned:
    crlDistributionPoints:
    - http://example.com/crl
YAML
kubectl apply -f /root/mock3/2/cluster-issuer.yaml
kubectl get clusterissuer                                            # READY True
```

</details>

### 3회 · Q3 – StatefulSet 축소  (워크로드 | 2%)

```bash
./mock.sh 3 3
```

```text
네임스페이스 project-h800에 o3db-*라는 이름의 Pod가 두 개 있습니다. 관리팀은 리소스를
아끼려고 이를 레플리카 하나로 줄이길 원합니다.
```

```bash
./mock.sh 3 3 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl -n project-h800 get pod | grep o3db
kubectl -n project-h800 get deploy,ds,sts | grep o3db       # StatefulSet임
kubectl -n project-h800 scale sts o3db --replicas 1
kubectl -n project-h800 get sts o3db                       # READY 1/1
```

</details>

### 3회 · Q4 – 먼저 종료될 Pod 찾기  (스케줄링 / QoS | 3%)

```bash
./mock.sh 3 4
```

```text
네임스페이스 project-c13의 모든 Pod를 확인해서, 노드의 cpu나 메모리가 부족해지면
가장 먼저 종료될 가능성이 높은 Pod를 찾으세요.

그 이름을 한 줄에 하나씩 /root/mock3/4/pods-terminated-first.txt에 쓰세요.
```

```bash
./mock.sh 3 4 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
# requests/limits가 하나도 없는 Pod는 QoS 클래스가 BestEffort가 되고 가장 먼저 축출된다.
kubectl -n project-c13 get pod -o custom-columns=NAME:.metadata.name,QOS:.status.qosClass
kubectl -n project-c13 get pod -o jsonpath='{range .items[*]}{.metadata.name} {.spec.containers[*].resources}{"\n"}{end}'
kubectl -n project-c13 get pod -o jsonpath='{range .items[?(@.status.qosClass=="BestEffort")]}{.metadata.name}{"\n"}{end}' \
  > /root/mock3/4/pods-terminated-first.txt
# 참고: c13-3cc-data는 메모리 limit만 있다 -> requests는 limit 값으로 기본 설정되지만 cpu가 없다 -> Burstable,
# BestEffort가 아니다. c13-2x3-web은 requests == limits -> Guaranteed.
```

</details>

### 3회 · Q5 – Kustomize로 HPA 오토스케일러 설정  (워크로드 / Kustomize | 8%)

```bash
./mock.sh 3 5
```

```text
애플리케이션 api-gateway는 외부 오토스케일러를 써 왔는데, 이를 HorizontalPodAutoscaler로
바꾸려 합니다. 이 애플리케이션은 다음 명령으로 네임스페이스 api-gateway-staging과 api-gateway-prod에 배포됩니다:
  kubectl kustomize /root/mock3/5/api-gateway/staging | kubectl apply -f -
  kubectl kustomize /root/mock3/5/api-gateway/prod    | kubectl apply -f -

/root/mock3/5/api-gateway의 Kustomize 설정을 사용해서:
1. ConfigMap horizontal-scaling-config를 완전히 없애세요
2. Deployment api-gateway용 HPA api-gateway를 추가하세요: 레플리카 최소 2, 최대 4,
   평균 CPU 사용률 50%에서 스케일링
3. prod에서는 HPA가 레플리카를 최대 6개까지 허용해야 합니다
4. 변경 사항을 staging과 prod에 적용해서 클러스터에 반영하세요
```

```bash
./mock.sh 3 5 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
cd /root/mock3/5/api-gateway
kubectl kustomize staging          # base + overlay 결과 확인
# 1. base/api-gateway.yaml에서 ConfigMap 문서를 지우고, staging/와 prod/ 패치에서도 지운다
#    (없어진 리소스에 대한 패치가 남아 있으면 빌드가 실패한다)
# 2. base/api-gateway.yaml에 추가한다 (namespace는 쓰지 않는다 - overlay가 정한다):
cat >> base/api-gateway.yaml <<'YAML'
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: api-gateway
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: api-gateway
  minReplicas: 2
  maxReplicas: 4
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
YAML
# 3. prod/api-gateway.yaml에 추가한다:
cat >> prod/api-gateway.yaml <<'YAML'
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: api-gateway
spec:
  maxReplicas: 6
YAML
kubectl kustomize staging | grep -B5 maxReplicas
kubectl kustomize prod | grep -B5 maxReplicas
# 4. 적용 - kustomize는 상태를 저장하지 않으므로 예전 ConfigMap은 직접 지워야 한다
kubectl kustomize staging | kubectl apply -f -
kubectl kustomize prod | kubectl apply -f -
kubectl -n api-gateway-staging delete cm horizontal-scaling-config
kubectl -n api-gateway-prod delete cm horizontal-scaling-config
# 선택: Deployment에서 "replicas: 1"을 지우면 다시 적용해도 HPA와 충돌하지 않는다.
```

</details>

### 3회 · Q6 – 스토리지, PV, PVC, Pod 볼륨  (스토리지 | 8%)

```bash
./mock.sh 3 6
```

```text
1. PersistentVolume safari-pv를 만드세요: 용량 2Gi, accessMode ReadWriteOnce,
   hostPath /Volumes/Data, storageClassName 없음
2. 네임스페이스 project-t230에 PersistentVolumeClaim safari-pvc를 만드세요: 요청 2Gi,
   accessMode ReadWriteOnce, 스토리지 클래스 없음. safari-pv에 Bound되어야 합니다
3. 네임스페이스 project-t230에 Deployment safari(이미지 httpd:2-alpine)를 만들고
   볼륨을 /tmp/safari-data에 마운트하세요

Killercoda 힌트: 클러스터에 기본 StorageClass가 있으면 storageClassName이 없는 PVC에
기본 클래스가 자동으로 붙어서 safari-pv에 바인딩되지 않습니다. 그럴 때는
PVC에  storageClassName: ""  을 지정하세요("클래스 없음"이라는 뜻).
```

```bash
./mock.sh 3 6 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: safari-pv
spec:
  capacity:
    storage: 2Gi
  accessModes: ["ReadWriteOnce"]
  hostPath:
    path: /Volumes/Data
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: safari-pvc
  namespace: project-t230
spec:
  storageClassName: ""          # 클러스터에 기본 StorageClass가 있을 때만 필요
  accessModes: ["ReadWriteOnce"]
  resources:
    requests:
      storage: 2Gi
YAML
kubectl -n project-t230 get pv,pvc                 # 둘 다 Bound
kubectl -n project-t230 create deploy safari --image=httpd:2-alpine --dry-run=client -o yaml > 6_dep.yaml
# spec.template.spec 아래에 추가:
#   volumes:
#   - name: data
#     persistentVolumeClaim:
#       claimName: safari-pvc
# 컨테이너 아래에 추가:
#   volumeMounts:
#   - name: data
#     mountPath: /tmp/safari-data
kubectl apply -f 6_dep.yaml
kubectl -n project-t230 describe pod -l app=safari | grep -A2 Mounts:
```

</details>

### 3회 · Q7 – 노드와 Pod 리소스 사용량  (모니터링 | 1%)

```bash
./mock.sh 3 7
```

```text
metrics-server가 설치되어 있습니다. kubectl을 쓰는 bash 스크립트 두 개를 작성하세요:
1. /root/mock3/7/node.sh는 노드의 리소스 사용량을 보여 줍니다
2. /root/mock3/7/pod.sh는 Pod와 그 컨테이너의 리소스 사용량을 보여 줍니다

별칭이 아니라 전체 명령 이름 kubectl을 쓰세요.
```

```bash
./mock.sh 3 7 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl top -h
kubectl top pod -h | grep -A1 containers
echo 'kubectl top node' > /root/mock3/7/node.sh
echo 'kubectl top pod --containers=true' > /root/mock3/7/pod.sh
bash /root/mock3/7/node.sh; bash /root/mock3/7/pod.sh
```

</details>

### 3회 · Q8 – Kubernetes 버전 업데이트와 클러스터 조인  (클러스터 수명 주기 | 10%) – 필요할 때 셋업

```bash
./mock.sh 3 8
```

```text
동료가 노드 node01이 예전 Kubernetes 버전으로 돌고 있고 아직 클러스터에 들어와 있지도
않다고 알려 왔습니다.

1. node01의 kubelet과 kubectl을 컨트롤 플레인과 정확히 같은 버전으로 업데이트하세요
2. kubeadm으로 node01을 클러스터에 추가하세요

controlplane에서 ssh node01이 됩니다.
이 문제는 node01을 클러스터에서 빼므로 필요할 때 셋업합니다(./mock.sh 3 8).
./mock.sh 3 start 직후 맨 먼저 푸세요: 노드를 빼면 그 노드에서 컨트롤러가 다시 만들지 않는
Pod가 모두 지워지므로, 다른 문제를 위해 만든 Pod가 사라집니다.
```

```bash
./mock.sh 3 8 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl get node                                    # 컨트롤 플레인 버전, 예: v1.34.1
ssh node01
kubelet --version; kubectl version --client; kubeadm version -o short
kubeadm upgrade node                                # 실패: 노드가 클러스터에 속해 있지 않음 -> 업그레이드할 것 없음
apt-get update
apt-cache madison kubelet | grep 1.34.1              # 컨트롤 플레인 버전을 쓴다
apt-mark unhold kubelet kubectl
apt-get install -y kubelet=1.34.1-1.1 kubectl=1.34.1-1.1   # (kubeadm도 그 버전이 아니면 함께)
apt-mark hold kubelet kubectl
systemctl daemon-reload && systemctl restart kubelet # 노드가 조인될 때까지 crash-loop - 정상
exit
# controlplane에서: 토큰을 만들고 join 명령을 출력한다
kubeadm token create --print-join-command
ssh node01 "kubeadm join <...printed command...>"    # join이 오류를 내면 먼저 kubeadm reset -f 실행
kubectl get node                                     # node01 Ready, 같은 버전
```

</details>

### 3회 · Q9 – Pod 안에서 K8s API 호출  (보안 | 6%)

```bash
./mock.sh 3 9
```

```text
네임스페이스 project-swan에 ServiceAccount secret-reader가 있습니다.
그 네임스페이스에 이 ServiceAccount를 쓰는 Pod api-contact(이미지 nginx:1-alpine)를 만드세요.

Pod에 exec로 들어가서 curl로 Kubernetes API에서 (클러스터 전체의) 모든 Secret을 조회하세요.
결과를 controlplane의 /root/mock3/9/result.json에 쓰세요.
```

```bash
./mock.sh 3 9 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl -n project-swan run api-contact --image=nginx:1-alpine --dry-run=client -o yaml \
  --overrides='{"spec":{"serviceAccountName":"secret-reader"}}' | kubectl apply -f -
kubectl -n project-swan wait --for=condition=Ready pod/api-contact --timeout=60s
kubectl -n project-swan exec -it api-contact -- sh
  TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
  CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
  curl --cacert $CACERT https://kubernetes.default/api/v1/secrets -H "Authorization: Bearer $TOKEN" > /tmp/result.json
  # (curl -k ... 도 된다. 토큰이 없으면 system:anonymous가 되어 403을 받는다)
  exit
kubectl -n project-swan exec api-contact -- cat /tmp/result.json > /root/mock3/9/result.json
kubectl auth can-i list secrets --as system:serviceaccount:project-swan:secret-reader   # yes
```

</details>

### 3회 · Q10 – RBAC ServiceAccount Role RoleBinding  (보안 | 6%)

```bash
./mock.sh 3 10
```

```text
네임스페이스 project-hamster에 ServiceAccount processor를 만드세요. 새 ServiceAccount가
그 네임스페이스에서 Secret과 ConfigMap 생성만 할 수 있도록, 둘 다 processor라는 이름의
Role과 RoleBinding을 만드세요.
```

```bash
./mock.sh 3 10 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl -n project-hamster create sa processor
kubectl -n project-hamster create role processor --verb=create --resource=secret --resource=configmap
kubectl -n project-hamster create rolebinding processor --role processor --serviceaccount project-hamster:processor
A="--as system:serviceaccount:project-hamster:processor"
kubectl -n project-hamster auth can-i create secret $A      # yes
kubectl -n project-hamster auth can-i create configmap $A   # yes
kubectl -n project-hamster auth can-i create pod $A         # no
kubectl -n project-hamster auth can-i get configmap $A      # no
# 가능한 조합: Role+RoleBinding, ClusterRole+ClusterRoleBinding, ClusterRole+RoleBinding.
# Role+ClusterRoleBinding은 불가능하다.
```

</details>

### 3회 · Q11 – 모든 노드에 DaemonSet  (스케줄링 | 4%)

```bash
./mock.sh 3 11
```

```text
네임스페이스 project-tiger에 DaemonSet ds-important를 만드세요. 이미지는 httpd:2-alpine,
레이블은 id=ds-important와 uuid=18426a0b-5f59-4e10-923f-c0e078e82462입니다.
Pod는 cpu 10 millicore와 메모리 10 mebibyte를 요청해야 하고, 컨트롤 플레인을 포함한
모든 노드에서 실행되어야 합니다.
```

```bash
./mock.sh 3 11 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl -n project-tiger create deployment ds-important --image=httpd:2-alpine --dry-run=client -o yaml > 11.yaml
# 수정: kind를 DaemonSet으로, replicas/strategy/status 삭제, 레이블 지정, requests + toleration 추가
cat > 11.yaml <<'YAML'
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: ds-important
  namespace: project-tiger
  labels:
    id: ds-important
    uuid: 18426a0b-5f59-4e10-923f-c0e078e82462
spec:
  selector:
    matchLabels:
      id: ds-important
      uuid: 18426a0b-5f59-4e10-923f-c0e078e82462
  template:
    metadata:
      labels:
        id: ds-important
        uuid: 18426a0b-5f59-4e10-923f-c0e078e82462
    spec:
      tolerations:
      - key: node-role.kubernetes.io/control-plane
        effect: NoSchedule
      containers:
      - name: ds-important
        image: httpd:2-alpine
        resources:
          requests:
            cpu: 10m
            memory: 10Mi
YAML
kubectl apply -f 11.yaml
kubectl -n project-tiger get ds; kubectl -n project-tiger get pod -l id=ds-important -o wide
```

</details>

### 3회 · Q12 – 모든 노드에 Deployment  (스케줄링 | 6%)

```bash
./mock.sh 3 12
```

```text
네임스페이스 project-jaguar에서:
- 레플리카 3개짜리 Deployment deploy-important를 만드세요
- Deployment와 그 Pod에는 레이블 id=very-important가 있어야 합니다
- 첫 번째 컨테이너는 container1, 이미지 nginx:1-alpine
- 두 번째 컨테이너는 container2, 이미지 registry.k8s.io/pause:3.10
- 이 Deployment의 Pod는 한 노드에 언제나 하나만 실행될 수 있어야 합니다.
  topologyKey: kubernetes.io/hostname을 쓰세요

Killercoda에는 워커가 하나(그리고 taint가 걸려 있을 수 있는 컨트롤 플레인)뿐이라서
Pod 3개 중 일부는 Pending으로 남습니다. 정상입니다. 레플리카 수가 고정된 DaemonSet을 흉내 내는 것입니다.
```

```bash
./mock.sh 3 12 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl -n project-jaguar create deployment deploy-important --image=nginx:1-alpine --replicas=3 --dry-run=client -o yaml > 12.yaml
cat > 12.yaml <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deploy-important
  namespace: project-jaguar
  labels:
    id: very-important
spec:
  replicas: 3
  selector:
    matchLabels:
      id: very-important
  template:
    metadata:
      labels:
        id: very-important
    spec:
      containers:
      - name: container1
        image: nginx:1-alpine
      - name: container2
        image: registry.k8s.io/pause:3.10
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: id
                operator: In
                values: ["very-important"]
            topologyKey: kubernetes.io/hostname
      # affinity 대신 쓸 수 있는 방법:
      # topologySpreadConstraints:
      # - maxSkew: 1
      #   topologyKey: kubernetes.io/hostname
      #   whenUnsatisfiable: DoNotSchedule
      #   labelSelector:
      #     matchLabels:
      #       id: very-important
YAML
kubectl apply -f 12.yaml
kubectl -n project-jaguar get pod -o wide -l id=very-important   # 스케줄 가능한 노드마다 하나, 나머지는 Pending
kubectl -n project-jaguar describe pod <pending-pod> | grep FailedScheduling
```

</details>

### 3회 · Q13 – Gateway API Ingress  (서비스와 네트워킹 | 7%)

```bash
./mock.sh 3 13
```

```text
r500 팀은 Ingress(networking.k8s.io)를 Gateway API(gateway.networking.k8s.io) 방식으로
바꾸려 합니다. 예전 Ingress는 /root/mock3/13/ingress.yaml에 있습니다.

네임스페이스 project-r500에서 기존 Gateway main을 사용해서:
1. 예전 Ingress의 라우트를 그대로 옮긴 HTTPRoute traffic-director를 만드세요
2. 경로 /auto를 추가하세요. User-Agent 헤더가 정확히 "mobile"이면 mobile 백엔드로,
   그 밖에는 desktop 백엔드로 보내야 합니다

Gateway는 /root/mock3/13/gateway-url의 URL로 접속할 수 있습니다(r500.gateway는 /etc/hosts에 있음).
다음이 동작해야 합니다:
  U=$(cat /root/mock3/13/gateway-url)
  curl $U/desktop        -> Web Desktop App
  curl $U/mobile         -> Web Mobile App
  curl $U/auto -H "User-Agent: mobile"   -> Web Mobile App
  curl $U/auto           -> Web Desktop App
```

```bash
./mock.sh 3 13 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl get gatewayclass; kubectl -n project-r500 get gateway main -o yaml
cat <<'YAML' | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: traffic-director
  namespace: project-r500
spec:
  parentRefs:
  - name: main
  hostnames:
  - r500.gateway
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /desktop
    backendRefs:
    - name: web-desktop
      port: 80
  - matches:
    - path:
        type: PathPrefix
        value: /mobile
    backendRefs:
    - name: web-mobile
      port: 80
  - matches:
    - path:                 # path와 header가 한 match 항목에 있음 = 둘 다 일치해야 함
        type: PathPrefix
        value: /auto
      headers:
      - type: Exact
        name: user-agent
        value: mobile
    backendRefs:
    - name: web-mobile
      port: 80
  - matches:
    - path:                 # /auto의 나머지 전부
        type: PathPrefix
        value: /auto
    backendRefs:
    - name: web-desktop
      port: 80
YAML
U=$(cat /root/mock3/13/gateway-url)
curl $U/desktop; curl $U/mobile; curl $U/auto -H "User-Agent: mobile"; curl $U/auto
# "- path: ... - headers: ..." (리스트 항목 두 개)로 쓰면 OR가 된다 - 여기서는 틀림.
```

</details>

### 3회 · Q14 – 인증서 유효 기간 확인  (클러스터 수명 주기 | 2%)

```bash
./mock.sh 3 14
```

```text
1. openssl(또는 cfssl)로 kube-apiserver 서버 인증서가 언제까지 유효한지 확인하세요.
   만료 날짜를 /root/mock3/14/expiration에 쓰세요.
   그다음 kubeadm으로 만료 날짜 목록을 보고 둘이 같은 날짜인지 확인하세요.
2. kube-apiserver 서버 인증서를 갱신하는 kubeadm 명령을
   /root/mock3/14/kubeadm-renew-certs.sh에 쓰세요  (실행하지는 마세요)
```

```bash
./mock.sh 3 14 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
find /etc/kubernetes/pki | grep apiserver
openssl x509 -noout -text -in /etc/kubernetes/pki/apiserver.crt | grep -A2 Validity
openssl x509 -noout -enddate -in /etc/kubernetes/pki/apiserver.crt | cut -d= -f2 > /root/mock3/14/expiration
kubeadm certs check-expiration | grep apiserver          # 같은 날짜
echo "kubeadm certs renew apiserver" > /root/mock3/14/kubeadm-renew-certs.sh
```

</details>

### 3회 · Q15 – NetworkPolicy  (서비스와 네트워킹 | 6%)

```bash
./mock.sh 3 15
```

```text
침입자가 해킹된 backend Pod 하나를 통해 클러스터 전체에 들어왔습니다. 이를 막기 위해
네임스페이스 project-snake에 NetworkPolicy np-backend를 만들어서 backend-* Pod가 다음만 할 수 있게 하세요:
- 포트 1111로 db1-* Pod에 연결
- 포트 2222로 db2-* Pod에 연결
정책에는 Pod의 app 레이블을 쓰세요.

모든 Pod가 nginx를 실행하므로 kubectl -n project-snake exec POD -- curl -s POD_IP:PORT 로 시험할 수 있습니다.
변경 후에는 backend -> vault-* 포트 3333 연결이 더 이상 되면 안 됩니다.
```

```bash
./mock.sh 3 15 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl -n project-snake get pod -L app -o wide
cat <<'YAML' | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: np-backend
  namespace: project-snake
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Egress
  egress:
  - to:                     # 규칙 1: db1 AND 포트 1111
    - podSelector:
        matchLabels:
          app: db1
    ports:
    - protocol: TCP
      port: 1111
  - to:                     # 규칙 2: db2 AND 포트 2222
    - podSelector:
        matchLabels:
          app: db2
    ports:
    - protocol: TCP
      port: 2222
YAML
# 틀린 예: 규칙 하나에 셀렉터 둘과 포트 둘을 넣으면 = (db1 OR db2) AND (1111 OR 2222)
# -> backend가 db2:1111과 db1:2222에도 접속할 수 있게 된다.
kubectl -n project-snake exec backend-0 -- curl -s -m3 <db1-ip>:1111   # database one
kubectl -n project-snake exec backend-0 -- curl -s -m3 <vault-ip>:3333 # 타임아웃
```

</details>

### 3회 · Q16 – CoreDNS 설정 변경  (서비스와 네트워킹 | 5%)

```bash
./mock.sh 3 16
```

```text
1. 현재 CoreDNS 설정 YAML을 /root/mock3/16/coredns_backup.yaml에 백업하세요.
   이 파일로 빠르게 복구할 수 있어야 합니다.
2. CoreDNS 설정을 바꿔서 SERVICE.NAMESPACE.custom-domain이 SERVICE.NAMESPACE.cluster.local과
   똑같이 해석되게 하세요(cluster.local도 계속 동작해야 함)

이미지 busybox:1인 Pod에서 시험하세요 - 둘 다 IP 주소를 돌려줘야 합니다:
  nslookup kubernetes.default.svc.cluster.local
  nslookup kubernetes.default.svc.custom-domain
```

```bash
./mock.sh 3 16 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl -n kube-system get deploy,cm | grep coredns
kubectl -n kube-system get cm coredns -o yaml > /root/mock3/16/coredns_backup.yaml
kubectl -n kube-system edit cm coredns
#   kubernetes custom-domain cluster.local in-addr.arpa ip6.arpa {     <- 이 줄에 custom-domain 추가
kubectl -n kube-system rollout restart deploy coredns
kubectl -n kube-system get pod -l k8s-app=kube-dns          # Running이면 문법 오류 없음
kubectl run bb --image=busybox:1 -- sh -c 'sleep 1d'
kubectl exec bb -- nslookup kubernetes.default.svc.custom-domain
kubectl exec bb -- nslookup kubernetes.default.svc.cluster.local
# 필요하면 복구:
#   sed -E '/^  (resourceVersion|uid|creationTimestamp):/d' /root/mock3/16/coredns_backup.yaml | kubectl apply -f -
#   kubectl -n kube-system rollout restart deploy coredns
#   (파일을 그대로 적용하면 "the object has been modified"로 실패한다: 예전 resourceVersion이 들어 있기 때문)
```

</details>

### 3회 · Q17 – Pod의 컨테이너를 찾아 정보 확인  (트러블슈팅 | 3%)

```bash
./mock.sh 3 17
```

```text
네임스페이스 project-puma에 레이블 pod=container와 container=pod를 가진 Pod tigers-reunite
(이미지 httpd:2-alpine)를 만드세요. 어느 노드에서 실행되는지 알아낸 뒤 그 노드에 ssh로 접속해서
이 Pod에 속한 containerd 컨테이너를 찾으세요.

crictl을 사용해서:
1. 컨테이너 ID와 그 info.runtimeType을 controlplane의 /root/mock3/17/pod-container.txt에
   한 줄로 쓰세요:  <container-id> <runtimeType>
2. 컨테이너 로그를 controlplane의 /root/mock3/17/pod-container.log에 쓰세요
```

```bash
./mock.sh 3 17 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl -n project-puma run tigers-reunite --image=httpd:2-alpine --labels "pod=container,container=pod"
kubectl -n project-puma get pod tigers-reunite -o wide          # NODE, 예: node01
ssh node01
crictl ps | grep tigers-reunite                                 # 컨테이너 ID
crictl inspect <ID> | grep runtimeType                          # io.containerd.runc.v2
exit
echo "<ID> io.containerd.runc.v2" > /root/mock3/17/pod-container.txt
ssh node01 "crictl logs <ID>" > /root/mock3/17/pod-container.log 2>&1   # httpd는 stderr로 로그를 남긴다
```

</details>

### 3회 · Q18 – 미리 보기: ETCD 정보  (클러스터 아키텍처 | 3%)

```bash
./mock.sh 3 18
```

```text
controlplane에서 실행되는 etcd에 대해 다음을 알아내세요:
- 서버 개인 키 위치
- 서버 인증서 만료 날짜
- 클라이언트 인증서 인증이 켜져 있는지

다음 형식으로 /root/mock3/18/etcd-info.txt에 쓰세요:
  Server private key location: <path>
  Server certificate expiration date: <date>
  Is client certificate authentication enabled: <yes|no>
```

```bash
./mock.sh 3 18 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl -n kube-system get pod | grep etcd                      # static Pod
grep -E -- '--(key-file|cert-file|client-cert-auth)=' /etc/kubernetes/manifests/etcd.yaml
openssl x509 -noout -enddate -in /etc/kubernetes/pki/etcd/server.crt
cat > /root/mock3/18/etcd-info.txt <<TXT
Server private key location: /etc/kubernetes/pki/etcd/server.key
Server certificate expiration date: $(openssl x509 -noout -enddate -in /etc/kubernetes/pki/etcd/server.crt | cut -d= -f2)
Is client certificate authentication enabled: yes
TXT
```

</details>

### 3회 · Q19 – 미리 보기: kube-proxy iptables  (서비스와 네트워킹 | 4%)

```bash
./mock.sh 3 19
```

```text
kube-proxy가 동작하는지 확인하세요. 네임스페이스 project-lynx에서:
1. 이미지 nginx:1-alpine으로 Pod p2-pod를 만드세요
2. Pod를 클러스터 내부에 포트 3000 -> 80으로 노출하는 Service p2-service를 만드세요
3. 노드 controlplane의 iptables 규칙 중 Service p2-service에 해당하는 것을
   /root/mock3/19/iptables.txt에 쓰세요
4. Service를 지우고 그 iptables 규칙이 사라졌는지 확인하세요
```

```bash
./mock.sh 3 19 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl -n project-lynx run p2-pod --image=nginx:1-alpine
kubectl -n project-lynx expose pod p2-pod --name p2-service --port 3000 --target-port 80
kubectl -n project-lynx wait --for=condition=Ready pod/p2-pod --timeout=60s
sleep 5      # kube-proxy는 Pod가 Ready가 된 뒤 잠시 후에 DNAT 규칙을 쓴다 (그 전에는 "has no endpoints" REJECT 규칙 하나뿐)
kubectl -n project-lynx get pod,svc,endpointslice
crictl ps | grep kube-proxy; crictl logs <id> 2>&1 | grep -i proxier   # "Using iptables proxy"
iptables-save | grep p2-service
iptables-save | grep p2-service > /root/mock3/19/iptables.txt
kubectl -n project-lynx delete svc p2-service
iptables-save | grep p2-service                                        # 아무것도 없음
```

</details>

### 3회 · Q20 – 미리 보기: Service CIDR 변경  (서비스와 네트워킹 | 7%) – 필요할 때 셋업

```bash
./mock.sh 3 20
```

```text
1. 네임스페이스 default에 이미지 httpd:2-alpine으로 Pod check-ip를 만드세요
2. 이 Pod를 포트 80의 ClusterIP Service check-ip-service로 노출하세요. Service IP를 적어 두세요
3. 클러스터의 Service CIDR을 11.96.0.0/12로 바꾸세요
4. 같은 Pod에 두 번째 Service check-ip-service2를 만드세요 - 새 범위의 IP를 받아야 합니다

필요할 때 셋업합니다(./mock.sh 3 20): API 서버와 컨트롤러 매니저를 재시작합니다.
맨 마지막에 푸세요. 끝난 뒤에는 Killercoda 새 세션을 권장합니다.
```

```bash
./mock.sh 3 20 validate
```

<details>
<summary><b>풀이 보기</b></summary>

```bash
kubectl run check-ip --image=httpd:2-alpine
kubectl expose pod check-ip --name check-ip-service --port 80
kubectl get svc check-ip-service                       # 10.x IP
vim /etc/kubernetes/manifests/kube-apiserver.yaml      # --service-cluster-ip-range=11.96.0.0/12
watch crictl ps                                        # 새 kube-apiserver가 뜰 때까지 기다린다
vim /etc/kubernetes/manifests/kube-controller-manager.yaml   # --service-cluster-ip-range=11.96.0.0/12
# K8s 1.33부터 할당기는 ServiceCIDR 오브젝트를 쓴다 - 새 범위용으로 하나 추가한다:
cat <<'YAML' | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: ServiceCIDR
metadata:
  name: svc-cidr-new
spec:
  cidrs:
  - 11.96.0.0/12
YAML
kubectl delete servicecidr kubernetes --wait=false     # 아직 쓰는 Service가 있는 동안 Terminating으로 남음
kubectl expose pod check-ip --name check-ip-service2 --port 80
kubectl get svc                                        # check-ip-service2가 11.x IP를 받음
```

</details>
