# Cilium

Cilium is used as CNI for the [Talos](../talos/) cluster. It can be
installed in **kubeproxy-mode** with the `cilium` CLI:

```console
cilium install --values values.yaml
```

## Hubble

**Hubble** can be enabled using the `cilium` CLI, too:

```console
cilium hubble enable --ui
```

The UI can be opened via

```console
cilium hubble ui
```
