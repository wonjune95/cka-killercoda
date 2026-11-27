# Question 45 - Reuse a retained PersistentVolume  (Storage | Medium | 15 min)
# 한글: 원본 시험 3번. 삭제된 MariaDB Deployment를 Retain된 PV를 재사용해 복구한다.
#
# A user accidentally deleted the MariaDB Deployment in namespace exercise-45. It used persistent
# storage. Restore it and reuse the existing PersistentVolume so the data is kept.
# The PersistentVolume exists and was retained for reuse (there is only one PV).
#
# 1. Create a PersistentVolumeClaim named mariadb in namespace exercise-45:
#      access mode ReadWriteOnce, storage 250Mi
# 2. Edit the MariaDB Deployment file /root/mariadb-deploy.yaml to use the PVC
# 3. Apply the edited Deployment file to the cluster
# 4. Make sure the MariaDB Deployment is running and stable
