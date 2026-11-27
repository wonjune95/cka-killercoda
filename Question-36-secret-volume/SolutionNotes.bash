kubectl -n exercise-36 get secret dotfile-secret
kubectl run secret-1401 -n exercise-36 --image=busybox --dry-run=client -o yaml --command -- sleep 4800 > secret-1401.yaml
# edit: container name secret-admin, add the volume and the mount. The finished file:
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
