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

