# Question 33 - Argo CD with Helm (template + install, no CRDs)  (Cluster Architecture | Medium | 15 min)
# 한글: 원본 시험 16번. Argo CD 차트 8.6.4의 helm template 저장 후 같은 설정으로 설치, CRD는 설치하지 않는다.
#
# The Argo CD CRDs are already installed in the cluster.
#
# Tasks
# 1. Add the official Argo CD Helm repository with the name argo:
#      https://argoproj.github.io/argo-helm
# 2. Generate a helm template of the Argo CD chart (argo/argo-cd) version 8.6.4 for the namespace
#    argocd and save it to /root/argo-helm.yaml. Configure the chart NOT to install CRDs.
# 3. Install Argo CD with Helm: release name argocd, same chart version and configuration as the
#    template, namespace argocd, CRDs NOT installed by the chart
# 4. You do not need to configure access to the Argo CD server UI
#
# Argo CD needs about 1.5 GB RAM. Lab 31 also uses namespace argocd - their setups clean each other.
