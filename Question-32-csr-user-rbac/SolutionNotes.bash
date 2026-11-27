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
