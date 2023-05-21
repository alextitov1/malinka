# init setup

## nmcli

```sh
nmcli radio wifi
nmcli dev wifi list
nmcli --ask dev wifi connect network-ssid


nmcli connection show
```

run init.sh to setup and ansible user and ssh key on a new host

```sh
. ./init.sh malinka1
```

# setup

perform a general setup of the host
* rename the host to a ansible node name
* install packages
* setup ntp

# notes

Clean up partition table

```sh
wipefs -a /dev/sda
```