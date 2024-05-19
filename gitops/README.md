# GitOps

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
  --version 6.9.3
```

## Secrets

Secrets are fetched from [Doppler](https://doppler.com) with [external-secrets](https://external-secrets.io).
Before bootstrapping the cluster, a single secret holding the
**service token** to the corresponding Doppler **project** needs
to be created.

Assuming the `doppler` CLI is configured properly, the secret can
be created like this:

```console
doppler run --command='kubectl create secret -n kube-system \
  generic doppler-auth-token \
  --from-literal token=$SERVICE_TOKEN'
```

## Bootstrapping the cluster

Bootstrap ArgoCD to manage itself:

```console
kubectl apply -f bootstrap/apps/argocd.yaml
```

Then, once the application is **in sync**, bootstrap all of the
remaining infrastructure:

```console
kubectl apply -f bootstrap/apps/bootstrap.yaml
```

This will apply an `Application` CRD referencing the `infrastructure/apps`
directory of this repository, and deploy all needed applications in the right
order.

A list of installed applications as well as their **installation
order** can be found below.

| Application | Sync Wave | Remarks |
|-------------|-----------|---------|
|[external-secrets](https://external-secrets.io)|**1**|Fetches secrets from [Doppler](https://doppler.com)|
|[ingress-nginx](https://kubernetes.github.io/ingress-nginx)|**1**|**Ingress controller** for applications|
|[rook](https://rook.io)|**1**|[Ceph](https://ceph.com) controller|
|[cnpg](https://cloudnative-pg.io)|**1**|A PostgreSQL operator|
|[tetragon](https://tetragon.io)|**1**|eBPF-based runtime observability|
|external-secrets resources|**2**|Reference to the secret store(s)|
|[cert-manager](https://cert-manager.io)|**2**|Provides certificates for applications|
|[external-dns](https://kubernetes-sigs.github.io/external-dns/v0.14.0/)|**2**|Creates **DNS entries** for applications|
|[velero](https://velero.io)|**2**|Automated backup solution|
|velero resources|**3**|Backup schedules etc.|
|[cert-manager-webhook-civo](https://github.com/okteto/cert-manager-webhook-civo)|**3**|Uses [Civo](https://civo.com) for solving **DNS-01 challenges**|
|cert-manager resources|**3**|Certificates, Issuers, and secrets needed for the cluster|
|Ceph Clusters|**4**|Ceph cluster(s) managed by Rook|

Those applications themselves may contain multiple resources again
(e.g. an `Application` installing the Helmchart and some `CRDs`),
for details regarding their sync order see their annotations.
