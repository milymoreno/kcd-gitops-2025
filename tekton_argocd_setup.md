# Guía de instalación y configuración Tekton + ArgoCD

## Instalar K3s

``` bash
curl -sfL https://get.k3s.io | sh -
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
```

Verificar pods:

``` bash
kubectl get pods -n default 
kubectl describe pod hello-tekton-5bd65df746-nzz76 -n default
```

## Crear el Cluster con Minikube

``` bash
minikube start -p kcd --driver=docker --cpus=2 --memory=4096 --disk-size=20g --wait=all 
```

Verificar Nodo del Cluster:

``` bash
kubectl get nodes --context kcd
```

Fijar el contexto:

``` bash
kubectl config use-context kcd
kubectl config current-context
```

## Instalar Tekton en el Cluster

``` bash
kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
kubectl get pods -n tekton-pipelines
kubectl wait --for=condition=Ready pod --all -n tekton-pipelines --timeout=300s
```

Instalar Tekton Triggers:

``` bash
kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml
kubectl get pods -n tekton-pipelines
watch kubectl get pods -n tekton-pipelines
```

## Instalar ArgoCD

``` bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl get pods -n argocd -w
```

Obtener la contraseña de ArgoCD:

``` bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
watch kubectl get pods -n argocd
```

Redireccionar ArgoCD (dashboard en https://localhost:8080):

``` bash
kubectl port-forward -n argocd svc/argocd-server 8080:443
```

## Kubeconfig

Guardar kubeconfig del cluster:

``` bash
kubectl config view --minify --raw --flatten > ~/Descargas/kubeconfig_minikube-test
```
