## Настройки GRUB
## Беспарольный доступ в систему
## Установка системы с LVM

# Включить отображение меню GRUB

1) Отредактировать файл /etc/default/grub для добавления задержки при загрузке :

root@linux:~# vim /etc/default/grub

GRUB_DEFAULT=0

#GRUB_TIMEOUT_STYLE=hidden

GRUB_TIMEOUT=10

GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`

GRUB_CMDLINE_LINUX_DEFAULT=""

GRUB_CMDLINE_LINUX=""

2) Обновляем конфигурацию загрузчика и перезагружаемся для проверки :

root@linux:~# update-grub

root@linux:~# shutdown -r now

3) Меню загрузчика представлено в файле grub_menu.png









# Попасть в систему без пароля несколькими способами

1) 1 Способ. В параметрах меню загрузчика добавляем в строку linux (grub_param.png):

init=/bin/bash 

2) Меняем ro -> rw для доступа записи :

root@(none):/# echo test >> file.txt

root@(none):/# exit

3) 2 Способ. Войти через меню recovery mode. и выбрать пункт: Drop to root shell prompt (recover_mode.png)

# Установить систему с LVM

1) Текущее состояние системы :

root@linux:~# vgs

  VG        #PV #LV #SN Attr   VSize   VFree 

  ubuntu-vg   1   2   0 wz--n- <48.00g     0 

  2) Переименование :

  root@linux:~# vgrename ubuntu-vg ubuntu-igor

  Volume group "ubuntu-vg" successfully renamed to "ubuntu-igor"

  3) Правим /boot/grub/grub.cfg, заменяем старое название VG на новое :

  root@linux:~# vim /boot/grub/grub.cfg 

  :%s/ubuntu--vg/ubuntu--igor

  4) Выполняем перезагрузку и проверяем :

  root@linux:~# vgs

  VG        #PV #LV #SN Attr   VSize   VFree 

  ubuntu-igor   1   2   0 wz--n- <48.00g     0 

