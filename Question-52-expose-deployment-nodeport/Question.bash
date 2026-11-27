# Question 52 - Expose an existing Deployment: container port + NodePort Service  (Services & Networking | Easy | 10 min)
# 한글: 원본 시험 8번. 기존 Deployment의 컨테이너 포트를 선언하고 NodePort Service로 노출한다. (문서 20번)
#
# Namespace exercise-52 runs the Deployment front-end (container nginx).
#
# 1. Reconfigure the existing Deployment front-end to expose port 80/tcp of the existing container nginx
# 2. Create a new Service named front-end-svc exposing the container port 80/tcp
# 3. Configure the new Service to also expose the individual Pods via a NodePort
