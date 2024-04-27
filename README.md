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

Заходим на сервер:

```
adminkonstantin@2OSUbuntu:~/NFS$ vagrant ssh nfss
[vagrant@nfss ~]$ 
```

Переходим в УЗ root:

```
[vagrant@nfss ~]$ sudo -i
[root@nfss ~]# 
```

Устанавливаем доп утилиты для отладки сервера:

```
[root@nfss ~]# yum install nfs-utils
```

```
Failed to set locale, defaulting to C
Loaded plugins: fastestmirror
Determining fastest mirrors
 * base: mirror.serverius.net
 * extras: mirror.serverius.net
 * updates: mirror.nforce.com
base                                                                                                                                                                      | 3.6 kB  00:00:00     
extras                                                                                                                                                                    | 2.9 kB  00:00:00     
updates                                                                                                                                                                   | 2.9 kB  00:00:00     
(1/4): base/7/x86_64/group_gz                                                                                                                                             | 153 kB  00:00:00     
(2/4): extras/7/x86_64/primary_db                                                                                                                                         | 253 kB  00:00:00     
(3/4): base/7/x86_64/primary_db                                                                                                                                           | 6.1 MB  00:00:01     
(4/4): updates/7/x86_64/primary_db                                                                                                                                        |  26 MB  00:00:09     
Resolving Dependencies
--> Running transaction check
---> Package nfs-utils.x86_64 1:1.3.0-0.66.el7 will be updated
---> Package nfs-utils.x86_64 1:1.3.0-0.68.el7.2 will be an update
--> Finished Dependency Resolution

Dependencies Resolved

=================================================================================================================================================================================================
 Package                                      Arch                                      Version                                                 Repository                                  Size
=================================================================================================================================================================================================
Updating:
 nfs-utils                                    x86_64                                    1:1.3.0-0.68.el7.2                                      updates                                    413 k

Transaction Summary
=================================================================================================================================================================================================
Upgrade  1 Package

Total download size: 413 k
Is this ok [y/d/N]: y
Downloading packages:
No Presto metadata available for updates
warning: /var/cache/yum/x86_64/7/updates/packages/nfs-utils-1.3.0-0.68.el7.2.x86_64.rpm: Header V3 RSA/SHA256 Signature, key ID f4a80eb5: NOKEY                ]  0.0 B/s | 254 kB  --:--:-- ETA 
Public key for nfs-utils-1.3.0-0.68.el7.2.x86_64.rpm is not installed
nfs-utils-1.3.0-0.68.el7.2.x86_64.rpm                                                                                                                                     | 413 kB  00:00:01     
Retrieving key from file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
Importing GPG key 0xF4A80EB5:
 Userid     : "CentOS-7 Key (CentOS 7 Official Signing Key) <security@centos.org>"
 Fingerprint: 6341 ab27 53d7 8a78 a7c2 7bb1 24c6 a8a7 f4a8 0eb5
 Package    : centos-release-7-8.2003.0.el7.centos.x86_64 (@anaconda)
 From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
Is this ok [y/N]: y
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Updating   : 1:nfs-utils-1.3.0-0.68.el7.2.x86_64                                                                                                                                           1/2 
  Cleanup    : 1:nfs-utils-1.3.0-0.66.el7.x86_64                                                                                                                                             2/2 
  Verifying  : 1:nfs-utils-1.3.0-0.68.el7.2.x86_64                                                                                                                                           1/2 
  Verifying  : 1:nfs-utils-1.3.0-0.66.el7.x86_64                                                                                                                                             2/2 

Updated:
  nfs-utils.x86_64 1:1.3.0-0.68.el7.2                                                                                                                                                            

Complete!
```

Включаем firewall и проверяем, что он работает:

```
[root@nfss ~]# systemctl enable firewalld --now
```

```
Created symlink from /etc/systemd/system/dbus-org.fedoraproject.FirewallD1.service to /usr/lib/systemd/system/firewalld.service.
Created symlink from /etc/systemd/system/multi-user.target.wants/firewalld.service to /usr/lib/systemd/system/firewalld.service.
```

```
[root@nfss ~]# systemctl status firewalld
```

