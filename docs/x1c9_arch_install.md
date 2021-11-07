Disabled Secure Boot
Left Kernel DMA Protection On (Looks like this might cause issues with docks but we dont use one so leave on)
Linux S3 Sleep state
Disabled OS defaults (looks windows specific)

Boot arch


Run iwctl:
```
device list
station wlan0 scan
station wlan0 get-networks
station wlan0 connect <network>
```

time
```
timedatectl set-ntp true
```

Partition. Used fdisk reorder partitions
```
root@archiso ~ # fdisk -l /dev/nvme0n1
Disk /dev/nvme0n1: 476.94 GiB, 512110190592 bytes, 1000215216 sectors
Disk model: KXG6AZNV512G TOSHIBA                    
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: 6ACDE0EE-01E1-4DE5-8EA5-BCB0A2F01D98

Device             Start        End   Sectors   Size Type
/dev/nvme0n1p1      2048     534527    532480   260M EFI System
/dev/nvme0n1p2    534528     567295     32768    16M Microsoft reserved
/dev/nvme0n1p3    567296   34121727  33554432    16G Linux swap
/dev/nvme0n1p4  34121728  998166527 964044800 459.7G Linux filesystem
/dev/nvme0n1p5 998166528 1000214527   2048000  1000M Windows recovery environment

```

After chrooting insatall iwd and connect like steps above

```
pacman -S iwd
mkdir /etc/iwd
vim /etc/iwd/main.conf
------
[General]
EnableNetworkConfiguration=true
----

```

Then install grub and ntfs-3g/os-prober so grub can find the recovery partition
Then install intel-ucode  and generate grub boot file

Then restart
