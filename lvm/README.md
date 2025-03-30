Файловые системы и LVM

# LVM начало работы

1)  Диски vdb, vdc будут ипользоваться для базовых вещей и снапшотов. Диски vdd,vde созданы для lvm mirror.

root@linux:~# lsblk

NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS

loop0                       7:0    0 63.9M  1 loop /snap/core20/2318

loop1                       7:1    0 63.7M  1 loop /snap/core20/2496

loop2                       7:2    0   87M  1 loop /snap/lxd/29351

loop3                       7:3    0 89.4M  1 loop /snap/lxd/31333

loop4                       7:4    0 44.4M  1 loop /snap/snapd/23771

loop5                       7:5    0 44.4M  1 loop /snap/snapd/23545

sr0                        11:0    1 1024M  0 rom  

vda                       253:0    0   50G  0 disk 

├─vda1                    253:1    0    1M  0 part 

├─vda2                    253:2    0    2G  0 part /boot

└─vda3                    253:3    0   48G  0 part 

  └─ubuntu--vg-ubuntu--lv 252:0    0   24G  0 lvm  /

vdb                       253:16   0   10G  0 disk 

vdc                       253:32   0    2G  0 disk 

vdd                       253:48   0    1G  0 disk 

vde                       253:64   0    1G  0 disk 

2) Просмотр информации при помощи lvmdiskscan:

root@linux:~# lvmdiskscan

  /dev/loop0 [     <63.95 MiB] 

  /dev/loop1 [     <63.75 MiB] 

  /dev/loop2 [     <87.04 MiB] 

  /dev/vda2  [       2.00 GiB] 

  /dev/loop3 [      89.40 MiB] 

  /dev/vda3  [     <48.00 GiB] LVM physical volume

  /dev/loop4 [     <44.45 MiB] 

  /dev/loop5 [     <44.44 MiB] 

  /dev/vdb   [      10.00 GiB] 

  /dev/vdc   [       2.00 GiB] 

  /dev/vdd   [       1.00 GiB] 

  /dev/vde   [       1.00 GiB] 

  4 disks

  7 partitions

  0 LVM physical volume whole disks

  1 LVM physical volume

3) Создание физического тома для vdb:

root@linux:~# pvcreate dev/vdb

  Physical volume "/dev/vdb" successfully created.

4) Создание vg и добавление в него физического тома pv1:

root@linux:~# vgcreate vg_data /dev/vdb 

  Volume group "vg_data" successfully created

5) Создание логического тома экстентами:

root@linux:~# lvcreate -l +80%FREE -n lv1 vg_data

  Logical volume "lv1" created.

6) Просмотр информации о vg:

root@linux:~# vgdisplay vg_data

  --- Volume group ---

  VG Name               vg_data

  System ID             

  Format                lvm2

  Metadata Areas        1

  Metadata Sequence No  2

  VG Access             read/write

  VG Status             resizable

  MAX LV                0

  Cur LV                1

  Open LV               0

  Max PV                0

  Cur PV                1

  Act PV                1

  VG Size               <10.00 GiB

  PE Size               4.00 MiB

  Total PE              2559

  Alloc PE / Size       2047 / <8.00 GiB

  Free  PE / Size       512 / 2.00 GiB

  VG UUID               FC2hKu-FB0R-Is8Z-c2mA-G56l-nEYS-sQMGNA

7) Просмотр дисков, которые входят в состав vg: 

root@linux:~# vgdisplay -v vg_data | grep -i 'pv name'

  PV Name               /dev/vdb 

8) Просмотр информации о созданном логическом томе: 

root@linux:~# lvdisplay /dev/vg_data/lv1 

  --- Logical volume ---

  LV Path                /dev/vg_data/lv1

  LV Name                lv1

  VG Name                vg_data

  LV UUID                7qih7v-7pSL-afX2-g6EU-PbpJ-1wSf-pqBdbG

  LV Write Access        read/write

  LV Creation host, time linux, 2025-03-20 09:45:55 +0000

  LV Status              available

  LV Size                <8.00 GiB

  Current LE             2047

  Segments               1

  Allocation             inherit

  Read ahead sectors     auto

  - currently set to     256

  Block device           252:1

