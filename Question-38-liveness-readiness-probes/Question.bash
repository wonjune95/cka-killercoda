# Question 38 - Liveness and readiness probes  (Workloads & Scheduling | Easy | 10 min)
# 한글: readiness·liveness 프로브가 있는 Deployment를 만들고 자가 복구를 확인한다. (문서 15번)
#
# In namespace exercise-38 create Deployment probe-web (image nginx, 2 replicas) whose container has:
#   - readinessProbe: HTTP GET / on port 80, initialDelaySeconds 5, periodSeconds 5
#   - livenessProbe:  HTTP GET / on port 80, initialDelaySeconds 10, periodSeconds 10, failureThreshold 3
# Delete one Pod and check that the Deployment brings the replica count back to 2 by itself.
