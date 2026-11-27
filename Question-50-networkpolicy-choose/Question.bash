# Question 50 - Pick the least-privilege NetworkPolicy  (Services & Networking | Medium | 15 min)
# 한글: 원본 시험 7번. 주어진 파일 중 frontend→backend 통신을 허용하는 가장 제한적인 정책 하나만 적용한다.
#
# Deployment frontend runs in namespace exercise-50-frontend, Deployment backend in namespace
# exercise-50-backend. They must be able to talk to each other (frontend -> backend).
#
# 1. Analyse the frontend and backend Deployments and find out what the communication needs
# 2. Choose ONE of the NetworkPolicy files in /root/netpol and apply it. It must
#    - allow the communication from frontend to backend
#    - be as restrictive as possible (least privilege)
# 3. Do NOT delete or change the existing deny-all NetworkPolicy
