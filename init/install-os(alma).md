# AlmaLinux on Raspberry Pi

Download image https://repo.almalinux.org/almalinux/9/raspberrypi/images/
```sh
curl -OL https://repo.almalinux.org/almalinux/9/raspberrypi/images/AlmaLinux-9-RaspberryPi-latest.aarch64.raw.xz
```

dd the image to the SD card:
```sh
# macOS
diskutil list
diskutil unmountDisk /dev/disk4
xzcat AlmaLinux-9-RaspberryPi-latest.aarch64.raw.xz | sudo dd of=/dev/disk4 bs=4M status=progress conv=fsync

# linux
apt install -y xz-utils
xzcat AlmaLinux-9-RaspberryPi-latest.aarch64.raw.xz | dd of=/dev/nvme0n1 bs=4M status=progress conv=fsync
```

## set cloud-init config

mount the boot partition and upd cloud-init config

```sh
# macOS
diskutil list
diskutil info /dev/disk4s1 | grep 'Volume Name'
cd /Volumes/CIDATA

# linux
partprobe /dev/nvme0n1
mount /dev/nvme0n1p1 /mnt

vi /mnt/user-data
```

```sh
vi user-data

cd ~
diskutil unmountDisk /dev/disk4
```

```yaml
hostname: malinka3.lan
ssh_pwauth: true

users:
  - name: 4esnok
    groups: [ adm, systemd-journal ]
    sudo: [ "ALL=(ALL) NOPASSWD:ALL" ]
    lock_passwd: false
    passwd: $6$JtRdjHaNjm.3UWgQ$Nib9qE5ouHDOobeaAUwExeGPxNvOdCrZRK98WRaWMlHMzPMzoeil8Llhg03PKTEoeizUnkJRxaAWKTv8D0FT9/
    ssh_authorized_keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCi15Zu1Ov6YYSC0zqNQ7Xai425+Maehv/kRK76FvazT1/QI6GiDjkY5ojwdzRo4P1Mp1yfuOM7bvNzpkeejUTEEKo4ShJgYNe5RUfadfJ4vAZKI8n0Pzvbm/47KPS8CS6AYyQHU7KLQhRwKOIJberUcI3o4UFnK5wp7I2uJWaiO/TmzDeiiXsojnpn6kJFgPfKIkBSNytlnljVOMDpIt8O/Fqw2zBzpplrnjxEfqY6fcf2vpM29s6ZkKrY9apqzubPRI0EF/J3ZFDWj8dUlkfaG3qmHFjnGU34jyNYPut3419fIQfp0FzJ1Kpkz/VmpUt7XyQumYPEtNK2Z+aGKGtLfyEZCVqdNH08z9aePWZjlkzjzEiKVvIlqqPGdMM/FyHO97TT75eoYq9s+LdkPAd4R/8LYopwxXCqp0EKoFlPx1qBWh2O2ojjIZ1cZBXyFtFdS9gJX+mw1ynv0KeJuUCQrbAS1mXMNqbKDGBMAiZ0AxoZU7r188GhEW8+7i5mVWjCsD+IKisUMhaE3S0KSFEB5Ivd//VLemJhjrc3e/LMo97BPAwaXgjzM1t105yLyHCU0DzA3K8eQ75PIwRBlwy5sAqHkA9DSlj+WMRkJzcN2+a5SakwBaVQPEmMVjpG4myCSjEjVN3NWRvjCwIWlHmGzqbo/h0RdRuKQGshfEK+bQ== mac
```

>(Optional) USB-SATA adapter UAS quirk

For some USB-SATA adapters you may need to add a quirk to switch off UAS

at the start of the line of parameters /boot/cmdline.txt


> usb-storage.quirks=7825:a2a4:u console=tt....


>(Kubernetes) Enable memory cgroup on Raspberry Pi

add `cgroup_enable=memory` to /boot/cmdline.txt to enable memory cgroup

Steps to verify if memory cgroup is enabled

```sh
# check if memory cgroup is enabled
cat /proc/cgroups | grep memory ????

# check current kernel parameters
cat /proc/cmdline
```


>Disable firewall

```sh
systemctl disable firewalld --now
```