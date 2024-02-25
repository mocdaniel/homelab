# ArgoCD

All applications in the cluster are being managed by
**ArgoCD**, a GitOps solution for Kubernetes.

## Installation

ArgoCD gets installed for the first time using `kubectl`
and consequently gets configured to **manage itself**.

```console
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Bootstrap ArgoCD to manage itself:

```console
kubectl apply -f bootstrap.yaml
```

This will apply an `Application` CRD referencing the `apps/`
subdirectory of this repository, and establish an
**App of Apps** pattern.
