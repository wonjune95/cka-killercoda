kubectl get pods -n cert-manager
kubectl get crd | grep cert-manager > /root/resources.yaml       # no -o !
cat /root/resources.yaml
kubectl explain certificate.spec.subject > /root/subject.yaml
cat /root/subject.yaml
# 참고: 화면에도 보면서 저장하려면 | tee /root/resources.yaml
#       CRD는 보통 오퍼레이터와 같이 설치된다: 오퍼레이터가 CR(Certificate 등)을 읽어 동작한다.
