# Question 41 - Service of type LoadBalancer  (Services & Networking | Easy | 10 min)
# 한글: LoadBalancer Service로 Deployment를 노출하고 엔드포인트를 확인한다. (문서 21번)
#
# In namespace exercise-41:
# 1. Create Deployment lb-web (image nginx, 2 replicas)
# 2. Expose it on port 80 with a Service lb-web-svc of type LoadBalancer
# 3. Verify the Service has both Pods as endpoints and answers on its NodePort
#
# Killercoda has no cloud load balancer, so EXTERNAL-IP stays <pending> - that is expected.