9) Создание логического тома абсолютным значением: 

root@linux:~# lvcreate -L 100M -n lv2 vg_data

  Logical volume "lv2" created.

10) Просмот информации о логических томах:

root@linux:~# lvs

  LV        VG        Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert

  ubuntu-lv ubuntu-vg -wi-ao---- <24.00g                                                    

  lv1       vg_data   -wi-a-----  <8.00g      

  lv2       vg_data   -wi-a----- 100.00m 

11) Создание файловой системы на lv1 и монтирование к каталог /data:

mkfs.ext4 /dev/vg_data/lv1
…
Allocating group tables: done       

Writing inode tables: done        

Creating journal (32768 blocks): done

Writing superblocks and filesystem accounting information: done

12) Проверка:

root@linux:~# df -h | grep lv1

/dev/mapper/vg_data-lv1            7.8G   24K  7.4G   1% /data

# Расширение LVM

1) Создание физического тома из /dev/vdc:

root@linux:~# pvcreate dev/vdc

  Physical volume "/dev/vdc" successfully created.

2) Расширим vg_data, добавив в него физический том диска /dev/vdc:

root@linux:~# vgextend vg_data /dev/vdc 

  Volume group "vg_data" successfully extended

3) Проверка добавления:

root@linux:~# vgdisplay -v vg_data | grep -i "pv name"

  PV Name               /dev/vdb     

  PV Name               /dev/vdc 

root@linux:~# vgs | grep vg_data

  vg_data     2   2   0 wz--n-  11.99g <3.90g

4) Имитация занятого места :

root@linux:~# dd if=/dev/zero of=/data/test.log bs=1M count=8000 status=progress

8175747072 bytes (8.2 GB, 7.6 GiB) copied, 45 s, 182 MB/s

dd: error writing '/data/test.log': No space left on device

7944+0 records in

7943+0 records out

8329297920 bytes (8.3 GB, 7.8 GiB) copied, 45.9094 s, 181 MB/s

5) Провека занятого места:

root@linux:~# df -Th /data

Filesystem              Type  Size  Used Avail Use% Mounted on

/dev/mapper/vg_data-lv1 ext4  7.8G  7.8G     0 100% /data

6) Расширим логический том lv1 :

root@linux:~# lvextend -l 80%FREE /dev/vg_data/lv1

  New size given (799 extents) not larger than existing size (2047 extents)

root@linux:~# lvextend -l +80%FREE /dev/vg_data/lv1

  Size of logical volume vg_data/lv1 changed from <8.00 GiB (2047 extents) to <11.12 GiB (2846 extents).

  Logical volume vg_data/lv1 successfully resized.

7) Расширим файловую систему и проверим:

root@linux:~# resize2fs /dev/vg_data/lv1 

resize2fs 1.46.5 (30-Dec-2021)

Filesystem at /dev/vg_data/lv1 is mounted on /data; on-line resizing required

old_desc_blocks = 1, new_desc_blocks = 2

The filesystem on /dev/vg_data/lv1 is now 2914304 (4k) blocks long.

root@linux:~# df -Th /data

Filesystem              Type  Size  Used Avail Use% Mounted on

/dev/mapper/vg_data-lv1 ext4   11G  7.8G  2.6G  76% /data

8) Уменьшение lv1 и ФС :

root@linux:~# umount /data/

root@linux:~# e2fsck -fy /dev/vg_data/lv1 

e2fsck 1.46.5 (30-Dec-2021)

Pass 1: Checking inodes, blocks, and sizes

Pass 2: Checking directory structure

Pass 3: Checking directory connectivity

Pass 4: Checking reference counts

Pass 5: Checking group summary information

/dev/vg_data/lv1: 12/729088 files (0.0% non-contiguous), 2105907/2914304 blocks

root@linux:~# resize2fs /dev/vg_data/lv1 10G

resize2fs 1.46.5 (30-Dec-2021)

Resizing the filesystem on /dev/vg_data/lv1 to 2621440 (4k) blocks.

