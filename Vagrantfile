# -*- mode: ruby -*-
# vi: set ft=ruby :

$ip = 100

$private_network = {
  libvirt__network_name: 'k8s_private',
  libvirt__network_address: '192.168.15.0/24',
  libvirt__forward_mode: 'none',
  libvirt__dhcp_enabled: false,
  autostart: true
}

def default_config(machine)
  machine.vm.box = "generic/ubuntu2004"

  machine.vm.synced_folder ".", "/vagrant", disabled: true
  machine.vm.provider "libvirt" do |h|
    h.memory = 4096
    h.cpus = 2
    h.machine_virtual_size = 20
  end

  # $ip += 1
  # private_network = {}.merge($private_network)
  # machine.vm.network :private_network,
  #   ip: "192.168.15.#{$ip}",
  #   **private_network

  provision machine
end

def provision(machine, script: "default_provision.sh")
  machine.vm.provision "shell", path: script
end

Vagrant.configure("2") do |config|
  config.vm.define :master do |master|
    default_config master
    master.vm.hostname = "k8s-master"
    provision master, script: "master_provision.sh"
  end

  [1, 2].each do |n|
    config.vm.define "worker_#{n}" do |worker|
      default_config worker
      worker.vm.hostname = "k8s-worker-#{n}"
    end
  end
end
