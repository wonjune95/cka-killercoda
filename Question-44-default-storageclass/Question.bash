# Question 44 - New default StorageClass  (Storage | Medium | 10 min)
# 한글: 원본 시험 4번. 새 StorageClass를 만들어 클러스터 기본으로 지정한다. 기존 Deployment·PVC는 건드리지 않는다.
#
# 1. Create a new StorageClass named low-latency that uses the existing provisioner
#    rancher.io/local-path
# 2. Set its VolumeBindingMode to WaitForFirstConsumer (mandatory)
# 3. Make low-latency the default StorageClass of the cluster
# 4. Do NOT modify any existing Deployment or PersistentVolumeClaim
#    (namespace exercise-44 has some that use the current default class)
#
# ./lab.sh 44 cleanup removes low-latency and restores the original default class.