```
● firewalld.service - firewalld - dynamic firewall daemon
   Loaded: loaded (/usr/lib/systemd/system/firewalld.service; enabled; vendor preset: enabled)
   Active: active (running) since Sat 2024-04-27 12:00:09 UTC; 1min 23s ago
     Docs: man:firewalld(1)
 Main PID: 2873 (firewalld)
   CGroup: /system.slice/firewalld.service
           └─2873 /usr/bin/python2 -Es /usr/sbin/firewalld --nofork --nopid

Apr 27 12:00:09 nfss systemd[1]: Starting firewalld - dynamic firewall daemon...
Apr 27 12:00:09 nfss systemd[1]: Started firewalld - dynamic firewall daemon.
Apr 27 12:00:10 nfss firewalld[2873]: WARNING: AllowZoneDrifting is enabled. This is considered an insecure configuration option. It will be removed in a future release. Please ...bling it now.
Hint: Some lines were ellipsized, use -l to show in full.
```

Разрешаем в firewall доступ к сервисам NFS: 

```
[root@nfss ~]# firewall-cmd --add-service="nfs3" \
> --add-service="rpc-bind" \
> --add-service="mountd" \
> --permanent 
```

```
success
```

```
[root@nfss ~]# firewall-cmd --reload
```

```
success
```

Включаем сервер NFS:

```
[root@nfss ~]# systemctl enable nfs --now 
```

```
Created symlink from /etc/systemd/system/multi-user.target.wants/nfs-server.service to /usr/lib/systemd/system/nfs-server.service.
```

Проверяем наличие слушаемых портов 2049/udp, 2049/tcp, 20048/udp,  20048/tcp, 111/udp, 111/tcp:

```
[root@nfss ~]# ss -tnplu 
```

```
Netid State      Recv-Q Send-Q                                                 Local Address:Port                                                                Peer Address:Port              
udp   UNCONN     0      0                                                                  *:111                                                                            *:*                   users:(("rpcbind",pid=367,fd=6))
udp   UNCONN     0      0                                                                  *:36218                                                                          *:*                   users:(("rpc.statd",pid=3045,fd=7))
udp   UNCONN     0      0                                                                  *:949                                                                            *:*                   users:(("rpcbind",pid=367,fd=7))
udp   UNCONN     0      0                                                          127.0.0.1:703                                                                            *:*                   users:(("rpc.statd",pid=3045,fd=32))
udp   UNCONN     0      0                                                                  *:2049                                                                           *:*                  
udp   UNCONN     0      0                                                                  *:35880                                                                          *:*                  
udp   UNCONN     0      0                                                          127.0.0.1:323                                                                            *:*                   users:(("chronyd",pid=384,fd=5))
udp   UNCONN     0      0                                                                  *:68                                                                             *:*                   users:(("dhclient",pid=1880,fd=6))
udp   UNCONN     0      0                                                                  *:20048                                                                          *:*                   users:(("rpc.mountd",pid=3053,fd=7))
udp   UNCONN     0      0                                                               [::]:111                                                                         [::]:*                   users:(("rpcbind",pid=367,fd=9))
udp   UNCONN     0      0                                                               [::]:949                                                                         [::]:*                   users:(("rpcbind",pid=367,fd=10))
udp   UNCONN     0      0                                                               [::]:49886                                                                       [::]:*                   users:(("rpc.statd",pid=3045,fd=9))
udp   UNCONN     0      0                                                               [::]:2049                                                                        [::]:*                  
udp   UNCONN     0      0                                                               [::]:39489                                                                       [::]:*                  
udp   UNCONN     0      0                                                              [::1]:323                                                                         [::]:*                   users:(("chronyd",pid=384,fd=6))
udp   UNCONN     0      0                                                               [::]:20048                                                                       [::]:*                   users:(("rpc.mountd",pid=3053,fd=9))
tcp   LISTEN     0      128                                                                *:111                                                                            *:*                   users:(("rpcbind",pid=367,fd=8))
tcp   LISTEN     0      128                                                                *:20048                                                                          *:*                   users:(("rpc.mountd",pid=3053,fd=8))
tcp   LISTEN     0      128                                                                *:58515                                                                          *:*                   users:(("rpc.statd",pid=3045,fd=8))
tcp   LISTEN     0      128                                                                *:22                                                                             *:*                   users:(("sshd",pid=687,fd=3))
tcp   LISTEN     0      100                                                        127.0.0.1:25                                                                             *:*                   users:(("master",pid=773,fd=13))
tcp   LISTEN     0      64                                                                 *:43931                                                                          *:*                  
tcp   LISTEN     0      64                                                                 *:2049                                                                           *:*                  
tcp   LISTEN     0      64                                                              [::]:33805                                                                       [::]:*                  
tcp   LISTEN     0      128                                                             [::]:111                                                                         [::]:*                   users:(("rpcbind",pid=367,fd=11))
tcp   LISTEN     0      128                                                             [::]:20048                                                                       [::]:*                   users:(("rpc.mountd",pid=3053,fd=10))
tcp   LISTEN     0      128                                                             [::]:22                                                                          [::]:*                   users:(("sshd",pid=687,fd=4))
tcp   LISTEN     0      100                                                            [::1]:25                                                                          [::]:*                   users:(("master",pid=773,fd=14))
tcp   LISTEN     0      64                                                              [::]:2049                                                                        [::]:*                  
tcp   LISTEN     0      128                                                             [::]:47591                                                                       [::]:*                   users:(("rpc.statd",pid=3045,fd=10))
```

