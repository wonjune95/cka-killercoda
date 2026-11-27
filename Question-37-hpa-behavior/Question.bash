# Question 37 - HPA with a scale-down stabilization window  (Workloads & Scheduling | Medium | 10 min)
# 한글: 원본 시험 2번. CPU 50%, 1~4개, 스케일 다운 안정화 윈도우 30초인 HPA를 만든다.
#
# The lab setup installed metrics-server and created Deployment apache-server in namespace exercise-37.
#
# Create a new HorizontalPodAutoscaler named apache-server in namespace exercise-37 that targets
# the existing Deployment apache-server:
#   - target 50% CPU usage per Pod
#   - at least 1 and at most 4 Pods
#   - set the downscale stabilization window to 30 seconds
