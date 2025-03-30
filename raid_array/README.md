Задание №2 Работа с mdadm

# Собрать RAID массив

1) Добавление 5-ти дисков размером 1 ГиБ:

root@linux:~# lshw -short | grep disk

/0/100/2.3/0/0     /dev/vda    disk           53GB Virtual I/O device

/0/100/2.6/0/0     /dev/vdb    disk           1073MB Virtual I/O device

/0/100/2.7/0/0     /dev/vdc    disk           1073MB Virtual I/O device

/0/100/3/0/0       /dev/vdd    disk           1073MB Virtual I/O device

/0/100/3.1/0/0     /dev/vde    disk           1073MB Virtual I/O device

/0/100/3.2/0/0     /dev/vdf    disk           1073MB Virtual I/O device

/0/100/1f.2/0.0.0  /dev/cdrom  disk           QEMU DVD-ROM

2) Вывод данных о дисках:

root@linux:~# fdisk -l

Disk /dev/vdb: 1 GiB, 1073741824 bytes, 2097152 sectors

Units: sectors of 1 * 512 = 512 bytes

Sector size (logical/physical): 512 bytes / 512 bytes

I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/vdc: 1 GiB, 1073741824 bytes, 2097152 sectors

Units: sectors of 1 * 512 = 512 bytes

Sector size (logical/physical): 512 bytes / 512 bytes

I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/vdd: 1 GiB, 1073741824 bytes, 2097152 sectors

Units: sectors of 1 * 512 = 512 bytes

Sector size (logical/physical): 512 bytes / 512 bytes

I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/vde: 1 GiB, 1073741824 bytes, 2097152 sectors

Units: sectors of 1 * 512 = 512 bytes

Sector size (logical/physical): 512 bytes / 512 bytes

I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/vdf: 1 GiB, 1073741824 bytes, 2097152 sectors

Units: sectors of 1 * 512 = 512 bytes

Sector size (logical/physical): 512 bytes / 512 bytes

I/O size (minimum/optimal): 512 bytes / 512 bytes

3) Проверка суперблоков-RAID на устройствах:

root@linux:~# mdadm --zero-superblock --force /dev/vd{b,c,d,e,f}

mdadm: Unrecognised md component device - /dev/vdb

mdadm: Unrecognised md component device - /dev/vdc

mdadm: Unrecognised md component device - /dev/vdd

mdadm: Unrecognised md component device - /dev/vde

mdadm: Unrecognised md component device - /dev/vdf

4) Создание RAID 5-го уровня из 5 устройств:

root@linux:~# mdadm --create --verbose /dev/md0 -l 5 -n 5 /dev/vd{b,c,d,e,f}

mdadm: layout defaults to left-symmetric

mdadm: layout defaults to left-symmetric

mdadm: chunk size defaults to 512K

mdadm: size set to 1046528K

mdadm: Defaulting to version 1.2 metadata

mdadm: array /dev/md0 started.

5) Проверка сборки: 

root@linux:~# cat /proc/mdstat 

Personalities : [linear] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10] 

md0 : active raid5 vdf[5] vde[3] vdd[2] vdc[1] vdb[0]

      4186112 blocks super 1.2 level 5, 512k chunk, algorithm 2 [5/5] [UUUUU]

6) Вывод при помощи mdadm: 

root@linux:~# mdadm -D /dev/md0

    Number   Major   Minor   RaidDevice State

       0     253       16        0      active sync   /dev/vdb

       1     253       32        1      active sync   /dev/vdc

       2     253       48        2      active sync   /dev/vdd

       3     253       64        3      active sync   /dev/vde

       5     253       80        4      active sync   /dev/vdf


# Сломать и починить RAID


1) Фейлим блочное устройство (например, vdc):

root@linux:~# mdadm /dev/md0 --fail /dev/vdc

mdadm: set /dev/vdc faulty in /dev/md0

2) Проверка состояния: 

root@linux:~# cat /proc/mdstat

Personalities : [linear] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10] 

md0 : active raid5 vdf[5] vde[3] vdd[2] vdc[1](F) vdb[0]

      4186112 blocks super 1.2 level 5, 512k chunk, algorithm 2 [5/4] [U_UUU]

root@linux:~# mdadm -D /dev/md0

    Number   Major   Minor   RaidDevice State

       0     253       16        0      active sync   /dev/vdb

       -       0        0        1      removed

       2     253       48        2      active sync   /dev/vdd

       3     253       64        3      active sync   /dev/vde

       5     253       80        4      active sync   /dev/vdf

       1     253       32        -      faulty   /dev/vdc

3) Удаление сломанного диска из RAID-массива:

root@linux:~# mdadm /dev/md0 --remove /dev/vdc

mdadm: hot removed /dev/vdc from /dev/md0

4) Добавляемм новый диск на сервер и прикрепляем его в наш RAID:

root@linux:~# mdadm /dev/md0 --add /dev/vdg

mdadm: added /dev/vdg

5) Проверка: 

root@linux:~# cat /proc/mdstat

Personalities : [linear] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10] 

md0 : active raid5 vdg[6] vdf[5] vde[3] vdd[2] vdb[0]

      4186112 blocks super 1.2 level 5, 512k chunk, algorithm 2 [5/5] [UUUUU]


root@linux:~# mdadm -D /dev/md0

    Number   Major   Minor   RaidDevice State

       0     253       16        0      active sync   /dev/vdb

       6     253       96        1      active sync   /dev/vdg

       2     253       48        2      active sync   /dev/vdd

       3     253       64        3      active sync   /dev/vde

       5     253       80        4      active sync   /dev/vdf



# Создание GPT-таблицы из пяти разделов и монитование их в системе

1) Создаем раздел GPT на RAID:

root@linux:~# parted -s /dev/md0 mklabel gpt

2) Создаем партиции:

root@linux:~# parted /dev/md0 mkpart primary ext4 0% 20%

root@linux:~# parted /dev/md0 mkpart primary ext4 20% 40%

root@linux:~# parted /dev/md0 mkpart primary ext4 40% 60%

root@linux:~# parted /dev/md0 mkpart primary ext4 60% 80%

root@linux:~# parted /dev/md0 mkpart primary ext4 80% 100%

3) После создания партиций прикрепляем на них ФС и монтируем по каталогам:

root@linux:~# mkdir -p /raid/part{1,2,3,4,5}

root@linux:~# for i in $(seq 1 5); do mount /dev/md0p$i /raid/part$i; done

4) Проверка корректности создания и монтирования:

root@linux:~# df -h

Filesystem                         Size  Used Avail Use% Mounted on

/dev/md0p1                         786M   24K  729M   1% /raid/part1

/dev/md0p2                         788M   24K  731M   1% /raid/part2

/dev/md0p3                         786M   24K  729M   1% /raid/part3

/dev/md0p4                         788M   24K  731M   1% /raid/part4

/dev/md0p5                         786M   24K  729M   1% /raid/part5

root@linux:~# mount | grep /dev/md0

/dev/md0p1 on /raid/part1 type ext4 (rw,relatime,stripe=512)

/dev/md0p2 on /raid/part2 type ext4 (rw,relatime,stripe=512)

/dev/md0p3 on /raid/part3 type ext4 (rw,relatime,stripe=512)

/dev/md0p4 on /raid/part4 type ext4 (rw,relatime,stripe=512)

/dev/md0p5 on /raid/part5 type ext4 (rw,relatime,stripe=512)




