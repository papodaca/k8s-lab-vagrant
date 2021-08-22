#!/bin/bash

remote_repo=k8s.gcr.io
local_repo=<insert_local_repo>
kubernetes_version=v1.21.1

images=(
  "kube-apiserver:${kubernetes_version}"
  "kube-controller-manager:${kubernetes_version}"
  "kube-scheduler:${kubernetes_version}"
  "kube-proxy:${kubernetes_version}"
  "pause:3.4.1"
  "etcd:3.4.13-0"
  "coredns/coredns:v1.8.0"
)

for image in ${images[@]}; do
  remote_image="${remote_repo}/${image}"
  local_image="${local_repo}/${image}"
  docker pull $remote_image
  docker tag $remote_image $local_image
  docker push $local_image
done