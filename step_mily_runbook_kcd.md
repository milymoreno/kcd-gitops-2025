# Runbook KCD – Kubernetes CI/CD (K3s + Tekton + ArgoCD + SonarQube) ✅

> **Nota:** K3s es la opción principal por ligereza y rapidez. Minikube queda como alternativa opcional.

---

## 1) Crear clúster local con K3s
```bash
# Instalar K3s
curl -sfL https://get.k3s.io | sh -

# Usar kubeconfig de K3s
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# Verifica contexto
kubectl config current-context
kubectl get nodes
```

---

## 2) (Opcional) Crear clúster local con Minikube
```bash
minikube start -p kcd --driver=docker --cpus=2 --memory=4096 --disk-size=20g --wait=all
kubectl get nodes --context kcd
kubectl config use-context kcd
kubectl config current-context   # debe decir: kcd
```

---

## 3) Instalar Tekton (Pipelines + Triggers)
```bash
# Pipelines
kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
kubectl wait --for=condition=Ready pod --all -n tekton-pipelines --timeout=300s

# Triggers
kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml
kubectl wait --for=condition=Ready pod --all -n tekton-pipelines --timeout=300s
```

---

## 4) Instalar ArgoCD
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

## 5) Instalar SonarQube (Community Edition)
```bash
helm repo add sonarqube https://SonarSource.github.io/helm-chart-sonarqube
helm repo update

helm install sonar sonarqube/sonarqube -n dev --create-namespace   --set community.enabled=true   --set monitoringPasscode=$(openssl rand -hex 16)

kubectl wait --for=condition=Ready pod --all -n dev --timeout=600s
```

### Abrir UI de SonarQube
```bash
kubectl -n dev port-forward svc/sonar-sonarqube 9000:9000
# Navega a: http://localhost:9000  (user: admin, pass: admin)
```

### Crear secret con token para Tekton
```bash
kubectl create secret generic sonar-auth -n default   --from-literal=SONAR_TOKEN=<tu_token>
```

---

## 6) Sincronizar la App con ArgoCD
```bash
kubectl -n argocd annotate application kcd-demo-app argocd.argoproj.io/refresh=hard --overwrite
```

---

## 7) App de ejemplo que funciona (http-echo)

### Deployment
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
          resources:
            requests:
              memory: "512Mi"
              cpu: "100m"
            limits:
              memory: "1024Mi"
              cpu: "200m"
```

### Service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: hello-tekton-service
spec:
  selector:
    app: hello-tekton
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
  type: ClusterIP
```

### Ingress
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: hello-tekton-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
    - host: hello.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: hello-tekton-service
                port:
                  number: 80
```

### Ver estado de la app
```bash
kubectl get pods -n default
kubectl logs -n default -l app=hello-tekton --tail=200 --timestamps
```

---

## 8) Probar la app rápido (sin Ingress)
```bash
kubectl -n default port-forward svc/hello-tekton-service 18080:80

# En otra terminal:
curl -i http://127.0.0.1:18080
# Esperado: "Hello from Tekton"
```

---

## 9) (Opcional) Ingress
### En Minikube
```bash
minikube addons enable ingress -p kcd
echo "$(minikube ip -p kcd) hello.local" | sudo tee -a /etc/hosts

IP=$(minikube ip -p kcd)
curl -i -H "Host: hello.local" "http://$IP/"
```

### En K3s
> Usa Traefik. Crea un Ingress con `ingressClassName: traefik` y apunta `/etc/hosts` al IP del nodo.

---

## 10) Utilidades
```bash
# Ver URL del Ingress Controller (Minikube)
minikube -p kcd service ingress-nginx-controller -n ingress-nginx --url

# Recursos en default
kubectl get all -n default

# Recursos en argocd
kubectl get all -n argocd

# Recursos en dev (SonarQube)
kubectl get all -n dev

# ArgoCD Application
kubectl get application -n argocd
kubectl describe application kcd-demo-app -n argocd
```
