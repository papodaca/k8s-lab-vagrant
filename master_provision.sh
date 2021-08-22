#!/bin/bash
cat <<EOF | tee /home/vagrant/kube-adm.yml
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
kubernetesVersion: v1.21.1
networking:
  podSubnet: 192.168.100.0/20
# imageRepository: <insert_local_repo>
---
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
cgroupDriver: systemd
serverTLSBootstrap: true
EOF

# lets install some helpful tools

cd /tmp
curl -sL https://github.com/derailed/k9s/releases/download/v0.24.15/k9s_Linux_x86_64.tar.gz > k9s.tar.gz
tar xf k9s.tar.gz
sudo mv k9s /usr/local/bin

curl -sL https://get.helm.sh/helm-v3.6.3-linux-amd64.tar.gz > helm.tar.gz
tar xf helm.tar.gz
sudo mv linux-amd64/helm /usr/local/bin

curl -sL https://github.com/linkerd/linkerd2/releases/download/stable-2.9.5/linkerd2-cli-stable-2.9.5-linux-amd64 > linkerd
sudo mv linkerd /usr/local/bin

rm -rf k9s.tar.gz helm.tar.gz linux-amd64 LICENSE README.md

cd ~
sudo -u vagrant helm repo add fairwinds-stable https://charts.fairwinds.com/stable
sudo -u vagrant helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
sudo -u vagrant helm repo add bitnami https://charts.bitnami.com/bitnami
sudo -u vagrant helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
sudo -u vagrant helm repo add jetstack https://charts.jetstack.io
sudo -u vagrant helm repo add argo https://argoproj.github.io/argo-helm
sudo -u vagrant helm repo add traefik https://helm.traefik.io/traefik
sudo -u vagrant helm repo add kubeview https://benc-uk.github.io/kubeview/charts
sudo -u vagrant helm repo update
