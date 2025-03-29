# Создание и размещение deb-пакета в локальном репозитории

## Создание пакета

1) Установка необходимых зависимостей :

root@linux:~# apt install -y build-essential devscripts debhelper  \
    libpcre3-dev zlib1g-dev libssl-dev cmake wget

2) Установка исходников nginx :

root@linux:~# mkdir ~/nginx-build && cd ~/nginx-build

root@linux:~/nginx-build# wget http://nginx.org/download/nginx-1.26.3.tar.gz

--2025-03-29 16:29:07--  http://nginx.org/download/nginx-1.26.3.tar.gz
Resolving nginx.org (nginx.org)... 3.125.197.172, 52.58.199.22
Connecting to nginx.org (nginx.org)|3.125.197.172|:80... connected.
HTTP request sent, awaiting response... 200 OK

root@linux:~/nginx-build# tar xzf nginx-1.26.3.tar.gz

root@linux:~/nginx-build# cd nginx-1.26.3

3) Установка модулей ngx_brotli :

root@linux:~/nginx-build/nginx-1.26.3# git clone --recursive https://github.com/google/ngx_brotli.git

root@linux:~/nginx-build/nginx-1.26.3# ./configure --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/lock/nginx.lock \
    --with-http_ssl_module \
    --with-http_gzip_static_module \
    --add-module=../ngx_brotli

root@linux:~/nginx-build/nginx-1.26.3# make -j$(nproc)
root@linux:~/nginx-build/nginx-1.26.3# make install

4) Создание структуры пакета и перемещение бинарников:

root@linux:~/nginx-build/nginx-1.26.3# mkdir -p ~/nginx-deb/DEBIAN

root@linux:~/nginx-build/nginx-1.26.3# mkdir -p ~/nginx-deb/usr/sbin

root@linux:~/nginx-build/nginx-1.26.3# mkdir -p ~/nginx-deb/etc/nginx

root@linux:~/nginx-build/nginx-1.26.3# mkdir -p ~/nginx-deb/lib/systemd/system

root@linux:~/nginx-build/nginx-1.26.3# mkdir -p ~/nginx-deb/var/log/nginx

root@linux:~/nginx-build/nginx-1.26.3# mkdir -p ~/nginx-deb/var/www/html

root@linux:~/nginx-build/nginx-1.26.3# cp /usr/sbin/nginx ~/nginx-deb/usr/sbin/

5) Создание systemd-файла :

root@linux:~/nginx-build/nginx-1.26.3# vim ~/nginx-deb/lib/systemd/system/nginx.service

[Unit]

Description=Nginx - High Performance Web Server

After=network.target

[Service]

Type=forking

ExecStart=/usr/sbin/nginx

ExecReload=/usr/sbin/nginx -s reload

ExecStop=/usr/sbin/nginx -s stop

PIDFile=/var/run/nginx.pid

Restart=always

[Install]

WantedBy=multi-user.target

6) Создание control-файла :

root@linux:~/nginx-build/nginx-1.26.3# vim ~/nginx-deb/DEBIAN/control

Package: nginx-custom

Version: 1.26.3-1

Section: web

Priority: optional

Architecture: amd64

Maintainer: Igor Maksimov imigormaximov@gmail.com

Depends: libc6, libpcre3, zlib1g, libssl3

Description: Custom Nginx 1.26.3 with ngx_brotli module

7) Сборка пакета :

root@linux:~/nginx-build/nginx-1.26.3# dpkg-deb --build ~/nginx-deb

dpkg-deb: building package 'nginx-custom' in '/root/nginx-deb.deb'.

root@linux:~/nginx-build/nginx-1.26.3# mv ~/nginx-deb.deb ~/nginx-custom_1.26.3-1_amd64.deb

root@linux:~/nginx-build/nginx-1.26.3# ls /root

nginx-custom_1.26.3-1_amd64.deb  nginx-deb



## Создание apt-репозтория

1) Подготовка структуры :

root@linux:~# mkdir -p /opt/myrepo/{conf,incoming,pool,db}

root@linux:~# chown -R $USER:$USER /opt/myrepo

2) Создание конфигурационного файла distributions :

root@linux:~/nginx-build/nginx-1.26.3# vim /opt/myrepo/distributions

Codename: stable

Suite: stable

Components: main

Architectures: amd64

SignWith: yes

3) Добавление пакета в репозиторий :

root@linux:~# reprepro -b /opt/myrepo includedeb local nginx-custom_1.26.3-1_amd64.deb

4) Размещение репозитория на сервере :

root@linux:~# vim /etc/apt/source.list 

deb [signed-by=/usr/share/keyrings/myrepo-archive-keyring.gpg] file:/opt/myrepo local main

## Проверка работы

root@linux:~# apt update

root@linux:~# systemctl enable nginx

Created symlink /etc/systemd/system/multi-user.target.wants/nginx.service → /lib/systemd/system/nginx.service.

root@linux:~# systemctl start nginx

root@linux:~# nginx -V 2>&1 | grep brotli

configure arguments: --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --pid-path=/var/run/nginx.pid --lock-path=/var/lock/nginx.lock --with-http_ssl_module --with-http_gzip_static_module --add-module=./ngx_brotli

root@linux:~# nginx -v

nginx version: nginx/1.26.3

