# Question 36 - Secret mounted as a volume  (Workloads & Scheduling | Easy | 10 min)
# 한글: 기존 Secret을 읽기 전용 볼륨으로 마운트하는 Pod를 만든다. (문서 13번)
#
# Namespace exercise-36 contains the Secret dotfile-secret.
# Create a Pod named secret-1401 in namespace exercise-36:
#   - image busybox, command: sleep 4800
#   - the container is named secret-admin (not the Pod name!)
#   - mount the Secret dotfile-secret as a volume named secret-volume, read-only, at /etc/secret-volume
