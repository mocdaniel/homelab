# ArgoCD

All applications in the cluster are being managed by
**ArgoCD**, a GitOps solution for Kubernetes.

## Installation

ArgoCD gets installed for the first time using `Helm`
and consequently gets configured to **manage itself**.

```console
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install --namespace argocd \
  --create-namespace \
  argocd \
  argo/argo-cd \
  --version 6.4.1
```

Bootstrap ArgoCD to manage itself:

```console
kubectl apply -f bootstrap.yaml
```

This will apply an `Application` CRD referencing the `apps/`
subdirectory of this repository, and establish an
**App of Apps** pattern.