Создаём и настраиваем директорию, которая будет экспортирована в будущем: 

```
[root@nfss ~]# mkdir -p /srv/share/upload 
```

```
[root@nfss ~]# chown -R nfsnobody:nfsnobody /srv/share 
```

```
[root@nfss ~]# chmod 0777 /srv/share/upload 
```

```
[root@nfss ~]# ls -l /srv/
```

```
total 0
drwxr-xr-x. 3 nfsnobody nfsnobody 20 Apr 27 12:13 share
```

```
[root@nfss ~]# ls -l /srv/share/
```

```
total 0
drwxrwxrwx. 2 nfsnobody nfsnobody 6 Apr 27 12:13 upload
```

Создаём в файле `/etc/exports` структуру, которая позволит экспортировать ранее созданную директорию: 

```
[root@nfss ~]# cat << EOF > /etc/exports 
/srv/share 192.168.56.11/32(rw,sync,root_squash)
EOF
```

Экспортируем ранее созданную директорию: 

```
[root@nfss ~]# exportfs -r
```

Проверяем экспортированную директорию:

```
[root@nfss ~]# exportfs -s
```

```
/srv/share  192.168.56.11/32(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)
```

### **Настраиваем клиент NFS** ###

Заходим на клиент:

```
adminkonstantin@2OSUbuntu:~/NFS$ vagrant ssh nfsc
```

```
[vagrant@nfsc ~]$ 
```

Переходим в УЗ root:

```
[vagrant@nfsc ~]$ sudo -i
```

```
[root@nfsc ~]# 
```

Доустановим вспомогательные утилиты:

```
[root@nfsc ~]# yum install nfs-utils 
```

```
Failed to set locale, defaulting to C
Loaded plugins: fastestmirror
Determining fastest mirrors
 * base: centos.mirror.triple-it.nl
 * extras: mirror.theory7.net
 * updates: mirror.wd6.net
base                                                                                                                                                                      | 3.6 kB  00:00:00     
extras                                                                                                                                                                    | 2.9 kB  00:00:00     
http://mirror.wd6.net/centos/7.9.2009/updates/x86_64/repodata/repomd.xml: [Errno 14] HTTP Error 403 - Forbidden
Trying other mirror.
To address this issue please refer to the below wiki article

https://wiki.centos.org/yum-errors

If above article doesn't help to resolve this issue please use https://bugs.centos.org/.

updates                                                                                                                                                                   | 2.9 kB  00:00:00     
(1/4): extras/7/x86_64/primary_db                                                                                                                                         | 253 kB  00:00:00     
(2/4): base/7/x86_64/group_gz                                                                                                                                             | 153 kB  00:00:00     
(3/4): base/7/x86_64/primary_db                                                                                                                                           | 6.1 MB  00:00:01     
(4/4): updates/7/x86_64/primary_db                                                                                                                                        |  26 MB  00:00:05     
Resolving Dependencies
--> Running transaction check
---> Package nfs-utils.x86_64 1:1.3.0-0.66.el7 will be updated
---> Package nfs-utils.x86_64 1:1.3.0-0.68.el7.2 will be an update
--> Finished Dependency Resolution

Dependencies Resolved

=================================================================================================================================================================================================
 Package                                      Arch                                      Version                                                 Repository                                  Size
=================================================================================================================================================================================================
Updating:
 nfs-utils                                    x86_64                                    1:1.3.0-0.68.el7.2                                      updates                                    413 k

Transaction Summary
=================================================================================================================================================================================================
Upgrade  1 Package

Total download size: 413 k
Is this ok [y/d/N]: y
Downloading packages:
No Presto metadata available for updates
warning: /var/cache/yum/x86_64/7/updates/packages/nfs-utils-1.3.0-0.68.el7.2.x86_64.rpm: Header V3 RSA/SHA256 Signature, key ID f4a80eb5: NOKEY
Public key for nfs-utils-1.3.0-0.68.el7.2.x86_64.rpm is not installed
nfs-utils-1.3.0-0.68.el7.2.x86_64.rpm                                                                                                                                     | 413 kB  00:00:00     
Retrieving key from file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
Importing GPG key 0xF4A80EB5:
 Userid     : "CentOS-7 Key (CentOS 7 Official Signing Key) <security@centos.org>"
 Fingerprint: 6341 ab27 53d7 8a78 a7c2 7bb1 24c6 a8a7 f4a8 0eb5
 Package    : centos-release-7-8.2003.0.el7.centos.x86_64 (@anaconda)
 From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
Is this ok [y/N]: y
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Updating   : 1:nfs-utils-1.3.0-0.68.el7.2.x86_64                                                                                                                                           1/2 
  Cleanup    : 1:nfs-utils-1.3.0-0.66.el7.x86_64                                                                                                                                             2/2 
  Verifying  : 1:nfs-utils-1.3.0-0.68.el7.2.x86_64                                                                                                                                           1/2 
  Verifying  : 1:nfs-utils-1.3.0-0.66.el7.x86_64                                                                                                                                             2/2 

Updated:
  nfs-utils.x86_64 1:1.3.0-0.68.el7.2                                                                                                                                                            

Complete!
```

