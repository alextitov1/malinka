# init setup

## Setup a control node

'''
ansible-galaxy role install -r requirements-rhel.yml
'''

## Setup a managed node
run init.sh to setup and ansible user and ssh key on a new host

```sh
. ./init.sh malinka1
```

## Start a media server

Prepare a host
```
ansible-playbook -e host=malinka2 plays/media-server-config.yml
```

Up podman-compose
```
cd /home/4esnok/gitrepos/malinka/Containers
sudo podman-compose up -d
```



# Repo notes

## SSD-USB

performace test
```sh
hdparm -tT --direct /dev/sda
```

usb3-sata issue:
```
https://forums.raspberrypi.com/viewtopic.php?t=245931

https://github.com/raspberrypi/linux/issues/3070
```

fix
```
# get idVendor=7825, idProduct=a2a4
lsusb
lsusb -t
dmesg -C + unplug/plug + dmesg

# At the start of the line of parameters /boot/cmdline.txt
usb-storage.quirks=7825:a2a4:u console=tt....

```

## Clean up partition table

```sh
wipefs -a /dev/sda
```


## mount options
```sh
UUID=c1eb2700-2c4b-40d2-9617-dbe54ec2e3c5 /media/pi/Seagate3TB ext4 auto,nofail,noatime,users,rw 0 0
```

## Alma wifi connect to Wi-Fi

```sh
nmcli radio wifi
nmcli dev wifi list
nmcli --ask dev wifi connect network-ssid


nmcli connection show
```

# Performance test result

## disk operations
>Sandisk ultra 32G A1 microSD (debian, custom power)
 - Linear read: 44 Mi/s
 - Random read: 2886 IOPS
 - Linear write: 23 Mi/s
 - Random write: 771 IOPS
 - Random write single thread: 236 IOPS

>ChineseSSD USB-SATA Driver=uas (debian, custom power)
 - Linear read: 340 Mi/s
 - Random read: 16993 IOPS
 - Linear write: 278 Mi/s
 - Random write: 25567 IOPS
 - Random write single thread: 804 IOPS

 Same as ^^^^ Driver=usb-storage
 - Linear read: 279Mi/s
 - Random read: 4653 IOPS
 - Linear write: 233Mi/s
 - Random write: 1793 IOPS
 - Random write single thread: 783 IOPS

>KingstonSSD(old)  USB-SATA Driver=usb-storage (alma, Pi power adapter)
 - Linear read: 211Mi/s
 - Random read: 3133 IOPS
 - Linear write: 177Mi/s
 - Random write: 779 IOPS
 - Random write single thread: 1019 IOPS

 Same as ^^^^ Driver=uas
 - Linear read: 348Mi/s
 - Random read: 18587 IOPS
 - Linear write: 212Mi/s
 - Random write: 4597 IOPS
 - Random write single thread: 1138 IOPS