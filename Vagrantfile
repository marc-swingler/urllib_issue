# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
	config.vm.box = "ubuntu/trusty64"
	config.vm.network "private_network", type: "dhcp"
	config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"
	config.vm.provision "chef_solo" do |chef|
		chef.add_recipe("foo")
	end
	config.vm.provider "virtualbox" do |v|
		v.memory = 4096
	end
end