Включаем firewall и проверяем, что он работает:

```
[root@nfsc ~]# systemctl enable firewalld --now
```

```
Created symlink from /etc/systemd/system/dbus-org.fedoraproject.FirewallD1.service to /usr/lib/systemd/system/firewalld.service.
Created symlink from /etc/systemd/system/multi-user.target.wants/firewalld.service to /usr/lib/systemd/system/firewalld.service.
```

```
[root@nfsc ~]# systemctl status firewalld  
```

```
● firewalld.service - firewalld - dynamic firewall daemon
   Loaded: loaded (/usr/lib/systemd/system/firewalld.service; enabled; vendor preset: enabled)
   Active: active (running) since Sat 2024-04-27 12:42:30 UTC; 1min 13s ago
     Docs: man:firewalld(1)
 Main PID: 2912 (firewalld)
   CGroup: /system.slice/firewalld.service
           └─2912 /usr/bin/python2 -Es /usr/sbin/firewalld --nofork --nopid

Apr 27 12:42:30 nfsc systemd[1]: Starting firewalld - dynamic firewall daemon...
Apr 27 12:42:30 nfsc systemd[1]: Started firewalld - dynamic firewall daemon.
Apr 27 12:42:31 nfsc firewalld[2912]: WARNING: AllowZoneDrifting is enabled. This is considered an insecure configuration option. It will be removed in a future release. Please ...bling it now.
Hint: Some lines were ellipsized, use -l to show in full.
```

Добавляем в `/etc/fstab` строку: 

```
[root@nfsc ~]# echo "192.168.56.10:/srv/share/ /mnt nfs vers=3,proto=udp,noauto,x-systemd.automount 0 0" >> /etc/fstab
```

Выполняем команды:

```
[root@nfsc ~]# systemctl daemon-reload 
[root@nfsc ~]# systemctl restart remote-fs.target 
```

Заходим в директорию `/mnt/` и проверяем успешность монтирования:

```
[root@nfsc ~]# cd /mnt          
```

```
[root@nfsc mnt]# mount | grep mnt 
```

```
systemd-1 on /mnt type autofs (rw,relatime,fd=46,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=24543)
192.168.56.10:/srv/share/ on /mnt type nfs (rw,relatime,vers=3,rsize=32768,wsize=32768,namlen=255,hard,proto=udp,timeo=11,retrans=3,sec=sys,mountaddr=192.168.56.10,mountvers=3,mountport=20048,mountproto=udp,local_lock=none,addr=192.168.56.10)
```

### **Проверка работоспособности** ###

На сервере `nfss` заходим в каталог `/srv/share/upload` и создаём тестовый файл `touch check_file`:

```
[root@nfss ~]# cd /srv/share/upload
[root@nfss upload]# touch check_file
```

На клиенте `nfsc` заходим в каталог `/mnt/upload` и проверяем наличие ранее созданного файла:

```
[root@nfsc mnt]# cd /mnt/upload
[root@nfsc upload]# ls -l
```

