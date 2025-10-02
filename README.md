# init setup

## Setup a control node

### Devcontainer
Use devcontainer to setup a control node with ansible and other dependencies.

### Manual setup
Install ansible and other dependencies on a control node (e.g. your laptop)

```sh
#(optional) if id_rsa.pub isn't generated
ssh-keygen 

ansible-galaxy role install -r requirements-rhel.yaml
ansible-galaxy collection install -r requirements-rhel.yaml
```

Install ansible-core > 2.14 on RHEL9 like systems
```sh
dnf install python3.12 python3.12-pip sshpass

python3.12 -m pip install ansible-core passlib

echo "export PATH=$HOME/.local/bin:$PATH" >> ~/.zshrc
source ~/.zshrc
```

## Setup a managed node
run init.sh to setup add ansible user and ssh key on a managed host

```sh
# will prompt for password to decrypt vars/secret.yaml pass ~ x2
# ./init.sh -h <host> -u <user>
./init/run-initsetup.sh -h malinka3 -u almalinux
```

## Setup USB-SSD storage on a managed node

if necessary, wipe existing partition table `wipefs -a /dev/sda`

```sh
ansible-playbook -e host=malinka3 ./init/ssdsetup-playbook.yaml
```

## Start a media server

Prepare a host
```
ansible-playbook -e host=malinka2 plays/media-server-config.yml
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
# Power

## Pi 5 usb-boot
```
to 
/boot/firmware/config.txt

add
usb_max_current_enable=1 
```

### Pi 5 Power requirement
```
It's actually USB Power Delivery specification that's confusing.

The Pi 5 expects 5v / 5a to enable usb boot. In USB Power Delivery, anything that goes above 3A requires a special 'e-marked' cable. Even though 5x5 is 25W, the PSU needs to support these more than 3A stuff. With most 27W PSU you'll find on the market, they will only provide up to 9V / 3A so they won't be good for the Pi.

So basically check the output capabilities of the PSU before buying one. They are called PDO (Power Delivery Object) and you'll be able to see if 5v / 5a is supported or not that way.
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