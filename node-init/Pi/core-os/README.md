https://github.com/cgruver/kamarotos/blob/main/bin/clusterButaneConfig.sh

# CoreOS Installation with Ignition

## Butane - Generate Ignition Config

```sh
# run butane from the container
docker run -i --rm quay.io/coreos/butane:release \
       --pretty --strict < vm-01.bu > vm-01.ign
```

[butane spec](https://coreos.github.io/butane/specs/)


# Install
1. generate ignition file

2. spin up a http server to serve the file

```sh
cd /path/to/ignition-dir
python3 -m http.server 8000
```

3. trigger the installation

```sh
coreos-installer install /dev/vda \
  --ignition-url http://192.168.88.16:8000/vm-01.ign \
  --insecure-ignition
```