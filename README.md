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

