# CKA Killercoda 실습 랩 (연습 54문제 + 모의고사 3회)

[norbutlepcha25/CKA-Certified-Kubernetes-Administrator](https://github.com/norbutlepcha25/CKA-Certified-Kubernetes-Administrator)의
연습문제 31개와 모의고사 2회를 실습 랩으로 만든 저장소에, 한글 문제집(CKA 실습문제, 35문제) 가운데 랩이 없던 문제를
32~54번 랩으로 더했습니다. 문제마다 랩 셋업, 문제, 풀이, 자동 채점기가 있습니다.
Killercoda CKA 플레이그라운드(`controlplane` + `node01`, root 로그인) 기준으로 만들었습니다.

- `lab.sh`: 연습 랩 54개 실행 (아래 참고)
- `mock.sh`: 시간 제한 모의고사 3회 실행 ([모의고사](#모의고사) 참고)
- [GUIDE.md](GUIDE.md): 셋업 방법과 전체 104문제, 접어 둔 풀이를 한 파일에 모은 한글 문서

GUIDE.md는 문제·풀이까지 모두 한글입니다. 터미널에서 `./lab.sh`·`./mock.sh`로 보는 문제는 실제 시험처럼 영어로 두었습니다.

## Killercoda로 가져오기

Killercoda에는 파일 업로드가 없으므로 Killercoda 터미널에서 이 저장소를 clone합니다.

```bash
# Killercoda 터미널에서 (https://killercoda.com/playgrounds/scenario/cka)
git clone https://github.com/wonjune95/cka-killercoda.git
cd cka-killercoda
chmod +x lab.sh mock.sh lib/*.sh Question-*/*.sh Question-*/LabSetUp.bash Mock-Exam-*/*/*.sh Mock-Exam-*/*/LabSetUp.bash
./lab.sh list
./mock.sh list
```

## 사용법

```bash
./lab.sh 5              # 5번 랩 초기화 + 셋업 후 문제 출력
./lab.sh 5 question     # 문제 다시 보기
./lab.sh 5 validate     # 답 채점 (항목마다 [PASS]/[FAIL])
./lab.sh 5 solution     # 풀이 보기
./lab.sh 5 cleanup      # 랩과 내 답이 만든 것 정리
```

셋업을 다시 실행하면 항상 초기화되므로 같은 문제를 몇 번이든 다시 풀 수 있습니다.
파일을 직접 실행해도 됩니다. 예: `bash Question-05-networkpolicy/LabSetUp.bash`

## 폴더 구성

```
lab.sh                      연습 랩 실행기
mock.sh                     모의고사 실행기
GUIDE.md                    전체 문제와 풀이
lib/common.sh               공용 함수 (pass/fail, 노드 함수, node01 ssh)
lib/cri-backup.sh           node01의 kubelet 런타임 설정 파일 백업 (Q26, 모의 1 Q07)
lib/cri-reset.sh            node01을 containerd로 되돌림 (Q18, Q26, 모의 1 Q07)
Question-NN-주제/
  LabSetUp.bash             랩 초기화, 필요한 것 설치, 장애 문제는 일부러 고장 냄
  Question.bash             문제
  SolutionNotes.bash        풀이
  validate.sh               자동 채점
  cleanup.sh                이 문제가 만든 것 정리·복원
```

## 셋업이 설치하거나 바꾸는 것

| Q | 셋업 내용 | 세션 영향 |
|---|---|---|
| 09 | 두 노드에 다음 마이너 버전 apt 저장소 추가, 목표 버전을 `/root/upgrade-target.txt`에 기록 | 업그레이드는 되돌릴 수 없음 - 다시 하려면 새 세션 |
| 11 | node01의 kubelet 중지·비활성화, CoreDNS 고장 (오타 + 레플리카 0) | `cleanup`이 둘 다 복구 |
| 13 | Helm이 없으면 설치 | - |
| 15 | Envoy Gateway v1.5.4 + GatewayClass `eg` 설치 (NodePort) | 설치된 채로 남음 |
| 16 | metrics-server가 없으면 설치 | 설치된 채로 남음 |
| 18 | node01의 cri-dockerd 설치 흔적 초기화 | node01 런타임 설정이 바뀜 - 새 세션 권장 |
| 19 | ingress-nginx controller-v1.13.3 설치 (NodePort), IngressClass `nginx` | 설치된 채로 남음 |
| 23 | 노드에 비해 requests가 너무 큰 Deployment 생성 | - |
| 25 | 모든 노드에 `/tmp/k8s-pv` 생성 | - |
| 26 | node01에 `/root/cri-dockerd.deb` 다운로드, kubelet 설정 파일 백업 | `cleanup`이 node01을 containerd로 되돌림 |
| 27 | **클러스터 CNI 제거** (`yes` 입력 필요, `CKA_LAB_YES=1`이면 묻지 않음) | 새 세션에서 단독으로 |
| 28 | frontend/backend/database 네임스페이스와 앱 생성 | - |
| 29 | kube-apiserver의 etcd 주소를 틀리게 바꿈 (백업은 `/root/.cka-lab/`) | `cleanup`이 매니페스트 복원 |
| 30 | TLS 1.3만 허용하는 nginx Deployment 생성 | - |
| 31 | 이전 Argo CD 설치 제거 | Argo CD는 RAM 약 1.5GB 필요 |
| 33 | Helm이 없으면 설치, Argo CD CRD(v3.1.8) 설치, `argo` 저장소와 Argo CD 릴리스 제거 | RAM 약 1.5GB. 31번과 `argocd` 네임스페이스를 같이 써서 서로의 셋업이 상대를 지움 |
| 35 | cert-manager v1.19.1이 없으면 설치 | `cleanup`이 다시 제거 (이 랩이 설치한 경우만) |
| 37 | metrics-server가 없으면 설치 | 설치된 채로 남음 |
| 39 | 답을 풀면 node01에 taint(`env_type=production:NoSchedule`)가 생김 | `cleanup`이 taint 제거 - 다른 랩 전에 꼭 실행 |
| 40 | 답을 풀면 node01에 `disktype=ssd` 레이블이 생김 | `cleanup`이 레이블 제거 |
| 42 | Envoy Gateway v1.5.4 + GatewayClass `eg` 설치 (15번과 같음) | 설치된 채로 남음 |
| 44 | `local-path`를 기본 StorageClass로 지정 (필요하면 local-path-provisioner v0.0.32 설치) | `cleanup`이 원래 기본 클래스로 복원 |
| 46 | admin.conf를 포트를 틀리게 바꿔 `/root/CKA/admin.kubeconfig`로 복사 | - |
| 53 | PriorityClass `user-low`·`user-medium`·`user-critical` 생성, `high-priority` 삭제 (22·24번과 같은 이름을 씀) | `cleanup`이 모두 삭제 |
| 54 | node01에 묶인 Deployment `wordpress`를 requests가 너무 크게 생성 (Pod 일부가 Pending) | - |

팁: 되돌리기 어려운 랩(09, 18, 26, 27)은 세션 마지막에 하거나 각각 새 세션에서 하세요.

## 32~54번 랩 (한글 문제집에서 추가)

`CKA_실습문제`에서 랩이 없던 문제를 옮겼습니다. "원본"은 문제집 안의 실제 시험 문제지에서 온 문제입니다.
문제집의 원본 16문제는 모두 대응하는 랩이 있습니다 (표에 없는 원본: 1번 → 26, 9번 → 27, 12번 → 30, 22번 → 19와 모의 1회 Q10, 31번 → 29).

| 랩 | 주제 | 문제집 | 랩 | 주제 | 문제집 |
|---|---|---|---|---|---|
| 32 | 사용자 CSR + Role | 5 | 44 | 새 기본 StorageClass | 26 (원본) |
| 33 | Argo CD: helm template + CRD 없이 설치 | 7 (원본) | 45 | Retain된 PV 재사용 | 28 (원본) |
| 34 | Kustomize 네임스페이스·접두사·레플리카·이미지 | 8 | 46 | 고장 난 kubeconfig | 30 |
| 35 | CRD 목록(기본 출력) + explain | 10 (원본) | 47 | 실패하는 init 컨테이너 | 33 |
| 36 | Secret을 읽기 전용 볼륨으로 | 13 | 48 | Service 셀렉터 / targetPort | 35 |
| 37 | 스케일 다운 안정화 윈도우가 있는 HPA | 14 (원본) | 49 | HA 컨트롤 플레인 (명령만) | 3 |
| 38 | liveness / readiness 프로브 | 15 | 50 | 최소 권한 NetworkPolicy 고르기 | 24 (원본) |
| 39 | taint + toleration | 18 | 51 | 기존 Deployment에 로깅 sidecar 추가 | 34 (원본) |
| 40 | node affinity | 19 | 52 | 기존 Deployment 포트 노출 + NodePort Service | 20 (원본) |
| 41 | LoadBalancer Service | 21 | 53 | 최댓값보다 1 작은 PriorityClass + patch | 17 (원본) |
| 42 | TLS Ingress → Gateway API | 23 (원본) | 54 | 노드 자원을 Pod 3개에 분배 (init 컨테이너 포함) | 16 (원본) |
| 43 | Service / Pod DNS 레코드 | 25 | | | |

26번은 원본 시험 문제(문제집 1번)처럼 sysctl 설정 4개도 요구하고, 27번은 원본(문제집 9번)처럼 Flannel과 Calico 중
요구 사항에 맞는 CNI를 고르는 형태입니다.

## 시험 범위 대응표 (CKA 커리큘럼 v1.37)

[CNCF 커리큘럼 v1.37](https://github.com/cncf/curriculum)의 항목마다 연습할 수 있는 랩과 모의고사 문제입니다 (2026-11-27 확인,
시험 환경도 Kubernetes v1.37). `1-Q04`는 모의고사 1회 Q04를 뜻합니다.

| 영역 (비중) | 커리큘럼 항목 | 연습 랩 | 모의고사 |
|---|---|---|---|
| 스토리지 (10%) | StorageClass와 동적 볼륨 프로비저닝 | 25, 44 | 1-Q12, 2-Q14 |
| | 볼륨 유형·접근 모드·회수 정책 | 12, 25, 45 | 1-Q04 |
| | PV·PVC 관리 | 07, 12, 45 | 3-Q06 |
| 트러블슈팅 (30%) | 클러스터·노드 장애 해결 | 11, 46 | 2-Q10, 3-Q08 |
| | 클러스터 컴포넌트 장애 해결 | 11, 29 | 1-Q11, 2-Q05 |
| | 클러스터·애플리케이션 리소스 사용량 모니터링 | 16, 23, 54 | 1-Q09, 3-Q07 |
| | 컨테이너 출력 스트림(로그) 관리·평가 | 02, 47, 51 | 1-Q01, 1-Q15, 3-Q17 |
| | 서비스·네트워킹 장애 해결 | 11, 48 | 2-Q01, 3-Q19 |
| 워크로드와 스케줄링 (15%) | 배포, 롤링 업데이트·롤백 | 06 | 2-Q02 |
| | ConfigMap·Secret으로 애플리케이션 구성 | 03, 30, 36 | 1-Q01, 2-Q03, 2-Q06 |
| | 워크로드 오토스케일링 | 16, 37 | 1-Q09, 3-Q05 |
| | 자가 복구되는 배포의 기본 요소 | 07, 10, 21, 38 | 2-Q09, 2-Q11, 3-Q03 |
| | Pod admission·스케줄링 (limits, node affinity 등) | 20, 22, 23, 24, 39, 40, 53, 54 | 1-Q13, 1-Q14, 2-Q04, 2-Q07, 2-Q13, 2-Q15, 3-Q04, 3-Q11, 3-Q12 |
| 클러스터 아키텍처·설치·구성 (25%) | RBAC 관리 | 04, 32 | 1-Q02, 3-Q09, 3-Q10 |
| | 클러스터 설치를 위한 기반 인프라 준비 | 18, 26 | 1-Q07 |
| | kubeadm으로 클러스터 생성·관리 | 49 | 3-Q08 |
| | 클러스터 수명 주기 관리 | 08, 09 | 1-Q03, 2-Q10, 3-Q14 |
| | 고가용성 컨트롤 플레인 | 49 | - |
| | Helm·Kustomize로 클러스터 구성요소 설치 | 13, 14, 33, 34 | 1-Q06, 3-Q02, 3-Q05 |
| | 확장 인터페이스 (CNI, CSI, CRI) | 18, 26, 27, 44 | 1-Q07, 3-Q17 |
| | CRD 이해, 오퍼레이터 설치·구성 | 31, 35 | 2-Q12, 3-Q02 |
| 서비스와 네트워킹 (20%) | Pod 간 연결 | 05, 27, 28 | 3-Q15 |
| | NetworkPolicy 정의·적용 | 05, 28, 50 | 1-Q05, 3-Q15 |
| | ClusterIP·NodePort·LoadBalancer와 엔드포인트 | 41, 48, 52 | 2-Q08, 3-Q19, 3-Q20 |
| | Gateway API로 인그레스 트래픽 관리 | 15, 42 | 3-Q13 |
| | Ingress 컨트롤러와 Ingress 리소스 | 19 | 1-Q10 |
| | CoreDNS | 11, 43 | 2-Q01, 3-Q16 |

2노드 플레이그라운드에서 직접 만들어 볼 수 없는 것: `kubeadm init`으로 새 클러스터 만들기와 HA 컨트롤 플레인(49번은 명령만 연습).
이 둘은 kubernetes.io의 "Creating a cluster with kubeadm", "Creating Highly Available Clusters with kubeadm" 문서를 한 번 읽어 두세요.

## 기존 랩과 모의고사 수정 사항

- Q26 / 모의 1 Q07: 셋업이 `kubeadm-flags.env`, `config.yaml`, `/etc/default/kubelet`를 모두 백업하고, cleanup이 답에서 바꾼
  파일을 복원합니다 (전에는 `config.yaml`로 답하면 node01이 NotReady로 남았음). 백업은 실행마다 새로 받습니다. Q26 채점도 `config.yaml`을 읽습니다.
- Q09: 같은 주소의 apt 저장소가 이미 있으면 추가하지 않습니다 (다른 키로 중복 등록되면 두 노드의 apt가 망가졌음). cleanup이 추가한 저장소를 지웁니다.
- Q29: 셋업은 정상인 매니페스트만 백업하고, cleanup은 etcd 주소 말고 달라진 게 없을 때만 복원합니다.
- Q10: 파일 이름과 상관없이 `static-web`을 정의한 매니페스트를 인정하고, cleanup도 그 파일을 지웁니다.
- Q20: `runAsNonRoot`를 Pod와 컨테이너 양쪽에 써도 되고, `runAsUser: 1000`도 채점합니다.
- 모의 2 Q02: revision마다 change-cause가 제자리에 붙습니다 (전에는 한 칸씩 밀렸음).
- 모의 2 Q11: drain에 `--pod-selector=app=my-app`을 씁니다. 그냥 drain하면 다른 문제의 Pod에서 멈췄고 `--force`는 그 Pod를 지웠음.
- 모의 3 Q08: `start` 직후 맨 먼저 풉니다 (node01을 빼면 컨트롤러 없는 Pod가 삭제됨). Q15의 Pod는 이름이 같은 StatefulSet으로 바꿔 Q08을 거쳐도 남습니다.
- 모의 3 Q16: 백업 확인과 복원 방법 모두 `resourceVersion`/`uid`를 지운 뒤 apply합니다.
- Q11: kubelet을 고치기 전에 채점을 두 번 돌리면 멈추던 문제를 고쳤습니다 (죽은 노드에 남은 테스트 Pod를 강제 삭제).
- Q10, Q15: 채점이 static Pod 삭제와 Gateway `Programmed`를 잠시 기다립니다 (바로 채점하면 FAIL이 나던 문제).
- Q35: kubectl 1.37의 `kubectl get crd` 출력(SCOPE·VERSIONS 열 추가)도 기본 형식으로 인정합니다.
- 모의 3 Q09: 채점이 python3 없이도 동작합니다. Q09·Q19 풀이에 Pod 준비를 기다리는 줄을 넣었습니다.

## 원래 연습문제에서 바꾼 점

원래 문장은 되도록 그대로 두었습니다. 모든 랩을 실행하고 채점할 수 있도록 다음을 바꿨습니다.

- 문제가 정하지 않은 이름을 정했습니다 (예: Q08 Deployment `drain-test`, Q21 Job `manual-backup`,
  Q14 `/root/kustomize-lab`, Q30 Service `tls-web`, Q31 `/root/argocd-app.yaml`).
- Q11, Q23, Q29, Q30: 문제가 말하는 고장·시작 상태를 셋업이 만듭니다.
- Q20: audit 네임스페이스는 audit + warn만 씁니다. 원래는 `enforce=restricted`도 있어서, 문제에서 성공해야 한다는 privileged Pod가 거부됐습니다.
- Q24: busybox Deployment가 `sleep 3600`을 실행합니다. 그냥 busybox는 바로 종료돼 crash-loop에 빠집니다.
- Q26: systemd 유닛 이름은 `cri-dockerd`가 아니라 `cri-docker.service` / `cri-docker.socket`이고, kubelet 전환은 `/var/lib/kubelet/kubeadm-flags.env`에서 합니다.
- Q27: Installation 리소스를 고쳤습니다. 원래는 엉뚱한 `pointerSize: Felix` 줄이 있었습니다.
- Q28: 풀이는 default-deny + 명시적 egress를 씁니다. 원래의 DNS만 허용하는 egress 정책은 frontend → backend를 막았습니다.
- 이미지와 버전은 지금 존재하는 것으로 고정했습니다 (Calico v3.30.3, Argo CD v3.1.9, Envoy Gateway v1.5.4).
- Q13: Bitnami가 2025년에 무료 이미지 대부분을 옮겼습니다. Pod가 ImagePullBackOff에 머물면 풀이의 `bitnamilegacy` 설정을 쓰세요. Helm 채점은 그래도 통과합니다.

## 모의고사

원본 저장소의 모의고사 2회(`mock-exams/MOCK-EXAM-01.md`, `MOCK-EXAM-02.md`)도 랩으로 만들었습니다.
회마다 15문제, 120분, 합격선 66%(10/15)입니다. 모든 문제와 풀이는 GUIDE.md에 있습니다.

```bash
./mock.sh list
./mock.sh 1 start            # 15문제 모두 셋업하고 120분 타이머 시작 (90분이면 ./mock.sh 1 start 90)
./mock.sh 1 questions        # 전체 문제 다시 보기
./mock.sh 1 time             # 남은 시간
./mock.sh 1 score            # 전체 채점 -> "Score: 12/15 (80%)"
./mock.sh 1 solutions        # 전체 풀이 (시험 뒤에)
./mock.sh 1 cleanup          # 1회가 만든 것 모두 정리

./mock.sh 2 7                # 2회 7번만 셋업·초기화하고 출력
./mock.sh 2 7 validate       # 그 문제만 채점
./mock.sh 2 7 solution
./mock.sh 2 7 cleanup
```

문제가 요구하는 답 파일은 `/root/mock1/`, `/root/mock2/`에 둡니다.
일부 문제가 컨트롤 플레인을 바꾸므로 모의고사마다 새 Killercoda 세션을 쓰세요.
같은 세션에서 다음 회를 시작한다면 먼저 `./mock.sh N cleanup`으로 이전 회를 정리하세요.

| 회 · Q | 셋업 내용 / 세션 영향 |
|---|---|
| 1 · Q03 | 답을 풀면 node01이 cordon 상태로 남음 - uncordon 전까지 새 Pod는 컨트롤 플레인에만 감 |
| 1 · Q06 | Helm이 없으면 설치, `/root/helm-charts/monitoring`에 차트 작성 |
| 1 · Q07 | node01에 docker.io + cri-dockerd v0.3.20 설치 (1~2분). 답을 풀면 node01이 Docker로 바뀜. `./mock.sh 1 7 cleanup`이 되돌림 |
| 1 · Q08 | kube-apiserver 매니페스트 원본을 `/root/.cka-lab/kube-apiserver.pristine.yaml`에 보관. 답을 풀면 API 서버가 재시작됨. `cleanup`이 원본 복원 |
| 1 · Q09 | metrics-server가 없으면 설치 |
| 1 · Q10 | ingress-nginx controller-v1.13.3(NodePort)이 없으면 설치 |
| 1 · Q11 | **kube-scheduler를 고장 냄.** `start`는 건너뜀 - 이 문제에 도달하면 `./mock.sh 1 11` 실행. `cleanup`이 매니페스트 복원 |
| 1 · Q12, 2 · Q14 | `rancher.io/local-path` 프로비저너와 StorageClass `local-path` 준비 (필요하면 local-path-provisioner v0.0.32 설치) |
| 2 · Q04 | 컨트롤 플레인에 기본 kubeadm taint `node-role.kubernetes.io/control-plane:NoSchedule`가 없으면 추가, `cleanup`이 다시 제거 |
| 2 · Q05 | **API 서버 audit 로그를 켬** (API 서버 재시작, 1~2분). `cleanup`이 원본 매니페스트 복원 (1 · Q08과 공유) |
| 2 · Q10 | 답을 풀면 컨트롤 플레인 인증서가 갱신되고 static Pod가 재시작됨 (되돌릴 수 없지만 무해) |
| 2 · Q11 | 답을 풀면 node01이 drain됨. 문제 마지막에 uncordon |

### 모의고사 3회 (Killer Shell 스타일)

`Mock-Exam-03/`에는 Killer Shell CKA 시뮬레이터 주제를 본뜬 20문제(17 + "preview" 3)가 있습니다:
kubeconfig 컨텍스트, Helm + cert-manager CRD, StatefulSet 스케일, QoS 클래스, Kustomize + HPA, PV/PVC, `kubectl top`,
kubeadm 업그레이드 + 노드 조인, Pod에서 API 호출, RBAC, DaemonSet / 노드당 Pod 하나 스케줄링, Gateway API HTTPRoute,
인증서 만료, NetworkPolicy, CoreDNS, crictl, etcd 정보, kube-proxy iptables, Service CIDR 변경.
Killercoda에 맞게 다시 썼고, 전체 문제와 풀이는 GUIDE.md에 있습니다.

```bash
./mock.sh 3 start            # 18문제 셋업, Q08과 Q20은 필요할 때 따로
./mock.sh 3 score            # 합격선 66% (14/20)
```

답 파일은 `/root/mock3/`에 둡니다.

| 회 · Q | 셋업 내용 / 세션 영향 |
|---|---|
| 3 · Q02 | Helm이 없으면 설치하고 jetstack 저장소 추가. 답을 풀면 cert-manager가 설치됨 (`cleanup`이 CRD까지 제거) |
| 3 · Q05, Q07 | metrics-server가 없으면 설치 |
| 3 · Q08 | **node01을 클러스터에서 뺌** (kubeadm reset) 그리고 kubelet/kubectl을 한 마이너 버전 낮춤. `./mock.sh 3 8`로 따로 셋업 - `start` 직후 맨 먼저 풀 것 (노드를 빼면 컨트롤러 없는 Pod가 삭제됨). `cleanup`이 컨트롤 플레인 버전으로 node01을 다시 조인 |
| 3 · Q13 | Envoy Gateway v1.5.4 + GatewayClass `eg` 설치 (NodePort, 연습 15번과 같음), `/etc/hosts`에 `r500.gateway` 추가 |
| 3 · Q15 | NetworkPolicy를 적용하는 CNI가 필요 (Killercoda 플레이그라운드는 됨) |
| 3 · Q16 | 원래 Corefile 저장, `cleanup`이 복원 |
| 3 · Q20 | **Service CIDR 변경** (kube-apiserver와 kube-controller-manager 재시작). `./mock.sh 3 20`으로 따로 셋업. `cleanup`이 두 매니페스트 복원, 이후엔 새 세션 권장 |

Q20에는 Kubernetes 1.33 이상이 필요합니다 (ServiceCIDR API).

### 원래 모의고사에서 바꾼 점

원래 문제는 동작하는 한 그대로 두었습니다. 문제나 공개된 풀이가 틀렸거나 채점할 수 없으면 다음처럼 바꿨습니다.

- 자동 채점을 위해 모든 문제에 오브젝트·네임스페이스·답 파일 이름을 정했습니다.
- 1회 Q03: 원래는 database Pod를 축출하지 말고 노드를 drain하라면서 풀이는 `--force`(그 Pod를 지움)를 썼습니다. 랩에는 emptyDir 데이터를 쓰는 단독 `database` Pod가 있고, 답은 cordon 후 web Pod만 옮기는 것입니다.
- 1회 Q04: 풀이가 GKE 프로비저너, 없는 명령 `kubectl create pvc`, OpenShift `oc` 명령인 `kubectl set volume`을 썼습니다. 랩은 StorageClass `fast-ssd`(`kubernetes.io/no-provisioner`)와 정적 hostPath PV를 씁니다.
- 1회 Q05: 풀이의 NetworkPolicy가 ingress 규칙 바로 아래에 `protocol`을 두었고(잘못된 형식), frontend 정책에 `ports`가 없었습니다. 고쳤습니다.
- 1회 Q07: 풀이가 kubelet의 kubeconfig인 `/etc/kubernetes/kubelet.conf`를 고쳤습니다. 런타임 플래그는 `/var/lib/kubelet/kubeadm-flags.env`(또는 `/var/lib/kubelet/config.yaml`의 `containerRuntimeEndpoint`)에 있습니다.
- 1회 Q08: 풀이가 audit 로그를 JSON 배열(`jq '.[]'`)로 읽었습니다. 실제로는 JSON lines입니다. 찾을 대상이 있도록 ConfigMap을 읽는 클라이언트를 추가했습니다.
- 1회 Q10: "health 엔드포인트는 TLS가 필요 없어야 한다"가 풀이와 맞지 않았습니다. HTTP `/health`는 리다이렉트되지 않아야 한다는 구체적인 요구로 바꾸고, `ssl-redirect: "false"`인 두 번째 Ingress로 풉니다.
- 1회 Q11: 고칠 대상이 있도록 랩이 scheduler를 고장 냅니다 (kubeconfig 경로 오류).
- 1회 Q13: 2 CPU / 2Gi Pod는 4 CPU / 8Gi 쿼터에 들어가서 거부되지 않습니다. 테스트 Pod는 6 CPU / 4Gi입니다. `kubectl run --requests`는 1.24에서 없어져 풀이는 `--overrides`를 씁니다.
- 1회 Q14: 예상 오류가 PodSecurityPolicy(1.25에서 제거)를 언급했고, restricted에 읽기 전용 루트 파일시스템이 필요하다고 했습니다(필요 없음). 고쳤습니다.
- 1회 Q15: `tail -f`는 로그 파일이 아직 없으면 종료됩니다. 랩은 `tail -F`를 씁니다.
- 2회 Q01: 풀이가 nginx 이미지에서 `wget`을 썼습니다(설치돼 있지 않음). 랩은 busybox를 씁니다.
- 2회 Q04: `datadog/agent:latest`는 1GB가 넘고 API 키도 필요합니다. 랩은 busybox를 씁니다.
- 2회 Q05: "명령을 제시하라"를 구체적인 작업(로그 저장, 포트, readyz, audit 로그에서 요청을 많이 보내는 클라이언트 찾기, 중지)으로 바꿨습니다. kube-apiserver는 static Pod라 `journalctl`로 볼 systemd 유닛이 없습니다.
- 2회 Q06: 볼륨 마운트는 재시작 없이 갱신되고, 환경 변수는 rollout restart가 필요하다는 두 경우를 모두 보여 줍니다.
- 2회 Q07: 풀이가 `globalDefault: true`를 썼습니다(클러스터의 모든 새 Pod가 바뀜). 랩은 두 클래스 모두 기본값이 아니고, 축출 순서는 kubelet의 실제 순위 설명과 함께 파일로 답합니다.
- 2회 Q08: `nodePort: 8080`은 NodePort 범위(30000-32767) 밖이라 거부됩니다. 랩은 서비스 포트 8080, targetPort 3000, nodePort 30080을 씁니다.
- 2회 Q09: `backup-tool:latest`는 없는 이미지라 busybox를 씁니다. "다시 시작"은 CronJob에서 수동 Job을 만드는 것으로 바꿨습니다.
- 2회 Q10: `systemctl restart kubelet`이나 미러 Pod 삭제로는 static Pod 컨테이너가 재시작되지 않습니다. 풀이는 매니페스트를 뺐다가 다시 넣고 :6443이 내보내는 인증서를 확인합니다.
- 2회 Q13: Pod Security Admission에는 Pod 단위 예외 레이블이 없습니다 (Pod의 `pod-security.kubernetes.io/exempt`는 아무 효과 없음). 랩은 baseline을 적용하는 별도 네임스페이스에서 root Pod를 실행하고, 풀이가 AdmissionConfiguration 예외를 설명합니다.
- 2회 Q14: GKE CSI 드라이버 대신 local-path 프로비저너를 씁니다.
- 2회 Q15: `kubectl run --requests` 대신 `--overrides`를 쓰고, 테스트 Pod가 LimitRange 최대값을 넘게 했습니다.

## 테스트 현황

### 전체 테스트 (2026-11-27, Kubernetes v1.37.0 = 현재 CKA 시험 버전)

Killercoda처럼 꾸민 2노드 kind 클러스터(컨트롤 플레인 taint 없음, 컨트롤 플레인에 root 로그인, 워커로 `ssh`)에서 문제마다
셋업 → 채점(풀기 전) → **공개된 풀이 그대로 실행** → 채점 → cleanup 순서로 돌렸습니다. `vi`·`kubectl edit`·`watch`·대화형 `ssh`
단계만 같은 결과를 내는 명령으로 바꿨습니다. 모의고사는 `./mock.sh N start` → 전 문제 풀이 → `./mock.sh N score` 흐름 그대로입니다.

| 대상 | 풀기 전 | 풀이 후 |
|---|---|---|
| 연습 01~08, 10~17, 19~25, 28~54 (50개) | 전부 FAIL (2단계로 채점하는 10번만 예외) | 전부 PASS |
| 모의 1회 | 0/15 | 14/15 (Q07은 kind에서 실행 불가) |
| 모의 2회 | 0/15 | 15/15 |
| 모의 3회 | 0/20 | 19/20 (Q08은 kind에서 실행 불가) |

`./mock.sh N cleanup` 뒤 클러스터가 원래대로 돌아오는 것도 확인했습니다 (노드 Ready, kube-apiserver 매니페스트·Service CIDR·taint 복원).

kind에서 통째로 돌릴 수 없어 Killercoda에서 확인이 필요한 것: 연습 09(kubeadm 업그레이드), 18·26과 모의 1회 Q07(cri-dockerd),
27(CNI 교체), 모의 3회 Q08(노드 재조인). 이 가운데 09번의 apt 저장소 로직과 cri-dockerd 백업·복원 로직은 따로 떼어 검증했고,
이 랩들이 내려받는 파일(cri-dockerd deb·tgz, Calico·Flannel 매니페스트, pkgs.k8s.io 저장소)은 모두 응답합니다.

이 테스트에서 찾아 고친 것은 위 [기존 랩과 모의고사 수정 사항](#기존-랩과-모의고사-수정-사항)에 있습니다. 그 밖에:

- 31번 뒤에 33번을 하면 `helm install`이 실패하던 문제: 31번 cleanup이 Argo CD의 ClusterRole·ClusterRoleBinding을 남겼습니다. 두 랩의 cleanup이 지웁니다.
- HPA 풀이의 `kubectl autoscale --cpu-percent=70`을 kubectl 1.37 형식인 `--cpu=70%`로 바꿨습니다 (예전 플래그는 deprecated 경고가 나옵니다).

### 원본 저장소의 테스트 (Kubernetes v1.35.1)

원본 저장소는 같은 방식의 kind 클러스터(v1.35.1, arm64)에서 연습 01-08, 10-17, 19-25, 28-30과 모의 1회(Q07 제외)·2회를 통과시켰고,
그때 다음을 고쳤습니다.

- Q19와 모의고사의 ingress 셋업: ingress-nginx admission webhook이 응답할 때까지 기다립니다. 설치 직후에는 Deployment가 Available이어도 webhook이 연결을 거부해서 첫 Ingress가 실패했습니다.
- Q24 채점: 아직 종료 중인 이전 ReplicaSet의 Pod를 새 Pod 대신 검사할 수 있었습니다.
- Q12, Q25 풀이: `kubectl exec` 전에 Pod가 Ready가 될 때까지 기다립니다.

잘못된 [FAIL]이 나오면 이슈로 알려 주세요.
