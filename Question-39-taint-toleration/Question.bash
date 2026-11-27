# Question 39 - Taints and tolerations  (Workloads & Scheduling | Easy | 10 min)
# 한글: 워커에 taint를 걸고, 그 taint를 허용하는 Pod를 만든다. (문서 18번)
#
# 1. Add a taint to node01: key env_type, value production, effect NoSchedule
# 2. In namespace exercise-39 create a Pod prod-redis (image redis:alpine) that tolerates this taint
#
# ./lab.sh 39 cleanup removes the taint again - other labs need node01 schedulable.
