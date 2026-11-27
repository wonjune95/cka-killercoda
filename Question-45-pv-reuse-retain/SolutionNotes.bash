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
  storageClassName: ""          # same as the PV (it has no class); "" stops the default class being added
  resources:
    requests:
      storage: 250Mi
EOF2
kubectl -n exercise-45 get pvc mariadb                # Bound to mariadb-pv
vi /root/mariadb-deploy.yaml                           # replace the emptyDir with:
#      volumes:
#      - name: mariadb-storage
#        persistentVolumeClaim:
#          claimName: mariadb
kubectl apply -f /root/mariadb-deploy.yaml
kubectl -n exercise-45 rollout status deployment mariadb
kubectl -n exercise-45 get pods,pvc
# 참고: PVC 의 storageClassName 은 PV 와 같아야 한다. PV 에 클래스가 없으면 "" 를 명시.