```
total 0
-rw-r--r--. 1 root root 0 Apr 27 13:00 check_file
```

Создаём тестовый файл `touch client_file` и проверяем, что файл успешно создан и виден на сервере:

```
[root@nfsc upload]# touch client_file
```

```
[root@nfss upload]# ls -l
```

```
total 0
-rw-r--r--. 1 root      root      0 Apr 27 13:00 check_file
-rw-r--r--. 1 nfsnobody nfsnobody 0 Apr 27 13:05 client_file
```

Проверки прошли успешно.
Предварительно проверяем клиент:

- перезагружаем клиент:

```
[root@nfsc upload]# reboot now
```

- заходим на клиент в каталог `/mnt/upload` и проверяем наличие ранее созданных файлов :

```
adminkonstantin@2OSUbuntu:~/NFS$ vagrant ssh nfsc
```

```
Last login: Sat Apr 27 12:33:59 2024 from 10.0.2.2
[vagrant@nfsc ~]$ 
```

```
[vagrant@nfsc ~]$ cd /mnt/upload
```

```
[vagrant@nfsc upload]$ ls -l
```

```
total 0
-rw-r--r--. 1 root      root      0 Apr 27 13:00 check_file
-rw-r--r--. 1 nfsnobody nfsnobody 0 Apr 27 13:05 client_file
```

Проверяем сервер: 

- перезагружаем сервер:

```
[root@nfss upload]# reboot now
```

- заходим на сервер и проверяем наличие файлов в каталоге `/srv/share/upload/`:

```
adminkonstantin@2OSUbuntu:~/NFS$ vagrant ssh nfss
```

```
Last login: Sat Apr 27 11:53:03 2024 from 10.0.2.2
[vagrant@nfss ~]$        
```

```
[vagrant@nfss ~]$ sudo -i
```

```
[root@nfss ~]# 
```

```
[root@nfss ~]# cd /srv/share/upload
[root@nfss upload]# ls -l
```

```
total 0
-rw-r--r--. 1 root      root      0 Apr 27 13:00 check_file
-rw-r--r--. 1 nfsnobody nfsnobody 0 Apr 27 13:05 client_file
```

- проверяем статус сервера NFS:

```
[root@nfss upload]# systemctl status nfs
```

```
● nfs-server.service - NFS server and services
   Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; enabled; vendor preset: disabled)
  Drop-In: /run/systemd/generator/nfs-server.service.d
           └─order-with-mounts.conf
   Active: active (exited) since Sat 2024-04-27 13:24:45 UTC; 5min ago
  Process: 833 ExecStartPost=/bin/sh -c if systemctl -q is-active gssproxy; then systemctl reload gssproxy ; fi (code=exited, status=0/SUCCESS)
  Process: 808 ExecStart=/usr/sbin/rpc.nfsd $RPCNFSDARGS (code=exited, status=0/SUCCESS)
  Process: 805 ExecStartPre=/usr/sbin/exportfs -r (code=exited, status=0/SUCCESS)
 Main PID: 808 (code=exited, status=0/SUCCESS)
   CGroup: /system.slice/nfs-server.service

Apr 27 13:24:45 nfss systemd[1]: Starting NFS server and services...
Apr 27 13:24:45 nfss systemd[1]: Started NFS server and services.
```

- проверяем статус firewall:

```
[root@nfss upload]# systemctl status firewalld
```

```
● firewalld.service - firewalld - dynamic firewall daemon
   Loaded: loaded (/usr/lib/systemd/system/firewalld.service; enabled; vendor preset: enabled)
   Active: active (running) since Sat 2024-04-27 13:24:42 UTC; 12min ago
     Docs: man:firewalld(1)
 Main PID: 405 (firewalld)
   CGroup: /system.slice/firewalld.service
           └─405 /usr/bin/python2 -Es /usr/sbin/firewalld --nofork --nopid

Apr 27 13:24:41 nfss systemd[1]: Starting firewalld - dynamic firewall daemon...
Apr 27 13:24:42 nfss systemd[1]: Started firewalld - dynamic firewall daemon.
Apr 27 13:24:42 nfss firewalld[405]: WARNING: AllowZoneDrifting is enabled. This is considered an insecure configuration option. It will be removed in a future release. Please c...bling it now.
Hint: Some lines were ellipsized, use -l to show in full.
```

- проверяем экспорты:

```
[root@nfss upload]# exportfs -s
```

```
/srv/share  192.168.56.11/32(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)
```

- проверяем работу RPC:

