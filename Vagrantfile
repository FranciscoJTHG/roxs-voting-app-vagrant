# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-24.04" # Ubuntu 24.04 LTS (Noble Numbat)
  config.vm.hostname = "ubuntu-dev"
  config.vm.boot_timeout = 600 # Increase boot timeout to 600 seconds (10 minutes)

  config.vm.network "forwarded_port", guest: 80, host: 8080, auto_correct: true # Forward port 80 (guest) to 8080 (host)
  config.vm.network "forwarded_port", guest: 5001, host: 5001 # Forward port for result app
  config.vm.network "private_network", ip: "192.168.56.10" # Static IP address

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048" # 2GB RAM
    vb.cpus = 2 # 2 CPUs
  end

  # Provision with Ansible via a shell wrapper to set the required environment variable.
  config.vm.provision "shell", inline: <<-SHELL
    echo "Setting Ansible environment variable to work around privilege escalation issue."
    export ANSIBLE_ALLOW_WORLD_READABLE_TMPFILES=1
    
    echo "Running Ansible playbook..."
    # Create a temporary vault password file
    echo "postgres" > /tmp/vault_pass.txt
    # Install Ansible first if not present
    if ! command -v ansible-playbook &> /dev/null
    then
        echo "Ansible not found, installing..."
        sudo apt-get update
        sudo apt-get install -y software-properties-common
        sudo add-apt-repository --yes --update ppa:ansible/ansible
        sudo apt-get install -y ansible
    fi
    # We need to specify the local connection for ansible-playbook when running it manually.
    ansible-playbook /vagrant/provision.yml --connection=local -i localhost, --vault-password-file /tmp/vault_pass.txt
    # Clean up the temporary vault password file
    rm /tmp/vault_pass.txt
  SHELL
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  # config.vm.box = "base"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Disable the default share of the current code directory. Doing this
  # provides improved isolation between the vagrant box and your host
  # by making sure your Vagrantfile isn't accessible to the vagrant box.
  # If you use this you may want to enable additional shared subfolders as
  # shown above.
  # config.vm.synced_folder ".", "/vagrant", disabled: true

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Ansible, Chef, Docker, Puppet and Salt are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
end
