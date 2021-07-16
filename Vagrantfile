# -*- mode: ruby -*-
# vi: set ft=ruby :


## Variables ##

worker_nodes_number = 3
k8s_source_image    = "bento/ubuntu-18.04"
# k8s_source_image    = "kube-ready"
master_memory       = 4096
worker_memory       = 2048
haproxy_memory      = 1024
create_haproxy_vm   = false

##################  ##################  ##################

# Create a shared dir
# The shared dir is used to share the "join to master" script for all the new Nodes (Which allows us to add nodes at any time)
Dir.mkdir('share') unless File.directory?('share')

## Create the VMs ##

Vagrant.configure("2") do |config|
  config.ssh.username = "vagrant"
  config.ssh.password = "vagrant"

  config.vm.define "master" do |master|
    master.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--memory", "#{master_memory}"]
      v.customize ["modifyvm", :id, "--cpus", "2"]
      v.customize ["modifyvm", :id, "--name", "master"]
    end
    master.vm.hostname = "master"
    config.vm.box = "#{k8s_source_image}"
    master.vm.network :public_network, bridge: "eth0", ip: "192.168.122.90"
    master.vm.synced_folder './share', '/var/share', SharedFoldersEnableSymlinksCreate: false
    if k8s_source_image == "bento/ubuntu-18.04"
      master.vm.provision :shell, path: "scripts/install-k8s-components.sh"
    end
    master.vm.provision :shell, path: "scripts/initialize_cluster.sh"
    master.vm.provision :shell, path: "scripts/generate_join_command.sh", run: "always"
    master.vm.provision :shell, path: "scripts/copy-master.sh", run: "always"
    master.vm.provision :shell, path: "scripts/install-helm3.sh"
    master.vm.provision :shell, path: "scripts/install-nfs-server.sh"

    # Generate /ec/hosts of the master
    txt="""
127.0.0.1          localhost
127.0.1.1          master
192.168.122.90       master"""
    if worker_nodes_number > 0
      # for each worker node --> add entry
      (1..worker_nodes_number).each do |i|
        txt = "#{txt}\n" + "192.168.1.#{90 + i}       worker-#{i}"
      end
    end
    File.open('share/hosts', 'w') do |f|
      f.puts txt
    end
end

(1..worker_nodes_number).each do |i|
  config.vm.define "worker-#{i}" do |worker|
    worker.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--memory", "#{worker_memory}"]
      v.customize ["modifyvm", :id, "--cpus", "2"]
      v.customize ["modifyvm", :id, "--name", "worker-#{i}"]
    end
    worker.vm.box = "#{k8s_source_image}"
    worker.vm.hostname = "worker-#{i}"
    worker.vm.network :public_network, bridge: "eth0", ip: "192.168.122.#{90 + i}"
    worker.vm.synced_folder './share', '/var/share', SharedFoldersEnableSymlinksCreate: false
    if k8s_source_image == "bento/ubuntu-18.04"
      worker.vm.provision :shell, path: "scripts/install-k8s-components.sh"
    end
    worker.vm.provision :shell, path: "scripts/join-k8s-worker.sh", privileged: true
  end
end

if create_haproxy_vm
  config.vm.define "haproxy" do |haproxy|
    haproxy.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--memory", "#{haproxy_memory}"]
      v.customize ["modifyvm", :id, "--cpus", "2"]
      v.customize ["modifyvm", :id, "--name", "haproxy"]
    end
    haproxy.vm.hostname = "HAProxy"
    config.vm.box = "bento/ubuntu-18.04"
    haproxy.vm.network :public_network, bridge: "eth0", ip: "192.168.122.100"
    haproxy.vm.provision :shell, path: "scripts/install-haproxy.sh"
  end
end
end
