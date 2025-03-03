# Задание №1 Обновление ядра системы


1) Текущая версия ядра:
root@linux:~# uname -r
5.15.0-133-generiс

2) Создание и переход в директорию kernel:
root@linux:~# mkdir kernel && cd kernel

3) Скачивание пакетов версии v6.13.5 :

root@linux:~/kernel# wget https://kernel.ubuntu.com/mainline/v6.13.5/amd64/linux-headers-6.13.5-061305-generic_6.13.5-061305.202502271338_amd64.deb
--2025-03-03 14:06:30--  https://kernel.ubuntu.com/mainline/v6.13.5/amd64/linux-headers-6.13.5-061305-generic_6.13.5-061305.202502271338_amd64.deb
Resolving kernel.ubuntu.com (kernel.ubuntu.com)... 185.125.189.76, 185.125.189.75, 185.125.189.74
Connecting to kernel.ubuntu.com (kernel.ubuntu.com)|185.125.189.76|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 3827358 (3.6M) [application/x-debian-package]
Saving to: ‘linux-headers-6.13.5-061305-generic_6.13.5-061305.202502271338_amd64.deb’

linux-headers-6.13.5-061305-generic_6.13.5- 100%[========================================================================================>]   3.65M  9.37MB/s    in 0.4s    

2025-03-03 14:06:31 (9.37 MB/s) - ‘linux-headers-6.13.5-061305-generic_6.13.5-061305.202502271338_amd64.deb’ saved [3827358/3827358]

root@linux:~/kernel# wget https://kernel.ubuntu.com/mainline/v6.13.5/amd64/linux-headers-6.13.5-061305_6.13.5-061305.202502271338_all.deb
--2025-03-03 14:07:06--  https://kernel.ubuntu.com/mainline/v6.13.5/amd64/linux-headers-6.13.5-061305_6.13.5-061305.202502271338_all.deb
Resolving kernel.ubuntu.com (kernel.ubuntu.com)... 185.125.189.74, 185.125.189.75, 185.125.189.76
Connecting to kernel.ubuntu.com (kernel.ubuntu.com)|185.125.189.74|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 13885596 (13M) [application/x-debian-package]
Saving to: ‘linux-headers-6.13.5-061305_6.13.5-061305.202502271338_all.deb’

linux-headers-6.13.5-061305_6.13.5-061305.2 100%[========================================================================================>]  13.24M  21.1MB/s    in 0.6s    

2025-03-03 14:07:07 (21.1 MB/s) - ‘linux-headers-6.13.5-061305_6.13.5-061305.202502271338_all.deb’ saved [13885596/13885596]

root@linux:~/kernel# wget https://kernel.ubuntu.com/mainline/v6.13.5/amd64/linux-image-unsigned-6.13.5-061305-generic_6.13.5-061305.202502271338_amd64.deb
--2025-03-03 14:07:37--  https://kernel.ubuntu.com/mainline/v6.13.5/amd64/linux-image-unsigned-6.13.5-061305-generic_6.13.5-061305.202502271338_amd64.deb
Resolving kernel.ubuntu.com (kernel.ubuntu.com)... 185.125.189.76, 185.125.189.74, 185.125.189.75
Connecting to kernel.ubuntu.com (kernel.ubuntu.com)|185.125.189.76|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 15882432 (15M) [application/x-debian-package]
Saving to: ‘linux-image-unsigned-6.13.5-061305-generic_6.13.5-061305.202502271338_amd64.deb’

linux-image-unsigned-6.13.5-061305-generic_ 100%[========================================================================================>]  15.15M  15.3MB/s    in 1.0s    

2025-03-03 14:07:38 (15.3 MB/s) - ‘linux-image-unsigned-6.13.5-061305-generic_6.13.5-061305.202502271338_amd64.deb’ saved [15882432/15882432]

root@linux:~/kernel# wget https://kernel.ubuntu.com/mainline/v6.13.5/amd64/linux-modules-6.13.5-061305-generic_6.13.5-061305.202502271338_amd64.deb
--2025-03-03 14:08:16--  https://kernel.ubuntu.com/mainline/v6.13.5/amd64/linux-modules-6.13.5-061305-generic_6.13.5-061305.202502271338_amd64.deb
Resolving kernel.ubuntu.com (kernel.ubuntu.com)... 185.125.189.74, 185.125.189.76, 185.125.189.75
Connecting to kernel.ubuntu.com (kernel.ubuntu.com)|185.125.189.74|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 191344832 (182M) [application/x-debian-package]
Saving to: ‘linux-modules-6.13.5-061305-generic_6.13.5-061305.202502271338_amd64.deb’

