## Работа с systemd

# Service, который мониторит раз в 30 секунд лог на предмет наличия ключевого слова

1) Создание файла с конфигурацией сервиса в директории /etc/default :

root@linux-ubuntu:~# vim /etc/default/watchlog

Configuration file for my watchlog service

lace it to /etc/default

File and word in that file that we will be monit

WORD="ALERT"

LOG=/var/log/watchlog.log

2) Создание /var/log/watchlog.log :

root@linux-ubuntu:~# vim /var/log/watchlog.log

3) Создание скрипта :

root@linux-ubuntu:~# cat > /opt/watchlog.sh

#!/bin/bash

WORD=$1

LOG=$2

DATE=`date`

if grep $WORD $LOG &> /dev/null

then

logger "$DATE: I found word, Master!"

else

exit 0

fi

4) Добавление прав на исполнение : 

root@linux-ubuntu:~# chmod +x /opt/watchlog.sh

5) Создание юнита для сервиса :

root@linux-ubuntu:~# cat > /etc/systemd/system/watchlog.service

[Unit]

Description=My watchlog service

[Service]

Type=oneshot

EnvironmentFile=/etc/default/watchlog

ExecStart=/opt/watchlog.sh $WORD $LOG

6) Создание юнита для timer :

root@linux-ubuntu:~# cat > /etc/systemd/system/watchlog.timer

[Timer]

OnUnitActiveSec=30

Unit=watchlog.service

[Install]

WantedBy=multi-user.target

root@linux-ubuntu:~# systemctl start watchlog.timer

7) Проверка внесения новых слов :

root@linux-ubuntu:~# сat /var/log/watchlog.log

This is a normal log message

ALERT: This is an important message!

root@linux-ubuntu:~# /opt/watchlog.sh "ALERT" "/var/log/watchlog.log"

8) В режиме реального времени в другой сессии tmux видим вывод логов :

root@linux-ubuntu:~# tail -f /var/log/syslog | grep word

Apr  4 12:49:18 linux-ubuntu igor: Fri Apr  4 12:49:18 UTC 2025: I found word, Master!






# Установка spawn-fcgi и создание unit-файл (spawn-fcgi.sevice) с помощью переделки init-скрипта


1) Установка spawn-fcgi и необходимых зависимостей :

root@linux-ubuntu:~# apt install spawn-fcgi php php-cgi php-cli  apache2 libapache2-mod-fcgid -y

2) Создание файла с настройками для сервиса :

root@linux-ubuntu:~# mkdir /etc/spawn-fcgi/

root@linux-ubuntu:~# tee -a /etc/spawn-fcgi/fcgi.conf << EOF

You must set some working options before the "spawn-fcgi" service will work.

If SOCKET points to a file, then this file is cleaned up by the init script.

See spawn-fcgi(1) for all possible options.

Example :

SOCKET=/var/run/php-fcgi.sock

OPTIONS="-u www-data -g www-data -s $SOCKET -S -M 0600 -C 32 -F 1 -- /usr/bin/php-cgi"

EOF

3) Юнит файл : 

root@linux-ubuntu:~# tee -a /etc/systemd/system/spawn-fcgi.service << EOF
> [Unit]

> Description=Spawn-fcgi startup service by Otus

> After=network.target
> 
> [Service]

> Type=simple

> PIDFile=/var/run/spawn-fcgi.pid

> EnvironmentFile=/etc/spawn-fcgi/fcgi.conf

> ExecStart=/usr/bin/spawn-fcgi -n $OPTIONS

> KillMode=process
> 
> [Install]

> WantedBy=multi-user.target

> EOF

4) Запуск и проверка сервиса :

root@linux-ubuntu:~# systemctl start spawn-fcgi

root@linux-ubuntu:~# systemctl status spawn-fcgi


spawn-fcgi.service - Spawn-fcgi startup service by Otus

     Loaded: loaded (/etc/systemd/system/spawn-fcgi.service; disabled; vendor preset: enabled)

     Active: active (running) since Fri 2025-04-04 13:57:10 UTC; 5s ago

# Доработка unit-файла Nginx (nginx.service) для запуска нескольких инстансов сервера с разными конфигурационными файлами одновременно

1) Установка nginx :

root@linux-ubuntu:~# apt install nginx -y

2) Cоздание нового Unit для работы с шаблонами (/etc/systemd/system/nginx@.service):

[Unit]

Description=A high performance web server and a reverse proxy server