```
[root@nfss upload]# showmount -a 192.168.56.10
```

```
All mount points on 192.168.56.10:
192.168.56.11:/srv/share
```

Проверяем клиент: 

- перезагружаем клиент:

```
[root@nfsc ~]# reboot now
```

- заходим на клиент:

```
adminkonstantin@2OSUbuntu:~/NFS$ vagrant ssh nfsc
```

```
Last login: Sat Apr 27 13:12:15 2024 from 10.0.2.2
[vagrant@nfsc ~]$ 
```

```
[vagrant@nfsc ~]$ sudo -i
```

```
[root@nfsc ~]# 
```

- проверяем работу RPC:

```
[root@nfsc ~]# showmount -a 192.168.56.10
```

```
All mount points on 192.168.56.10:
```

- заходим в каталог `/mnt/upload`:

```
[root@nfsc ~]# cd /mnt/upload
```

```
[root@nfsc upload]# 
```

- проверяем статус монтирования:

```
[root@nfsc upload]# mount | grep mnt
```

```
systemd-1 on /mnt type autofs (rw,relatime,fd=33,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=11161)
192.168.56.10:/srv/share/ on /mnt type nfs (rw,relatime,vers=3,rsize=32768,wsize=32768,namlen=255,hard,proto=udp,timeo=11,retrans=3,sec=sys,mountaddr=192.168.56.10,mountvers=3,mountport=20048,mountproto=udp,local_lock=none,addr=192.168.56.10)
```

- проверяем наличие ранее созданных файлов:

```
[root@nfsc upload]# ls -l
```

```
total 0
-rw-r--r--. 1 root      root      0 Apr 27 13:00 check_file
-rw-r--r--. 1 nfsnobody nfsnobody 0 Apr 27 13:05 client_file
```

- создаём тестовый файл:

```
[root@nfsc upload]# touch final_check
```

- проверяем, что файл успешно создан:

```
[root@nfsc upload]# ls -l
```

```
total 0
-rw-r--r--. 1 root      root      0 Apr 27 13:00 check_file
-rw-r--r--. 1 nfsnobody nfsnobody 0 Apr 27 13:05 client_file
-rw-r--r--. 1 nfsnobody nfsnobody 0 Apr 27 13:59 final_check
```

```
[root@nfss upload]# ls -l
```

```
total 0
-rw-r--r--. 1 root      root      0 Apr 27 13:00 check_file
-rw-r--r--. 1 nfsnobody nfsnobody 0 Apr 27 13:05 client_file
-rw-r--r--. 1 nfsnobody nfsnobody 0 Apr 27 13:59 final_check
```

Проверки прошли успешно, демонстрационный стенд работоспособен и готов к работе.

### **Создание автоматизированного Vagrantfile** ###

Вносим изменения в первоначальный Vagrantfile:


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
    nfss.vm.provision "shell", path: "nfss_script.sh"    
  end
 
  config.vm.define "nfsc" do |nfsc| 
    nfsc.vm.network "private_network", ip: "192.168.56.11",  virtualbox__intnet: "net1" 
    nfsc.vm.hostname = "nfsc"
    nfsc.vm.provision "shell", path: "nfsc_script.sh"  
  end 
end
```

Создаём 2 bash-скрипта: `nfss_script.sh` - для конфигурирования сервера и `nfsc_script.sh` - для конфигурирования клиента. В них описываем bash-командами ранее выполненные шаги.

```
adminkonstantin@2OSUbuntu:~/NFS$ touch nfss_script.sh nfsc_script.sh
```

В текстовом редакторе nano пишем скрипт для сервера nfss:

```
#!/bin/bash

# Устанавливаем доп. утилиты

sudo yum install -y nfs-utils

# Включаем firewall

sudo systemctl enable firewalld --now

# Разрешаем в firewall доступ к сервисам NFS

sudo firewall-cmd --add-service="nfs3" \
--add-service="rpc-bind" \
--add-service="mountd" \
--permanent
sudo firewall-cmd --reload

# Включаем сервер NFS

sudo systemctl enable nfs --now

# Cоздаём и настраиваем директорию, которая будет экспортирована

sudo mkdir -p /srv/share/upload
sudo chown -R nfsnobody:nfsnobody /srv/share
sudo chmod 0777 /srv/share/upload

# Создаём в файле /etc/exports структуру, которая позволит экспортировать ранее созданную директорию

sudo cat << EOF > /etc/exports
/srv/share 192.168.56.11/32(rw,sync,root_squash)
EOF

