

kubectl delete -f k8s/cluster/csi/ceph-rook/storage-class.yaml

sleep 10

kubectl delete -f k8s/cluster/csi/ceph-rook/cluster.yaml

sleep 10

helm uninstall rook-ceph -n rook-ceph

# force delete the rook-ceph namespace and all resources in it
# kubectl delete namespace rook-ceph --force --grace-period=0
kubectl get crd -o name | grep '\.ceph\.rook\.io$' | xargs -r kubectl delete --force --grace-period=0
kubectl get crd -o name | grep '\.ceph\.io$' | xargs -r kubectl delete --force --grace-period=0

# if namespace deletion gets stuck in Terminating, clear common Rook/Ceph finalizers and retry
kubectl patch -n rook-ceph cephfilesystem.ceph.rook.io/cephfs --type=merge -p '{"metadata":{"finalizers":[]},"spec":{"preserveFilesystemOnDelete":false}}' \
     && kubectl patch cephcluster.ceph.rook.io/rook-ceph -n rook-ceph --type=merge -p '{"metadata":{"finalizers":[]}}' \
     && kubectl patch clientprofile.csi.ceph.io/rook-ceph -n rook-ceph --type=merge -p '{"metadata":{"finalizers":[]}}' \
     && kubectl patch configmap/rook-ceph-mon-endpoints -n rook-ceph --type=merge -p '{"metadata":{"finalizers":[]}}' \
     && kubectl patch secret/rook-ceph-mon -n rook-ceph --type=merge -p '{"metadata":{"finalizers":[]}}' \
     && kubectl patch namespace rook-ceph --type=merge -p '{"spec":{"finalizers":[]}}'

kubectl delete namespace rook-ceph

ansible-playbook k8s/cluster/csi/ceph-rook/node_prep/teardown-osd-file.yaml
