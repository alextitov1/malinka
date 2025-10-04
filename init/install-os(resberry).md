download image https://www.raspberrypi.com/software/operating-systems/

```sh
curl -OL https://downloads.raspberrypi.com/raspios_arm64/images/raspios_arm64-2025-10-02/2025-10-01-raspios-trixie-arm64.img.xz
```


dd the image to the SD card:
```sh
diskutil list
diskutil unmountDisk /dev/disk4
xzcat AlmaLinux-9-RaspberryPi-latest.aarch64.raw.xz | sudo dd of=/dev/disk4 bs=4M status=progress conv=fsync
```

