# Question 54 - Divide a node's resources between 3 Pods (with init containers)  (Workloads & Scheduling | Hard | 20 min)
# 한글: 원본 시험 11번. 한 노드의 자원을 Pod 3개에 균등하게 나눠 requests를 정하고, init 컨테이너와 컨테이너에 같은 값을 준다. (문서 16번)
#
# Namespace exercise-54 runs a WordPress application: Deployment wordpress, 3 replicas, all bound to
# the node node01. Its resource requests are too high, so not all Pods can run.
#
# Adjust the resource requests of the Deployment so that:
# 1. The resources of node01 are divided evenly between all 3 Pods
# 2. Each Pod gets a fair share of CPU and memory
# 3. Enough overhead is left to keep the node stable (other Pods run on node01 too)
# 4. The container and the init container use exactly the same requests
#    (you do not need to change resource limits)
# 5. Afterwards all 3 replicas are Running and Ready on node01
#
# Hint: temporarily scaling the Deployment to 0 replicas while you update the requests can help.