# Экспортируем ранее созданную директорию

sudo exportfs -r
```

В текстовом редакторе nano пишем скрипт для клиента nfsc:

```
#!/bin/bash

# Установим вспомогательные утилиты

sudo yum install -y nfs-utils

# Включаем firewall

sudo systemctl enable firewalld --now

# Правим /etc/fstab

sudo echo "192.168.56.10:/srv/share/ /mnt nfs vers=3,proto=udp,noauto,x-systemd.automount 0 0" >> /etc/fstab

# Выполняем перезагрузку сервисов

sudo systemctl daemon-reload
sudo systemctl restart remote-fs.target
```
Добавляем файлам скриптов права на исполнение:

```
adminkonstantin@2OSUbuntu:~/NFS$ chmod +x nfss_script.sh nfsc_script.sh
```

Скрипты для автоматизации развёртования готовы. Уничтожаем тестовый стенд и создаём его заново:

```
adminkonstantin@2OSUbuntu:~/NFS$ vagrant destroy -f
```

```
==> nfsc: Forcing shutdown of VM...
==> nfsc: Destroying VM and associated drives...
==> nfss: Forcing shutdown of VM...
==> nfss: Destroying VM and associated drives...
```

```
adminkonstantin@2OSUbuntu:~/NFS$ vagrant up
```

```
Bringing machine 'nfss' up with 'virtualbox' provider...
Bringing machine 'nfsc' up with 'virtualbox' provider...
==> nfss: Importing base box 'centos/7'...
==> nfss: Matching MAC address for NAT networking...
==> nfss: Checking if box 'centos/7' version '2004.01' is up to date...
==> nfss: Setting the name of the VM: NFS_nfss_1714233836510_2982
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
==> nfss: Running provisioner: shell...
    nfss: Running: /tmp/vagrant-shell20240427-33762-77z85l.sh
    nfss: Loaded plugins: fastestmirror
    nfss: Determining fastest mirrors
    nfss:  * base: mirror.ams1.nl.leaseweb.net
    nfss:  * extras: mirror.vimexx.nl
    nfss:  * updates: centos.mirror.triple-it.nl
    nfss: Resolving Dependencies
    nfss: --> Running transaction check
    nfss: ---> Package nfs-utils.x86_64 1:1.3.0-0.66.el7 will be updated
    nfss: ---> Package nfs-utils.x86_64 1:1.3.0-0.68.el7.2 will be an update
    nfss: --> Finished Dependency Resolution
    nfss: 
    nfss: Dependencies Resolved
    nfss: 
    nfss: ================================================================================
    nfss:  Package          Arch          Version                    Repository      Size
    nfss: ================================================================================
    nfss: Updating:
    nfss:  nfs-utils        x86_64        1:1.3.0-0.68.el7.2         updates        413 k
    nfss: 
    nfss: Transaction Summary
    nfss: ================================================================================
    nfss: Upgrade  1 Package
    nfss: 
    nfss: Total download size: 413 k
    nfss: Downloading packages:
    nfss: No Presto metadata available for updates
    nfss: Public key for nfs-utils-1.3.0-0.68.el7.2.x86_64.rpm is not installed
    nfss: warning: /var/cache/yum/x86_64/7/updates/packages/nfs-utils-1.3.0-0.68.el7.2.x86_64.rpm: Header V3 RSA/SHA256 Signature, key ID f4a80eb5: NOKEY
    nfss: Retrieving key from file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
    nfss: Importing GPG key 0xF4A80EB5:
    nfss:  Userid     : "CentOS-7 Key (CentOS 7 Official Signing Key) <security@centos.org>"
    nfss:  Fingerprint: 6341 ab27 53d7 8a78 a7c2 7bb1 24c6 a8a7 f4a8 0eb5
    nfss:  Package    : centos-release-7-8.2003.0.el7.centos.x86_64 (@anaconda)
    nfss:  From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
    nfss: Running transaction check
    nfss: Running transaction test
    nfss: Transaction test succeeded
    nfss: Running transaction
    nfss:   Updating   : 1:nfs-utils-1.3.0-0.68.el7.2.x86_64                          1/2
    nfss:   Cleanup    : 1:nfs-utils-1.3.0-0.66.el7.x86_64                            2/2
    nfss:   Verifying  : 1:nfs-utils-1.3.0-0.68.el7.2.x86_64                          1/2
    nfss:   Verifying  : 1:nfs-utils-1.3.0-0.66.el7.x86_64                            2/2
    nfss: 
    nfss: Updated:
    nfss:   nfs-utils.x86_64 1:1.3.0-0.68.el7.2
    nfss: 
    nfss: Complete!
    nfss: Created symlink from /etc/systemd/system/dbus-org.fedoraproject.FirewallD1.service to /usr/lib/systemd/system/firewalld.service.
    nfss: Created symlink from /etc/systemd/system/multi-user.target.wants/firewalld.service to /usr/lib/systemd/system/firewalld.service.
    nfss: success
    nfss: success
    nfss: Created symlink from /etc/systemd/system/multi-user.target.wants/nfs-server.service to /usr/lib/systemd/system/nfs-server.service.
