# Talos Linux

Talos is a super-lightweight Linux-based operating system,
designed to only run Kubernetes on top of it.
It is managed via API using `talosctl` and comes with a minimum of installed binaries.

## Configuration

Talos nodes are configured using so-called **machine configs**.
Those contain sensible data, so they can't be versioned.

Instead, this repository contains the needed **patches**
to be applied to the vanilla machine configurations.

### Configuration Generation

In order to generate the full machine configs, generate
the configs **with** applied patches, using the saved
`secrets.yaml` so we get the same PKI data:

```console
talosctl gen config --with-secrets secrets.yaml \
  <cluster-name> <cluster-api-endpoint> \
  --kubernetes-version <version>\
  --config-patch @general.yaml
```

**Move** the generated `talosconfig` to the default location:

```console
mv talosconfig ~/.config/talos/config
```

## Installation

Applying the config for the first time can be done like this:

```console
talosctl apply-config --insecure \
  --nodes <control-plane-node> \
  --file controlplane.yaml \
  -p @node-1.yaml
```

For `worker` nodes, respectively:

```console
talosctl apply-config --insecure \
  --nodes <worker-node-x> \
  --file worker.yaml \
  -p @node-x.yaml
```

### Update Configuration

If the configuration needs to be updated, go about it like this:

```console
# Stage configuration changes
talosctl apply-config -m stage \
  -e <cluster-api-endpoint> \
  -n <node> \
  -f <config-file>

# Cordon and drain node
kubectl cordon <node>
kubectl drain <node> --ignore-daemonsets --delete-emptydir-data

# Reboot node
talosctl reboot -e <cluster-api-endpoint> \
  -n <node>

# Uncordon node
kubectl uncordon <node>

# Wait until Ceph data has been restored
kubectl wait --timeout=1800s \
  --namespace rook-ceph \
  --for=jsonpath='{.status.ceph.health}=HEALTH_OK' \
  rook-ceph
```

### Resetting Nodes

Nodes can get resetted with the following command:

```console
talosctl reset -n <node> -e <control-plane-endpoint> \
  --system-labels-to-wipe STATE \
  --system-labels-to-wipe EPHEMERAL \
  --graceful=true \
  --reboot \
  --wait
```

## Kubernetes

### Cluster Bootstrapping

Bootstrap the Kubernetes cluster with the following command:

**This needs to be done only once!**

```console
talosctl bootstrap \
  --nodes <control-plane-node> \
  --endpoints <control-plane-node>
```

Export the kubeconfig:

```console
talosctl kubeconfig \
  --nodes <control-plane-node> \
  --endpoints <control-plane-node>
```

**It may take a few minutes** until the cluster is fully bootstrapped.
