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

## Bootstrapping the cluster

Bootstrap ArgoCD to manage itself:

```console
kubectl apply -f bootstrap/argocd.yaml
kubectl apply -f bootstrap/bootstrap.yaml
```

This will apply an `Application` CRD referencing the `bootstrap/argocd` and `infrastructure/`
subdirectories of this repository, and deploy all needed applications in the right
order.

A list of installed applications as well as their **installation
order** can be found below. Each application name is mapped to
a directory at `argocd/infrastructure/`:

| Application | Sync Wave | Remarks |
|-------------|-----------|---------|
|argocd/repos|**-900**|All needed ArgoCD repositories|
|argocd/projects|**-900**|All needed ArgoCD projects|
|[external-secrets](https://external-secrets.io)|**-100**|Fetches secrets from [Doppler](https://doppler.com)|
|external-secrets/secrets|**-90**|All needed secret references|
|external-secrets/secretstores|**-90**|All needed secret stores|
|[cert-manager](https://cert-manager.io)|**-50**|Provides certificates for applications|
|[cert-manager-webhook-civo](https://github.com/okteto/cert-manager-webhook-civo)|**-40**|Uses [Civo](https://civo.com) for solving **DNS-01 challenges**|
|cert-manager/certificates|**-35**|All needed certificates|
|cert-manager/issuers|**-35**|All needed issuers|
|[external-dns](https://kubernetes-sigs.github.io/external-dns/v0.14.0/)|**-30**|Creates **DNS entries** for applications|
|[trœfik](https://traefik.io)|**-20**|**Ingress controller** for applications|
