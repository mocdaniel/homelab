# Rook

[Rook](https://rook.io) is a Kubernetes operator for [Ceph](https://ceph.io)
clusters.

## Installation

The **Rook operator** can be installed via **Helm**:

```console
helm repo add rook-release https://charts.rook.io/release
helm repo update
helm install --create-namespace --namespace rook-ceph \
  rook-ceph \
  rook-release/rook-ceph
```

Once the operator and the project's CRDs are installed,
a cluster can be initiated, again via **Helm**:

```console
helm install --namespace rook-ceph \
  rook-ceph-cluster \
  rook-release/rook-ceph-cluster \
  -f values.yaml
```

Because the cluster is deployed by [Talos](../talos/),
[Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/)
are in place. Thus, the target namespace needs to be
labeled accordingly:

```console
kubectl label namespace rook-ceph pod-security.kubernetes.io/enforce=privileged
```

## Cleaning up

Cleaning up a Ceph cluster isn't an easy task, if the occupied disks should remain
usable afterwards. The following steps have to be followed for a clean removal
of a Ceph cluster operated by Rook:

### Confirming Pending Deletion

First, the planned deletion needs to be signaled to the Rook operator by patching
the `CephCluster` CRD:

```console
kubectl --namespace rook-ceph patch cephcluster rook-ceph \
  --type merge \
  -p '{"spec":{"cleanupPolicy":{"confirmation":"yes-really-destroy-data"}}}'
```

### Removal of the Ceph Cluster

Once the Rook operator knows about the planned deletion, the `CephCluster` and its
**dependants** can be **deleted** and its **Helm release** can be uninstalled:

```console
kubectl delete storageclasses ceph-block ceph-bucket ceph-filesystem
kubectl --namespace rook-ceph delete cephblockpools ceph-blockpool
kubectl --namespace rook-ceph delete cephobjectstore ceph-objectstore
kubectl --namespace rook-ceph delete cephfilesystemsubvolumegroup ceph-filesystem-csi
kubectl --namespace rook-ceph delete cephfilesystem ceph-filesystem
kubectl --namespace rook-ceph delete cephcluster rook-ceph
helm --namespace rook-ceph uninstall rook-ceph-cluster
```
