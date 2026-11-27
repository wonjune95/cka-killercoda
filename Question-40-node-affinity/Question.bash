# Question 40 - Node affinity (required + preferred)  (Workloads & Scheduling | Medium | 10 min)
# 한글: 노드 레이블을 붙이고 required·preferred node affinity를 가진 Pod를 만든다. (문서 19번)
#
# 1. Add the label disktype=ssd to node01
# 2. In namespace exercise-40 create a Pod affinity-pod (image nginx) that
#    - may only be scheduled on nodes with the label disktype=ssd (required node affinity)
#    - prefers nodes with the label zone=a (preferred node affinity, weight 50)
#
# ./lab.sh 40 cleanup removes the label again.
