# Rook-Ceph (File-backed OSDs)

This directory contains the configuration for installing [Rook-Ceph](https://rook.io/)
on a cluster where nodes **do not have dedicated disks**. Instead, each node
uses a fixed-size 180 GiB file (`/var/lib/rook-osd/osd.img`) exposed as a
loop device to serve as an OSD.

## Prerequisites

### 1. Create OSD backing files and loop devices

Run the following Ansible playbook to create the OSD backing files and loop devices on each node:

```bash
# From the workspace root
ansible-playbook k8s/cluster/csi/ceph-rook/node_prep/setup-osd-file.yaml
```

Verify the loop device is active:
```bash
losetup -a
# Expected output: /dev/loopX: ... (/var/lib/rook-osd/osd.img)
```

## Installation

**1. Add the Rook Helm Repository**
```bash
helm repo add rook-release https://charts.rook.io/release
helm repo update
```

**2. Create the namespace**
```bash
kubectl create namespace rook-ceph
```

**3. Install the Rook Operator**
```bash
helm upgrade --install rook-ceph rook-release/rook-ceph \
  --namespace rook-ceph \
  -f k8s/cluster/csi/ceph-rook/operator-values.yaml
```

**4. Deploy the Ceph Cluster**

Wait for the operator pod to be ready, then apply the cluster manifest:
```bash
kubectl wait --for=condition=Ready pod -l app=rook-ceph-operator \
  -n rook-ceph --timeout=300s

kubectl apply -f k8s/cluster/csi/ceph-rook/cluster.yaml
```

**5. Deploy CSI Drivers**
```bash
helm repo add ceph-csi-operator https://ceph.github.io/ceph-csi-operator-charts
helm upgrade --install ceph-csi-drivers ceph-csi-operator/ceph-csi-drivers \
  --namespace rook-ceph \
  -f k8s/cluster/csi/ceph-rook/driver-values.yaml
```

**5. Create the StorageClass and CephBlockPool**
```bash
kubectl apply -f k8s/cluster/csi/ceph-rook/storage-class.yaml
```

**6. (Optional) Deploy the Toolbox for debugging**
```bash
kubectl apply -f k8s/cluster/csi/ceph-rook/toolbox.yaml
```

The toolbox relies on the operator-generated `rook-ceph-mon` secret and
`rook-ceph-mon-endpoints` ConfigMap. If those objects do not exist yet, wait for
the Ceph cluster to finish bootstrapping before using `ceph` commands from the
toolbox.

## Verification

First verify the cluster has created its admin access objects and reached a
healthy state:
```bash
kubectl -n rook-ceph get cephcluster rook-ceph
kubectl -n rook-ceph get secret rook-ceph-mon
kubectl -n rook-ceph get configmap rook-ceph-mon-endpoints
kubectl -n rook-ceph get pods
```

Once the monitors and manager are running, check the Ceph cluster health from
the toolbox:
```bash
kubectl -n rook-ceph exec -it deploy/rook-ceph-tools -- ceph status
kubectl -n rook-ceph exec -it deploy/rook-ceph-tools -- ceph osd tree
```

Verify each node shows a ~180 GiB OSD.

If `ceph status` still fails, inspect the toolbox pod and operator logs:
```bash
kubectl -n rook-ceph exec -it deploy/rook-ceph-tools -- sh -c 'env | grep ROOK && ls -R /etc/ceph /etc/rook /var/lib/rook-ceph-mon'
kubectl -n rook-ceph logs deploy/rook-ceph-operator
```

## Uninstallation

```bash
# Remove StorageClass & CephBlockPool
kubectl delete -f k8s/cluster/csi/ceph-rook/storage-class.yaml

# Remove the Ceph Cluster
kubectl delete -f k8s/cluster/csi/ceph-rook/cluster.yaml

# Remove the Operator
helm uninstall rook-ceph -n rook-ceph

# Clean up host data (run on each node)
sudo systemctl disable --now rook-osd-loopdev.service
sudo losetup -d /dev/loop*  # detach all loop devices for osd.img
sudo rm -rf /var/lib/rook /var/lib/rook-osd
sudo rm /etc/systemd/system/rook-osd-loopdev.service
sudo systemctl daemon-reload
```
