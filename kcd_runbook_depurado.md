# Runbook KCD – Kubernetes CI/CD (Minikube + Tekton + ArgoCD) ✅

> **Nota:** Pasos depurados que sí funcionan en tu entorno. Repetibles para demo.

---

## 0) Opción alternativa: K3s (solo si lo necesitas)
```bash
# Instalar K3s
curl -sfL https://get.k3s.io | sh -

# Usar kubeconfig de K3s
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# (Opcional) Si ya tienes ArgoCD en ese clúster:
kubectl port-forward svc/argocd-server -n argocd 8080:443
# UI: https://localhost:8080  (user: admin, pass: <argocd-initial-admin-secret>)
```
---

## 1) Crear clúster local con Minikube (perfil **kcd**)
```bash
minikube start -p kcd --driver=docker --cpus=2 --memory=4096 --disk-size=20g --wait=all
kubectl get nodes --context kcd
kubectl config use-context kcd
kubectl config current-context   # debe decir: kcd
```

---

## 2) Instalar Tekton (Pipelines + Triggers)
```bash
# Pipelines
kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
kubectl wait --for=condition=Ready pod --all -n tekton-pipelines --timeout=300s

# Triggers
kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml
kubectl wait --for=condition=Ready pod --all -n tekton-pipelines --timeout=300s
```

---

## 3) Instalar ArgoCD
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl get pods -n argocd -w   # esperar todo Running
```

### Obtener contraseña inicial de ArgoCD
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

### Abrir la UI de ArgoCD
```bash
kubectl port-forward -n argocd svc/argocd-server 8080:443
# Navega a: https://localhost:8080  (user: admin, pass: <salida anterior>)
```

---

## 4) Sincronizar la App con ArgoCD (si ya está creada en el repo)
```bash
# Forzar reconciliación completa si hace falta
kubectl -n argocd annotate application kcd-demo-app argocd.argoproj.io/refresh=hard --overwrite
```

---

## 5) App de ejemplo que funciona (http-echo)
> El Service apunta a TargetPort **8080**, así que el contenedor debe escuchar en 8080.

**Deployment (final OK):**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-tekton
  labels:
    app: hello-tekton
spec:
  replicas: 3
  selector:
    matchLabels:
      app: hello-tekton
  template:
    metadata:
      labels:
        app: hello-tekton
    spec:
      containers:
        - name: hello-tekton
          image: hashicorp/http-echo:0.2.3
          command: ["/http-echo"]
          args: ["-listen=:8080", "-text=Hello from Tekton"]
          ports:
            - containerPort: 8080
```

### Ver estado de la app
```bash
kubectl get pods -n default
kubectl logs -n default -l app=hello-tekton --tail=200 --timestamps
```

---

## 6) Probar la app rápido (sin Ingress)
```bash
kubectl -n default port-forward svc/hello-tekton-service 18080:80

# En otra terminal:
curl -i http://127.0.0.1:18080
# Esperado: "Hello from Tekton"
```

---

## 7) (Opcional) Ingress en Minikube
```bash
# Habilitar Ingress Controller (NGINX)
minikube addons enable ingress -p kcd

# Asegurar clase nginx en el Ingress
kubectl -n default patch ingress hello-tekton-ingress   --type='json' -p='[{"op":"add","path":"/spec/ingressClassName","value":"nginx"}]'

# /etc/hosts → apuntar dominio local al IP del clúster
echo "$(minikube ip -p kcd) hello.local" | sudo tee -a /etc/hosts

# (Si necesitas túnel para 80/443)
sudo -E env MINIKUBE_HOME="$HOME/.minikube" minikube -p kcd tunnel

# Probar
IP=$(minikube ip -p kcd)
curl -i -H "Host: hello.local" http://$IP/
```

---

## 8) Utilidades
```bash
# Ver URL del Ingress Controller
minikube -p kcd service ingress-nginx-controller -n ingress-nginx --url

# Recursos en default
kubectl get all -n default

# ArgoCD Application
kubectl get application -n argocd
kubectl describe application kcd-demo-app -n argocd
```
