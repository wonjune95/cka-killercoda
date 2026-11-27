# Question 51 - Add a logging sidecar to an existing Deployment  (Troubleshooting | Medium | 15 min)
# 한글: 원본 시험 12번. 기존 Deployment에 로그를 스트리밍하는 sidecar 컨테이너와 공유 볼륨을 추가한다. (문서 34번)
#
# A legacy app must be integrated into the Kubernetes built-in logging architecture (kubectl logs).
# Adding a streaming co-located container is a good and common way to do that.
#
# Namespace exercise-51 runs the Deployment synergy-deployment. Its container writes its log to the
# file /var/log/synergy-deployment.log inside the container.
#
# 1. Update the existing Deployment synergy-deployment: add a co-located container named sidecar,
#    using the busybox:stable image, to the existing Pod. The new container must run this command:
#      /bin/sh -c "tail -n+1 -f /var/log/synergy-deployment.log"
# 2. Use a Volume mounted at /var/log to make the log file synergy-deployment.log available to the
#    sidecar container
# 3. Do not modify the specification of the existing container other than adding the required
#    volume mount
