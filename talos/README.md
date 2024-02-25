# Talos Linux

Talos is a super-lightweight Linux-based operating system,
designed to only run Kubernetes on top of it.
It is managed via API using `talosctl` and comes with a minimum of installed binaries.

## Configuration

Talos nodes are configured using so-called **machine configs**.
Those contain sensible data, so they can't be versioned.

Instead, this repository contains the needed **patches**
to be applied to the vanilla machine configurations.

### Generation

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

### Installation

Applying the config for the first time can be done like this:

```console
talosctl apply-config --insecure \
  --nodes <control-plane-node> \
  --file controlplane.yaml
```

For `worker` nodes, respectively:

```console
talosctl apply-config --insecure \
  --nodes <worker-node-1>,<worker-node-2>... \
  --file worker.yaml
```

## Kubernetes

### Cluster Bootstrapping

Bootstrap the Kubernetes cluster with the following command:

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

## Cilium

Cilium is used as CNI. It can be installed in **kubeproxy-mode**
with the `cilium` CLI:

```console
cilium install \
  --helm-set=k8sServiceHost=localhost \
  --helm-set=k8sServicePort=7445 \
  --helm-set=ipam.mode=kubernetes \
  --helm-set=kubeProxyReplacement=true \
  --helm-set=securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" \
  --helm-set=securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" \
  --helm-set=cgroup.autoMount.enabled=false \
  --helm-set=cgroup.hostRoot=/sys/fs/cgroup
```

**Hubble** can be enabled using the `cilium` CLI, too:

```console
cilium hubble enable
```
