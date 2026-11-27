# Question 34 - Kustomize overlay: namespace, prefix, replicas, image  (Cluster Architecture | Medium | 15 min)
# 한글: base는 그대로 두고 prod 오버레이로 네임스페이스·접두사·레플리카·이미지 태그를 바꿔 배포한다. (문서 8번)
#
# /root/kustomize/base defines a Deployment web (nginx:1.26, 1 replica) and a Service web.
# Do NOT change the base. Create the overlay /root/kustomize/overlays/prod that:
#   - deploys everything to namespace exercise-34
#   - adds the name prefix prod- to every resource
#   - runs 3 replicas of the Deployment
#   - uses the nginx image tag 1.27
# Then deploy the overlay to the cluster.
