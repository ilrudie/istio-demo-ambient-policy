#!/usr/bin/env bash

GATEWAY_HOST=bookinfo-gateway-istio.default

echo "        ### FROM ambient sleep TO ingress"
kubectl exec -n client deploy/sleep -- curl -s "http://$GATEWAY_HOST/productpage" | grep -o -e "<title>.*</title>" -e "RBAC: access denied" -e "reset reason: connection termination"
echo ""
echo "        ### FROM ambient sleep TO productpage service"
kubectl exec -n client deploy/sleep -- curl -s http://productpage.default:9080/ | grep -o -e "<title>.*</title>" -e "RBAC: access denied" -e "reset reason: connection termination"
echo ""
echo "        ### FROM ambient notsleep TO productpage service"
kubectl exec -n client deploy/notsleep -- curl -s http://productpage.default:9080/ | grep -o -e "<title>.*</title>" -e "RBAC: access denied" -e "reset reason: connection termination"
echo ""
echo "        ### FROM non-ambient sleep TO ingress"
kubectl exec -n nonmesh-client deploy/sleep -- curl -s "http://$GATEWAY_HOST/productpage" | grep -o -e "<title>.*</title>" -e "RBAC: access denied" -e "reset reason: connection termination"
echo ""
echo "        ### FROM non-ambient sleep TO productpage service"
kubectl exec -n nonmesh-client deploy/sleep -- curl -s http://productpage.default:9080/ | grep -o -e "<title>.*</title>" -e "RBAC: access denied" -e "reset reason: connection termination"
echo ""
echo "        ### FROM non-ambient notsleep TO productpage service"
kubectl exec -n nonmesh-client deploy/notsleep -- curl -s http://productpage.default:9080/ | grep -o -e "<title>.*</title>" -e "RBAC: access denied" -e "reset reason: connection termination"
echo ""
