#!/usr/bin/env bash


echo "        ### FROM ambient sleep TO productpage service"
kubectl exec -n client deploy/sleep -- curl -s http://productpage.default:9080/ -X DELETE | grep -o -e "<title>.*</title>" -e "RBAC: access denied" -e "reset reason: connection termination"

