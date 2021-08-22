#!/bin/bash -xe

vagrant up
vagrant ssh-config > .vagrant/ssh_config

ssh -F .vagrant/ssh_config master << EOF
  sudo kubeadm init --config /home/vagrant/kube-adm.yml

  mkdir -p ~/.kube/
  sudo cp -i /etc/kubernetes/admin.conf ~/.kube/config
  sudo chown vagrant:vagrant ~/.kube/config
EOF

if [[ -z "${FLANEL}" ]]; then
ssh -F .vagrant/ssh_config master << EOF
  kubectl apply -f https://docs.projectcalico.org/manifests/tigera-operator.yaml
  curl -sL https://docs.projectcalico.org/manifests/custom-resources.yaml > calico-install.yml
  sed -i 's/0\.0\/16/100\.0\/20/g' calico-install.yml
  kubectl apply -f calico-install.yml
EOF
else
ssh -F .vagrant/ssh_config master "kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml"
fi

command=$(ssh -F .vagrant/ssh_config master "sudo kubeadm token create --print-join-command")
ssh -F .vagrant/ssh_config worker_1 "sudo ${command}" &
ssh -F .vagrant/ssh_config worker_2 "sudo ${command}" &

wait

ssh -F .vagrant/ssh_config master << EOF
  kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
  kubectl create ns kubeview
  kubectl create ns kubernetes-dashboard
  helm install -n kubeview kubeview kubeview/kubeview
  helm install -n kubernetes-dashboard kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard
EOF