linux-modules-6.13.5-061305-generic_6.13.5- 100%[========================================================================================>] 182.48M  4.28MB/s    in 56s     

2025-03-03 14:09:13 (3.27 MB/s) - ‘linux-modules-6.13.5-061305-generic_6.13.5-061305.202502271338_amd64.deb’ saved [191344832/191344832]

4) Установка всех пакетов: 
root@linux:~/kernel# dpkg -i *.deb
(Reading database ... 169916 files and directories currently installed.)
Preparing to unpack linux-headers-6.13.5-061305_6.13.5-061305.202502271338_all.deb ...
Unpacking linux-headers-6.13.5-061305 (6.13.5-061305.202502271338) over (6.13.5-061305.202502271338) ...

5) Проверка каталога /boot:

root@linux:~/kernel# ls -la /boot
total 441020
drwxr-xr-x  4 root root      4096 Mar  3 14:14 .
drwxr-xr-x 20 root root      4096 Mar  3 07:49 ..
-rw-r--r--  1 root root    262072 Aug  2  2024 config-5.15.0-119-generic
-rw-r--r--  1 root root    262228 Feb  7 17:44 config-5.15.0-133-generic
-rw-r--r--  1 root root    310720 Feb 27 13:38 config-6.13.5-061305-generic
drwxr-xr-x  5 root root      4096 Mar  3 14:14 grub
lrwxrwxrwx  1 root root        32 Mar  3 14:10 initrd.img -> initrd.img-6.13.5-061305-generic
-rw-r--r--  1 root root 106277326 Mar  3 09:52 initrd.img-5.15.0-119-generic
-rw-r--r--  1 root root 106341177 Mar  3 09:53 initrd.img-5.15.0-133-generic
-rw-r--r--  1 root root 176182352 Mar  3 14:14 initrd.img-6.13.5-061305-generic
lrwxrwxrwx  1 root root        29 Mar  3 14:10 initrd.img.old -> initrd.img-5.15.0-133-generic
drwx------  2 root root     16384 Mar  3 07:46 lost+found
-rw-------  1 root root   6289146 Aug  2  2024 System.map-5.15.0-119-generic
-rw-------  1 root root   6295053 Feb  7 17:44 System.map-5.15.0-133-generic
-rw-------  1 root root  10067508 Feb 27 13:38 System.map-6.13.5-061305-generic
lrwxrwxrwx  1 root root        29 Mar  3 14:10 vmlinuz -> vmlinuz-6.13.5-061305-generic
-rw-------  1 root root  11704712 Aug  2  2024 vmlinuz-5.15.0-119-generic
-rw-------  1 root root  11711400 Feb  7 18:12 vmlinuz-5.15.0-133-generic
-rw-------  1 root root  15847936 Feb 27 13:38 vmlinuz-6.13.5-061305-generic
lrwxrwxrwx  1 root root        26 Mar  3 14:10 vmlinuz.old -> vmlinuz-5.15.0-133-generic

6) Перезагружаем систему :

root@linux:~/kernel# shutdown -r now

7) Обновление конфигурации загрузчика:

root@linux:~/kernel# update-grub
Sourcing file `/etc/default/grub'
Sourcing file `/etc/default/grub.d/init-select.cfg'
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-6.13.5-061305-generic
Found initrd image: /boot/initrd.img-6.13.5-061305-generic
Found linux image: /boot/vmlinuz-5.15.0-133-generic
Found initrd image: /boot/initrd.img-5.15.0-133-generic
Found linux image: /boot/vmlinuz-5.15.0-119-generic
Found initrd image: /boot/initrd.img-5.15.0-119-generic
Warning: os-prober will not be executed to detect other bootable partitions.
Systems on them will not be added to the GRUB boot configuration.
Check GRUB_DISABLE_OS_PROBER documentation entry.
done

8) Выбор загрузки нового ядра по умолчанию:

root@linux:~/kernel# grub-set-default 0

9) После перезагрузки проверяем версию ядра:

root@linux:~/kernel# uname -r
6.13.5-061305-generic