Documentation=man:nginx(8)

After=network.target nss-lookup.target

[Service]

Type=forking

PIDFile=/run/nginx-%I.pid

ExecStartPre=/usr/sbin/nginx -t -c /etc/nginx/nginx-%I.conf -q -g 'daemon on; master_process on;'

ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx-%I.conf -g 'daemon on; master_process on;'

ExecReload=/usr/sbin/nginx -c /etc/nginx/nginx-%I.conf -g 'daemon on; master_process on;' -s reload

ExecStop=-/sbin/start-stop-daemon --quiet --stop --retry QUIT/5 --pidfile /run/nginx-%I.pid

TimeoutStopSec=5

KillMode=mixed

[Install]

WantedBy=multi-user.target

3) Создание файлов конфигурации (/etc/nginx/nginx-first.conf, /etc/nginx/nginx-second.conf) :

- Создадим копии из стандартного конфига :

root@linux-ubuntu:~# cp /etc/nginx/nginx.conf /etc/nginx/nginx-first.conf

root@linux-ubuntu:~# cp /etc/nginx/nginx.conf /etc/nginx/nginx-second.conf

- Отредактируем файлы :

 Меняем секцию в конфигах:
 pid /run/nginx-first.pid; и порт listen 9001;

 pid /run/nginx-second.pid; и порт listen 9002;

Комментируем строку :

#include /etc/nginx/sites-enabled/*;

4) Запуск сервисов и проверка работы :

root@linux-ubuntu:~# systemctl start nginx@first

root@linux-ubuntu:~# systemctl start nginx@second

root@linux-ubuntu:~# systemctl status nginx@second

● nginx@second.service - A high performance web server and a reverse proxy server

     Loaded: loaded (/etc/systemd/system/nginx@.service; disabled; vendor preset: enabled)

     Active: active (running) since Fri 2025-04-04 15:05:21 UTC; 1min 24s ago


root@linux-ubuntu:~# systemctl status nginx@first

● nginx@first.service - A high performance web server and a reverse proxy server

     Loaded: loaded (/etc/systemd/system/nginx@.service; disabled; vendor preset: enabled)

     Active: active (running) since Fri 2025-04-04 14:38:11 UTC; 28min ago

root@linux-ubuntu:~# ss -tnulp | grep nginx

tcp    LISTEN  0       511                    0.0.0.0:9001        0.0.0.0:*      users:(("nginx",pid=123015,fd=6),("nginx",pid=123014,fd=6),("nginx",pid=123013,fd=6),("nginx",pid=123012,fd=6),("nginx",pid=123011,fd=6),("nginx",

pid=123010,fd=6),("nginx",pid=123009,fd=6),("nginx",pid=123008,fd=6),("nginx",pid=123007,fd=6),("nginx",pid=123006,fd=6),("nginx",pid=123005,fd=6))


tcp    LISTEN  0       511                  127.0.0.1:9002        0.0.0.0:*      users:(("nginx",pid=123206,fd=6),("nginx",pid=123205,fd=6),("nginx",pid=123204,fd=6),("nginx",pid=123203,fd=6),("nginx",pid=123202,fd=6),("nginx",

pid=123201,fd=6),("nginx",pid=123200,fd=6),("nginx",pid=123199,fd=6),("nginx",pid=123198,fd=6),("nginx",pid=123197,fd=6),("nginx",pid=123196,fd=6))


tcp    LISTEN  0       511                    0.0.0.0:80          0.0.0.0:*      users:(("nginx",pid=123015,fd=7),("nginx",pid=123014,fd=7),("nginx",pid=123013,fd=7),("nginx",pid=123012,fd=7),("nginx",pid=123011,fd=7),("nginx",
pid=123010,fd=7),("nginx",pid=123009,fd=7),("nginx",pid=123008,fd=7),("nginx",pid=123007,fd=7),("nginx",pid=123006,fd=7),("nginx",pid=123005,fd=7))


tcp    LISTEN  0       511                       [::]:80             [::]:*      users:(("nginx",pid=123015,fd=8),("nginx",pid=123014,fd=8),("nginx",pid=123013,fd=8),("nginx",pid=123012,fd=8),("nginx",pid=123011,fd=8),("nginx",pid=123010,fd=8),("nginx",pid=123009,fd=8),("nginx",pid=123008,fd=8),("nginx",pid=123007,fd=8),("nginx",pid=123006,fd=8),("nginx",pid=123005,fd=8))


