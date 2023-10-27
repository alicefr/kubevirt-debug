#!/bin/bash -xe

K8S_VERSION=k8s-1.27
CONT=${K8S_VERSION}-dnsmasq
IMAGE=debug-tools:latest

PORT=$(sudo podman port $CONT 5000 |awk -F ":" '{print $2}')
IMAGE_PUSH=localhost:${PORT}/${IMAGE}
registry=localhost:${PORT}
tag=$(kubectl get kubevirt kubevirt -n kubevirt  -o jsonpath='{.status.observedDeploymentConfig}' |jq '.virtLauncherSha'|tr -d "\"")
sudo podman build -t $IMAGE --tls-verify=false \
	--build-arg registry=$registry \
	--build-arg tag=@$tag \
	.
sudo podman rmi ${IMAGE_PUSH} || true
sudo podman tag ${IMAGE} ${IMAGE_PUSH}
sudo podman push --tls-verify=false ${IMAGE_PUSH}
