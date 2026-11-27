# Question 53 - PriorityClass one below the highest + patch a Deployment  (Workloads & Scheduling | Medium | 10 min)
# 한글: 원본 시험 10번. 기존 사용자 정의 PriorityClass 최댓값보다 1 작은 PriorityClass를 만들고 Deployment에 patch한다. (문서 17번)
#
# 1. Create a new PriorityClass named high-priority for user workloads. Its value must be exactly
#    one less than the highest existing user-defined PriorityClass value
#    (the built-in system-* classes are not user-defined)
# 2. Patch the existing Deployment busybox-logger in namespace exercise-53 to use the PriorityClass
#    high-priority
# 3. Make sure the busybox-logger Deployment rolls out successfully with the new PriorityClass
# 4. Do NOT modify the other Deployment in namespace exercise-53
#
# (In the exam other Pods may get evicted when the high-priority Pod starts - that is expected.)
