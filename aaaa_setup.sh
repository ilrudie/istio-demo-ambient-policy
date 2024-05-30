#!/usr/bin/env bash

ISTIO_SAMPLES_PATH="https://raw.githubusercontent.com/istio/istio/release-1.22/"
GATEWAY_HOST=bookinfo-gateway-istio.default
GATEWAY_SERVICE_ACCOUNT=ns/default/sa/bookinfo-gateway-istio

kind create cluster --config=- <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: community-demo
nodes:
- role: control-plane
- role: worker
- role: worker
EOF

kind load docker-image docker.io/istio/pilot:1.22.0-distroless --name community-demo
kind load docker-image docker.io/istio/install-cni:1.22.0-distroless --name community-demo
kind load docker-image docker.io/istio/ztunnel:1.22.0-distroless --name community-demo
kind load docker-image docker.io/istio/proxyv2:1.22.0-distroless --name community-demo
kind load docker-image docker.io/istio/examples-bookinfo-productpage-v1:1.19.1 --name community-demo
kind load docker-image docker.io/istio/examples-bookinfo-details-v1:1.19.1 --name community-demo
kind load docker-image docker.io/istio/examples-bookinfo-ratings-v1:1.19.1 --name community-demo
kind load docker-image docker.io/istio/examples-bookinfo-reviews-v1:1.19.1 --name community-demo
kind load docker-image docker.io/istio/examples-bookinfo-reviews-v2:1.19.1 --name community-demo
kind load docker-image docker.io/istio/examples-bookinfo-reviews-v3:1.19.1 --name community-demo
kind load docker-image curlimages/curl --name community-demo
 

kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null || \
  { kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd/experimental?ref=v1.1.0" | kubectl apply -f -; }

istioctl install --set profile=ambient --skip-confirmation

kubectl create namespace client
kubectl create namespace nonmesh-client
kubectl label namespace default istio.io/dataplane-mode=ambient
kubectl label namespace client istio.io/dataplane-mode=ambient

kubectl apply -f ${ISTIO_SAMPLES_PATH}/samples/bookinfo/platform/kube/bookinfo.yaml
kubectl apply -f ${ISTIO_SAMPLES_PATH}/samples/bookinfo/platform/kube/bookinfo-versions.yaml

kubectl apply -f ${ISTIO_SAMPLES_PATH}/samples/sleep/sleep.yaml -n client
kubectl apply -f ${ISTIO_SAMPLES_PATH}/samples/sleep/notsleep.yaml -n client 

kubectl apply -f ${ISTIO_SAMPLES_PATH}/samples/sleep/sleep.yaml -n nonmesh-client
kubectl apply -f ${ISTIO_SAMPLES_PATH}/samples/sleep/notsleep.yaml -n nonmesh-client 

kubectl apply -f ${ISTIO_SAMPLES_PATH}/samples/bookinfo/gateway-api/bookinfo-gateway.yaml
kubectl annotate gateway bookinfo-gateway networking.istio.io/service-type=ClusterIP --namespace=default

kubectl wait -n default --for=condition=programmed gtw/bookinfo-gateway --timeout=120s

sleep 30

./run-clients.sh
