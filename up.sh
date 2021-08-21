#!/bin/bash -xe

k8s_version=1.21.1
flanel="https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml"
calico="https://docs.projectcalico.org/manifests/calico.yaml"

vagrant up
vagrant ssh-config > .vagrant/ssh_config

ssh -F .vagrant/ssh_config master "sudo kubeadm init --pod-network-cidr 192.168.100.0/24 --kubernetes-version ${k8s_version}"
ssh -F .vagrant/ssh_config master "sudo KUBECONFIG=/etc/kubernetes/admin.conf kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml"

command=$(ssh -F .vagrant/ssh_config master "sudo kubeadm token create --print-join-command")
ssh -F .vagrant/ssh_config worker_1 "sudo ${command}" &
ssh -F .vagrant/ssh_config worker_2 "sudo ${command}" &

wait