The filesystem on /dev/vg_data/lv1 is now 2621440 (4k) blocks long.

root@linux:~# lvreduce /dev/vg_data/lv1 -L 10G

  WARNING: Reducing active logical volume to 10.00 GiB.

  THIS MAY DESTROY YOUR DATA (filesystem etc.)

Do you really want to reduce vg_data/lv1? [y/n]: y

  Size of logical volume vg_data/lv1 changed from <11.12 GiB (2846 extents) to 10.00 GiB (2560 extents).

  Logical volume vg_data/lv1 successfully resized.

9) Проверка, что ФС и lv необходимого размера:

root@linux:~# mount /dev/vg_data/lv1 /data

root@linux:~# df -Th /data

Filesystem              Type  Size  Used Avail Use% Mounted on

/dev/mapper/vg_data-lv1 ext4  9.8G  7.8G  1.6G  84% /data

root@linux:~# lvs /dev/vg_data/lv1

  LV   VG      Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert

  lv1  vg_data -wi-ao---- 10.00g



# Работа со снапшотами

1) Создание снапшота:

root@linux:~# lvcreate -L 500M -s -n lv-snap /dev/vg_data/lv1

  Logical volume "lv-snap" create

root@linux:~# vgs -o +lv_size,lv_name | grep lv

  ubuntu-vg   1   1   0 wz--n- <48.00g 24.00g <24.00g ubuntu-lv

  vg_data     2   3   1 wz--n-  11.99g <1.41g  10.00g lv1      

  vg_data     2   3   1 wz--n-  11.99g <1.41g 100.00m lv2      

  vg_data     2   3   1 wz--n-  11.99g <1.41g 500.00m lv-snap 

2) Монтирование снапшота в директорию /data-snap:

root@linux:~# mkdir /data-snap

root@linux:~# mount /dev/vg_data/lv-snap /data-snap/

root@linux:~# ll /data-snap/

total 8134108

drwxr-xr-x  3 root root       4096 Mar 20 10:42 ./

drwxr-xr-x 23 root root       4096 Mar 20 12:10 ../

drwx------  2 root root      16384 Mar 20 10:31 lost+found/

-rw-r--r--  1 root root 8329297920 Mar 20 10:43 test.log

root@linux:~# umount /data-snap/

3) Удаление файла и откат к предыдущему состоянию:

root@linux:~# rm /data/test.log 

root@linux:~# ll /data

total 24

drwxr-xr-x  3 root root  4096 Mar 20 12:13 ./

drwxr-xr-x 23 root root  4096 Mar 20 12:10 ../

drwx------  2 root root 16384 Mar 20 10:31 lost+found/

root@linux:~# umount /data

root@linux:~# lvconvert --merge /dev/vg_data/lv-snap 

  Merging of volume vg_data/lv-snap started.

  vg_data/lv1: Merged: 99.90%

  vg_data/lv1: Merged: 100.00%

root@linux:~# mount /dev/vg_data/lv1 /data

root@linux:~# ll /data

total 8134108

drwxr-xr-x  3 root root       4096 Mar 20 10:42 ./

drwxr-xr-x 23 root root       4096 Mar 20 12:10 ../

drwx------  2 root root      16384 Mar 20 10:31 lost+found/

-rw-r--r--  1 root root 8329297920 Mar 20 10:43 test.log


# Работа с LVM-RAID

1) Создание зеркала :

root@linux:~# pvcreate /dev/vd{d,e}

  Physical volume "/dev/vdd" successfully created.

  Physical volume "/dev/vde" successfully created.

root@linux:~# vgcreate vg0 /dev/vd{d,e}

  Volume group "vg0" successfully created

root@linux:~# lvcreate -l +80%FREE -m1 -n mirror vg0

  Logical volume "mirror" created.

root@linux:~# lvs
  LV        VG        Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert

  ubuntu-lv ubuntu-vg -wi-ao---- <24.00g     

  mirror    vg0       rwi-a-r--- 816.00m                                    12.52           

  lv1       vg_data   -wi-ao----  10.00g     
                                                 
  lv2       vg_data   -wi-a----- 100.00m  




