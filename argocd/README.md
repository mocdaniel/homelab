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
kubectl apply -f bootstrap/argocd.yaml
```

Then, once the application is **in sync**, bootstrap all of the
remaining infrastructure:

```console
kubectl apply -f bootstrap/bootstrap.yaml
```

This will apply an `Application` CRD referencing the `infrastructure/`
subdirectories of this repository, and deploy all needed applications in the right
order.

A list of installed applications as well as their **installation
order** can be found below. Each application name is mapped to
a directory at `argocd/infrastructure/`:

| Application | Sync Wave | Remarks |
|-------------|-----------|---------|
|[external-secrets](https://external-secrets.io)|**-100**|Fetches secrets from [Doppler](https://doppler.com)|
|external-secrets/secrets|**-90**|All needed secret references|
|external-secrets/secretstores|**-90**|All needed secret stores|
|[cert-manager](https://cert-manager.io)|**-50**|Provides certificates for applications|
|[cert-manager-webhook-civo](https://github.com/okteto/cert-manager-webhook-civo)|**-40**|Uses [Civo](https://civo.com) for solving **DNS-01 challenges**|
|cert-manager/certificates|**-35**|All needed certificates|
|cert-manager/issuers|**-35**|All needed issuers|
|[external-dns](https://kubernetes-sigs.github.io/external-dns/v0.14.0/)|**-30**|Creates **DNS entries** for applications|
|external-secrets/secrets|**-30**|secret needed for external-dns|
|[ingress-nginx](https://kubernetes.github.io/ingress-nginx)|**-20**|**Ingress controller** for applications|
|[rook](https://rook.io)|**-10**|[Ceph](https://ceph.com) controller|
|rook/cephclusters|**-5**|ceph cluster(s)|
