#!/bin/bash

# systemd-resolved causes hostnames to randomly return SERVFAIL, we don't need it in anycase.
# Not sure why its enabled by default
sudo systemctl disable --now systemd-resolved
sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
# sudo rm -rf /etc/resolv.conf
# echo "nameserver 192.168.1.1" | sudo tee /etc/resolv.conf

export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true

systemctl disable --now snapd
sudo apt-get purge -y snapd

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://packages.cloud.google.com/apt/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
apt-get update

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
apt-get update

k8s_version=1.21.1
k8s_package_version=${k8s_version}-00

sudo apt-get update
sudo apt-get install -y containerd kubelet=${k8s_package_version} kubeadm=${k8s_package_version} kubectl=${k8s_package_version}
sudo apt-mark hold kubelet kubeadm kubectl containerd

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system

sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
sudo systemctl restart containerd

sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# kubeadm config images pull --kubernetes-version $k8s_version --image-repository <insert_local_repo>
kubeadm config images pull --kubernetes-version $k8s_version
