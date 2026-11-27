# Question 32 - User certificate (CSR) + Role  (Cluster Architecture | Medium | 15 min)
# 한글: 사용자 john의 CSR을 제출·승인하고 Role/RoleBinding으로 Pod 권한을 준다. (문서 5번)
#
# The lab setup created a private key and a certificate signing request for the user john:
#   /root/exercise-32/john.key   /root/exercise-32/john.csr
#
# Tasks
# 1. Create a CertificateSigningRequest named john-developer from /root/exercise-32/john.csr
#    (signer kubernetes.io/kube-apiserver-client, usage client auth) and approve it
# 2. In namespace exercise-32 create a Role named developer that allows
#    create, list, get, update and delete on pods
# 3. Create a RoleBinding named developer-role-binding that grants the Role to the user john
# 4. Verify with kubectl auth can-i ... --as=john
