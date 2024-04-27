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
