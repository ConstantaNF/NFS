# ****Стенд Vagrant с NFS**** #

### **Цель домашннего задания** ###

Научиться самостоятельно развернуть сервис NFS и подключить к нему клиента.

### **Описание домашннего задания** ###

- vagrant up должен поднимать 2 виртуалки: сервер и клиент;
- на сервер должна быть расшарена директория;
- на клиента она должна автоматически монтироваться при старте (fstab или autofs);
- в шаре должна быть папка upload с правами на запись;
- требования для NFS: NFSv3 по UDP, включенный firewall.

### **Выполнение** ###

Задание выполняется на рабочей станции с ОС Ubuntu 22.04.4 LTS с заранее установленными Vagrant 2.4.1 и VirtualBox 7.0. Перед выполнением предварительно подготовлен репозиторий <https://github.com/ConstantaNF/NFS>

### **Подготовка окружения** ###

Для развёртывания управляемых ВМ посредством Vagrant использую Vagrantfile из методички к домашнему заданию по теме:

```
# -*- mode: ruby -*- 
# vi: set ft=ruby : vsa

Vagrant.configure(2) do |config| 
  config.vm.box = "centos/7" 
  config.vm.box_version = "2004.01" 
  config.vm.provider "virtualbox" do |v| 
    v.memory = 256 
    v.cpus = 1 
  end
 
  config.vm.define "nfss" do |nfss| 
    nfss.vm.network "private_network", ip: "192.168.56.10",  virtualbox__intnet: "net1" 
    nfss.vm.hostname = "nfss" 
  end
 
  config.vm.define "nfsc" do |nfsc| 
    nfsc.vm.network "private_network", ip: "192.168.56.11",  virtualbox__intnet: "net1" 
    nfsc.vm.hostname = "nfsc" 
  end 
end
```

Данный Vagrantfile кладу в заранее подготовленный каталог `/home/adminkonstantin/NFS`.

Стартую ВМ:

```
adminkonstantin@2OSUbuntu:~/NFS$ vagrant up
```

```
Bringing machine 'nfss' up with 'virtualbox' provider...
Bringing machine 'nfsc' up with 'virtualbox' provider...
==> nfss: Importing base box 'centos/7'...
==> nfss: Matching MAC address for NAT networking...
==> nfss: Checking if box 'centos/7' version '2004.01' is up to date...
==> nfss: Setting the name of the VM: NFS_nfss_1714148183848_38048
==> nfss: Clearing any previously set network interfaces...
==> nfss: Preparing network interfaces based on configuration...
    nfss: Adapter 1: nat
    nfss: Adapter 2: intnet
==> nfss: Forwarding ports...
    nfss: 22 (guest) => 2222 (host) (adapter 1)
==> nfss: Running 'pre-boot' VM customizations...
==> nfss: Booting VM...
==> nfss: Waiting for machine to boot. This may take a few minutes...
    nfss: SSH address: 127.0.0.1:2222
    nfss: SSH username: vagrant
    nfss: SSH auth method: private key
    nfss: 
    nfss: Vagrant insecure key detected. Vagrant will automatically replace
    nfss: this with a newly generated keypair for better security.
    nfss: 
    nfss: Inserting generated public key within guest...
    nfss: Removing insecure key from the guest if it's present...
    nfss: Key inserted! Disconnecting and reconnecting using new SSH key...
==> nfss: Machine booted and ready!
==> nfss: Checking for guest additions in VM...
    nfss: No guest additions were detected on the base box for this VM! Guest
    nfss: additions are required for forwarded ports, shared folders, host only
    nfss: networking, and more. If SSH fails on this machine, please install
    nfss: the guest additions and repackage the box to continue.
    nfss: 
    nfss: This is not an error message; everything may continue to work properly,
    nfss: in which case you may ignore this message.
==> nfss: Setting hostname...
==> nfss: Configuring and enabling network interfaces...
==> nfss: Rsyncing folder: /home/adminkonstantin/NFS/ => /vagrant
==> nfsc: Importing base box 'centos/7'...
==> nfsc: Matching MAC address for NAT networking...
==> nfsc: Checking if box 'centos/7' version '2004.01' is up to date...
==> nfsc: Setting the name of the VM: NFS_nfsc_1714148233567_1945
==> nfsc: Fixed port collision for 22 => 2222. Now on port 2200.
==> nfsc: Clearing any previously set network interfaces...
==> nfsc: Preparing network interfaces based on configuration...
    nfsc: Adapter 1: nat
    nfsc: Adapter 2: intnet
==> nfsc: Forwarding ports...
    nfsc: 22 (guest) => 2200 (host) (adapter 1)
==> nfsc: Running 'pre-boot' VM customizations...
==> nfsc: Booting VM...
==> nfsc: Waiting for machine to boot. This may take a few minutes...
    nfsc: SSH address: 127.0.0.1:2200
    nfsc: SSH username: vagrant
    nfsc: SSH auth method: private key
    nfsc: 
    nfsc: Vagrant insecure key detected. Vagrant will automatically replace
    nfsc: this with a newly generated keypair for better security.
    nfsc: 
    nfsc: Inserting generated public key within guest...
    nfsc: Removing insecure key from the guest if it's present...
    nfsc: Key inserted! Disconnecting and reconnecting using new SSH key...
==> nfsc: Machine booted and ready!
==> nfsc: Checking for guest additions in VM...
    nfsc: No guest additions were detected on the base box for this VM! Guest
    nfsc: additions are required for forwarded ports, shared folders, host only
    nfsc: networking, and more. If SSH fails on this machine, please install
    nfsc: the guest additions and repackage the box to continue.
    nfsc: 
    nfsc: This is not an error message; everything may continue to work properly,
    nfsc: in which case you may ignore this message.
==> nfsc: Setting hostname...
==> nfsc: Configuring and enabling network interfaces...
==> nfsc: Rsyncing folder: /home/adminkonstantin/NFS/ => /vagrant
```

### **Настраиваем сервер NFS** ###

























