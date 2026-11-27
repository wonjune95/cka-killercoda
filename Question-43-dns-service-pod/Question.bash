# Question 43 - DNS records of a Service and a Pod  (Services & Networking | Easy | 10 min)
# 한글: Service와 Pod의 DNS 이름을 nslookup으로 조회해 파일로 저장한다. (문서 25번)
#
# In namespace exercise-43:
# 1. Create a Pod nginx-resolver (image nginx) and expose it with a ClusterIP Service
#    nginx-resolver-service on port 80
# 2. From a temporary Pod with image busybox:1.28, look up the Service and the Pod with nslookup
#    and save the output to /root/CKA/nginx.svc and /root/CKA/nginx.pod
