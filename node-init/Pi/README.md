## Hard Drive

```sh
# clean up partition table
wipefs -a /dev/sda
```
### USB-SATA

```sh
# check current driver
lsusb -t

# Look for Driver=uas or Driver=usb-storage in the output. uas is better, but has issues see below.
# 5000M is USB 3.0, 480M is USB 2.0

>/:  Bus 002.Port 001: Dev 001, Class=root_hub, Driver=xhci_hcd/4p, 5000M
>    |__ Port 001: Dev 002, If 0, Class=Mass Storage, Driver=uas, 5000M
```

#### usb3-sata issue:


[forums.raspberrypi.com](https://forums.raspberrypi.com/viewtopic.php?t=245931)

[Github issue](https://github.com/raspberrypi/linux/issues/3070)

Workaround:

```
# get idVendor=7825, idProduct=a2a4
lsusb
lsusb -t
dmesg -C + unplug/plug + dmesg

# At the start of the line of parameters /boot/cmdline.txt
usb-storage.quirks=7825:a2a4:u console=tt....
```


## Power

### Pi 5 usb-boot
```
# usb-boot requires 5v/5a; here is a workaround
echo "usb_max_current_enable=1" >> /boot/firmware/config.txt
```

### Pi 5 Power requirement
```
The Pi 5 expects 5v / 5a to enable usb boot. In USB Power Delivery, anything that goes above 3A requires a special 'e-marked' cable. Even though 5x5 is 25W, the PSU needs to support these more than 3A stuff. With most 27W PSU you'll find on the market, they will only provide up to 9V / 3A so they won't be good for the Pi.

Check - PDO (Power Delivery Object) and you'll be able to see if 5v / 5a is supported or not that way.
```



## Performance tests

```sh
hdparm -tT --direct /dev/sda
```

```sh
# fio tests script 
../scripts/fio_drive_test.sh
```


### Fio Results
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

>NVMe 24HY08000831  HYV256X3 (HXY) 256.06 FW APF1M3R1 (debian Pi5)
 - Linear read: 431Mi/s
 - Random read: 107677 IOPS
 - Linear write: 422Mi/s
 - Random write: 49227 IOPS
 - Random write single thread: 978 IOPS