==> nfsc: Importing base box 'centos/7'...
==> nfsc: Matching MAC address for NAT networking...
==> nfsc: Checking if box 'centos/7' version '2004.01' is up to date...
==> nfsc: Setting the name of the VM: NFS_nfsc_1714233912502_45115
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
==> nfsc: Running provisioner: shell...
    nfsc: Running: /tmp/vagrant-shell20240427-33762-uhi5v.sh
    nfsc: Loaded plugins: fastestmirror
    nfsc: Determining fastest mirrors
    nfsc:  * base: mirror.hostnet.nl
    nfsc:  * extras: mirror.hostnet.nl
    nfsc:  * updates: mirror.serverius.net
    nfsc: Resolving Dependencies
    nfsc: --> Running transaction check
    nfsc: ---> Package nfs-utils.x86_64 1:1.3.0-0.66.el7 will be updated
    nfsc: ---> Package nfs-utils.x86_64 1:1.3.0-0.68.el7.2 will be an update
    nfsc: --> Finished Dependency Resolution
    nfsc: 
    nfsc: Dependencies Resolved
    nfsc: 
    nfsc: ================================================================================
    nfsc:  Package          Arch          Version                    Repository      Size
    nfsc: ================================================================================
    nfsc: Updating:
    nfsc:  nfs-utils        x86_64        1:1.3.0-0.68.el7.2         updates        413 k
    nfsc: 
    nfsc: Transaction Summary
    nfsc: ================================================================================
    nfsc: Upgrade  1 Package
    nfsc: 
    nfsc: Total download size: 413 k
    nfsc: Downloading packages:
    nfsc: No Presto metadata available for updates
    nfsc: Public key for nfs-utils-1.3.0-0.68.el7.2.x86_64.rpm is not installed
    nfsc: warning: /var/cache/yum/x86_64/7/updates/packages/nfs-utils-1.3.0-0.68.el7.2.x86_64.rpm: Header V3 RSA/SHA256 Signature, key ID f4a80eb5: NOKEY
    nfsc: Retrieving key from file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
    nfsc: Importing GPG key 0xF4A80EB5:
    nfsc:  Userid     : "CentOS-7 Key (CentOS 7 Official Signing Key) <security@centos.org>"
    nfsc:  Fingerprint: 6341 ab27 53d7 8a78 a7c2 7bb1 24c6 a8a7 f4a8 0eb5
    nfsc:  Package    : centos-release-7-8.2003.0.el7.centos.x86_64 (@anaconda)
    nfsc:  From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
    nfsc: Running transaction check
    nfsc: Running transaction test
    nfsc: Transaction test succeeded
    nfsc: Running transaction
    nfsc:   Updating   : 1:nfs-utils-1.3.0-0.68.el7.2.x86_64                          1/2
    nfsc:   Cleanup    : 1:nfs-utils-1.3.0-0.66.el7.x86_64                            2/2
    nfsc:   Verifying  : 1:nfs-utils-1.3.0-0.68.el7.2.x86_64                          1/2
    nfsc:   Verifying  : 1:nfs-utils-1.3.0-0.66.el7.x86_64                            2/2
    nfsc: 
    nfsc: Updated:
    nfsc:   nfs-utils.x86_64 1:1.3.0-0.68.el7.2
    nfsc: 
    nfsc: Complete!
    nfsc: Created symlink from /etc/systemd/system/dbus-org.fedoraproject.FirewallD1.service to /usr/lib/systemd/system/firewalld.service.
    nfsc: Created symlink from /etc/systemd/system/multi-user.target.wants/firewalld.service to /usr/lib/systemd/system/firewalld.service.
```

Проводим проверку работоспособности, описанную выше и убеждаемся, что всё работает.
Задание выполнено.
