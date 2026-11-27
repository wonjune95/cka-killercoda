kubectl get ns --show-labels | grep exercise-50
kubectl -n exercise-50-frontend get deploy,pods --show-labels
kubectl -n exercise-50-backend get deploy,pods --show-labels
kubectl -n exercise-50-backend get deploy backend -o yaml | grep -A3 ports:     # containerPort 80
kubectl get netpol -A | grep exercise-50                                         # deny-all
cat /root/netpol/*.yaml
#  netpol-1: from every namespace (namespaceSelector: {})            -> too wide
#  netpol-2: namespaceSelector and podSelector as TWO list items = OR -> too wide
#  netpol-3: ipBlock 0.0.0.0/0                                        -> too wide
#  netpol-4: frontend ns AND app=frontend, but every port             -> wider than needed
#  netpol-5: frontend ns AND app=frontend, TCP 80 only                -> the answer
kubectl apply -f /root/netpol/netpol-5.yaml
kubectl -n exercise-50-frontend exec deploy/frontend -- curl -s -m3 backend.exercise-50-backend | grep title
# 참고: from 아래 한 항목에 namespaceSelector 와 podSelector 를 함께 = AND, "-" 로 나누면 = OR.
