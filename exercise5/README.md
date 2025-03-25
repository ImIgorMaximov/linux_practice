Развертывание сервиса NFS и подключение к нему клиентов

# Настойка сервера NFS

1) Установка пакетов nfs :

root@linux:~# apt install nfs-kernel-server

2) Провека слушающих портов :

root@linux:~# ss -tulnp | grep "2049\|111"
udp   UNCONN 0      0                    0.0.0.0:111        0.0.0.0:*    users:(("rpcbind",pid=1695,fd=5),("systemd",pid=1,fd=111))
udp   UNCONN 0      0                       [::]:111           [::]:*    users:(("rpcbind",pid=1695,fd=7),("systemd",pid=1,fd=113))
tcp   LISTEN 0      64                   0.0.0.0:2049       0.0.0.0:*                                                              
tcp   LISTEN 0      4096                 0.0.0.0:111        0.0.0.0:*    users:(("rpcbind",pid=1695,fd=4),("systemd",pid=1,fd=105))
tcp   LISTEN 0      64                      [::]:2049          [::]:*                                                              
tcp   LISTEN 0      4096                    [::]:111           [::]:*    users:(("rpcbind",pid=1695,fd=6),("systemd",pid=1,fd=112))

3) Создание и настойка директории для экспорта nfs :

root@linux:~# mkdir -p /srv/share/upload
root@linux:~# chown -R nobody:nogroup /srv/share
root@linux:~# chmod 0777 /srv/share/upload
root@linux:~# 

4) Настойка файла exports :

root@linux:~# vim /etc/exports
/srv/share 10.160.107.164/24(rw,sync,root_squash)


5) Экспортируем ранее созданную директорию и проверяем:

root@linux:~# exportfs -ra
exportfs: /etc/exports [1]: Neither 'subtree_check' or 'no_subtree_check' specified for export "10.160.107.164/24:/srv/share".
  Assuming default behaviour ('no_subtree_check').
  NOTE: this default has changed since nfs-utils version 1.0.x

root@linux:~# systemctl restart nfs-kernel-server
root@linux:~# exportfs -s
/srv/share  10.160.107.164/24(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)

# Настойка клиента NFS

1) Установка пакета NFS :

admin-msk@linux:~$ sudo apt install nfs-common

2) Добавление строки в /etc/fstab :

root@operator:~# echo "10.160.107.239:/srv/share/ /mnt nfs vers=3,noauto,x-systemd.automount 0 0" >> /etc/fstab

3) Обновление сервиса и демонов :

root@operator:~# systemctl daemon-reload
root@operator:~# systemctl restart remote-fs.target

4) Применение изменений и провека монтиования :

root@operator:~# root@operator:~# mount -a
root@operator:~# mount | grep mnt

systemd-1 on /mnt type autofs (rw,relatime,fd=43,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=637511)
10.160.107.239:/srv/share/ on /mnt type nfs (rw,relatime,vers=3,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=10.160.107.239,mountvers=3,mountport=51053,mountproto=udp,local_lock=none,addr=10.160.107.239)


# Проверка работоспособности

1) Создание файла на сервере в каталоге /srv/share/upload:

root@linux:/srv/share/upload# > check_file
root@linux:/srv/share/upload# 

2) Проверка наличия файла на ВМ клиента :

root@operator:~# ls /mnt/upload/
check_file

3) Создание тестового файла на клиенте :

root@operator:~# > /mnt/upload/client_file
root@operator:~# ls /mnt/upload/
check_file  client_file

root@operator:/mnt/upload# showmount -a 10.160.107.239
All mount points on 10.160.107.239:
10.160.107.164:/srv/share
root@operator:/mnt/upload# mount | grep mnt
/home/igor/MyOffice_CO_3.3.iso on /mnt/myiso type udf (ro,relatime,iocharset=utf8)
systemd-1 on /mnt type autofs (rw,relatime,fd=43,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=637511)
10.160.107.239:/srv/share/ on /mnt type nfs (rw,relatime,vers=3,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=10.160.107.239,mountvers=3,mountport=51053,mountproto=udp,local_lock=none,addr=10.160.107.239)
