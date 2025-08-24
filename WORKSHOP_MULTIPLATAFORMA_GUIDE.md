# 🚀 Taller KCD Colombia 2025: CI/CD con Tekton y ArgoCD - Guía Multiplataforma

## CI/CD en acción: Automatiza todo con Tekton y ArgoCD desde cero

**Guía completa para Linux y Windows** - Elige tu plataforma y sigue los pasos correspondientes.

---

## 🎯 **Objetivo del Taller**

Construir un pipeline CI/CD empresarial completo que incluye:
- ✅ **Clúster Kubernetes** (K3s o Minikube)
- ✅ **Pipeline CI/CD** con Tekton (6 tasks)
- ✅ **Testing automático** con JUnit
- ✅ **Análisis de calidad** con SonarQube (opcional)
- ✅ **GitOps** con ArgoCD
- ✅ **Despliegue automático** desde GitHub

---

## 🖥️ **Elige tu Plataforma**

### 🐧 **Linux/Ubuntu** (Recomendado para servidores)
- Instalación directa en Ubuntu 22.04+
- K3s como distribución de Kubernetes
- Rendimiento óptimo y menor consumo de recursos

### 🪟 **Windows** (Para desarrolladores)
- WSL2 + Ubuntu 22.04
- Opciones: K3s, K3d, o Minikube
- Docker Desktop integrado

---

# 🐧 GUÍA PARA LINUX/UBUNTU

## **1. Preparación del Entorno Linux**

### **Requisitos previos**
- Ubuntu 22.04 LTS o superior
- Acceso `sudo`
- Conexión a internet estable
- Mínimo 4GB RAM, 20GB espacio libre

### **Instalar dependencias**
```bash
# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar herramientas básicas
sudo apt install -y curl wget git vim htop

# Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
newgrp docker

# Instalar kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Instalar Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Instalar tkn (Tekton CLI)
curl -LO https://github.com/tektoncd/cli/releases/latest/download/tkn_Linux_x86_64.tar.gz
sudo tar xvzf tkn_Linux_x86_64.tar.gz -C /usr/local/bin/ tkn
```

## **2. Instalación de Kubernetes con K3s (Linux)**

```bash
# Instalar K3s
curl -sfL https://get.k3s.io | sh -

# Crear directorio para kubectl config
mkdir -p ~/.kube

# Copiar configuración de K3s
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config

# Ajustar permisos
sudo chown $USER:$USER ~/.kube/config
chmod 600 ~/.kube/config

# Verificar instalación
kubectl get nodes

# Verificar que todos los pods del sistema estén funcionando
kubectl get pods -A
```

## **3. Clonar Repositorio (Linux)**

```bash
cd ~
git clone https://github.com/milymoreno/creating-cicd-pipelines-with-tekton-2
cd creating-cicd-pipelines-with-tekton-2
```

---

# 🪟 GUÍA PARA WINDOWS

## **1. Preparación del Entorno Windows**

### **Requisitos previos**
- Windows 10/11 actualizado
- PowerShell con permisos de administrador
- Mínimo 8GB RAM, 30GB espacio libre

### **Instalar WSL2**
```powershell
# En PowerShell como administrador
wsl --install

# Reiniciar PC si es necesario
# Verificar instalación
wsl --version
```

### **Instalar Ubuntu 22.04**
```powershell
# Opción 1: Microsoft Store (recomendado)
# Buscar "Ubuntu 22.04 LTS" e instalar

# Opción 2: PowerShell
wsl --install -d Ubuntu-22.04

# Verificar instalación
wsl --list --verbose
```

### **Abrir Ubuntu WSL**
- **Método 1**: Inicio → escribir "Ubuntu" → Enter
- **Método 2**: PowerShell → `wsl -d Ubuntu-22.04`
- **Método 3**: Windows Terminal → seleccionar Ubuntu

## **2. Configurar Ubuntu en WSL2**

```bash
# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar herramientas básicas
sudo apt install -y curl wget git vim htop ca-certificates

# Instalar kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Instalar tkn (Tekton CLI)
curl -LO https://github.com/tektoncd/cli/releases/latest/download/tkn_Linux_x86_64.tar.gz
sudo tar xvzf tkn_Linux_x86_64.tar.gz -C /usr/local/bin/ tkn
```

## **3. Opciones de Kubernetes para Windows**

### **Opción A: K3s en WSL2 (Recomendado)**

```bash
# Descargar K3s manualmente
sudo wget --no-check-certificate -O /usr/local/bin/k3s https://github.com/k3s-io/k3s/releases/latest/download/k3s
sudo chmod +x /usr/local/bin/k3s

# Crear directorio para kubectl
mkdir -p ~/.kube

# Iniciar K3s (mantener terminal abierta)
sudo /usr/local/bin/k3s server --disable traefik --write-kubeconfig ~/.kube/config

# En otra terminal WSL, configurar kubectl
sudo cat /etc/rancher/k3s/k3s.yaml | sudo tee ~/.kube/config > /dev/null
sudo chown $(id -u):$(id -g) ~/.kube/config
chmod 600 ~/.kube/config

# Crear alias para kubectl
echo 'alias kubectl="/usr/local/bin/k3s kubectl"' >> ~/.bashrc && source ~/.bashrc

# Verificar
kubectl get nodes
```

### **Opción B: K3d con Docker Desktop**

```bash
# Instalar k3d
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Crear clúster
k3d cluster create demo-cluster --servers 1 --agents 2 --port 8080:80@loadbalancer

# Verificar
kubectl get nodes
```

### **Opción C: Minikube**

```bash
# Instalar Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Iniciar clúster
minikube start --memory=4096 --cpus=2 --disk-size=20g

# Verificar
kubectl get nodes
```

## **4. Clonar Repositorio (Windows WSL)**

```bash
# IMPORTANTE: Siempre usar el home de Linux, NO /mnt/c/
cd ~
pwd  # Debe mostrar /home/tu_usuario

# Clonar repositorio
git clone https://github.com/milymoreno/creating-cicd-pipelines-with-tekton-2
cd creating-cicd-pipelines-with-tekton-2
```

---

# 🚀 INSTALACIÓN COMÚN (Linux y Windows)

## **4. Instalar Tekton**

```bash
# Instalar Tekton Pipelines
kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml

# Instalar Tekton Triggers
kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml

# Verificar instalación
kubectl get pods -n tekton-pipelines

# Esperar a que todos los pods estén Running
kubectl wait --for=condition=Ready pod --all -n tekton-pipelines --timeout=300s
```

## **5. Instalar ArgoCD**

```bash
# Crear namespace
kubectl create namespace argocd

# Instalar ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Verificar instalación
kubectl get pods -n argocd

# Esperar a que ArgoCD esté listo
kubectl wait --for=condition=Ready pod --all -n argocd --timeout=600s
```

## **6. Instalar SonarQube (Opcional)**

### **Opción A: Con Helm**
```bash
# Agregar repositorio
helm repo add sonarqube https://SonarSource.github.io/helm-chart-sonarqube
helm repo update

# Crear namespace
kubectl create namespace sonarqube

# Instalar SonarQube
helm install sonarqube sonarqube/sonarqube \
  --namespace sonarqube \
  --set persistence.enabled=false \
  --set postgresql.enabled=false
```

### **Opción B: Con kubectl**
```bash
kubectl create namespace sonarqube

kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sonarqube
  namespace: sonarqube
spec:
  replicas: 1
  selector:
    matchLabels:
      app: sonarqube
  template:
    metadata:
      labels:
        app: sonarqube
    spec:
      containers:
      - name: sonarqube
        image: sonarqube:9.9-community
        ports:
        - containerPort: 9000
        env:
        - name: SONAR_ES_BOOTSTRAP_CHECKS_DISABLE
          value: "true"
---
apiVersion: v1
kind: Service
metadata:
  name: sonarqube
  namespace: sonarqube
spec:
  selector:
    app: sonarqube
  ports:
  - port: 9000
    targetPort: 9000
  type: ClusterIP
EOF
```

## **7. Aplicar Tasks de Tekton**

```bash
# Aplicar todas las tasks
kubectl apply -f tekton-tasks/

# Verificar tasks creadas
kubectl get tasks

# Deberías ver:
# NAME                                     AGE
# build-image                              10s
# deploy-artifact-to-ibm-cloud-functions   10s
# git-clone                                10s
# junit-test                               10s
# maven-build-java-artifact-from-source    10s
# sonarqube-analysis                       10s
```

## **8. Crear y Ejecutar Pipeline**

```bash
# Aplicar pipeline básico (sin SonarQube)
kubectl apply -f tekton-pipeline/basic-pipeline.yaml

# Ejecutar pipeline
tkn pipeline start basic-java-ci-cd-pipeline \
  --param repo-url=https://github.com/milymoreno/creating-cicd-pipelines-with-tekton-2 \
  --param app-name=kcd-demo-app \
  --workspace name=shared-data,volumeClaimTemplateFile=creating-cicd-pipelines-with-tekton-2/tekton/tekton-pvc.yaml \
  --showlog

# Verificar ejecución
tkn pipelinerun list
```

## **9. Configurar ArgoCD**

```bash
# Port forward para acceder a ArgoCD
kubectl port-forward svc/argocd-server -n argocd 8080:443 &

# Obtener contraseña admin
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo

# Acceder a ArgoCD
# URL: https://localhost:8080
# Usuario: admin
# Contraseña: (salida del comando anterior)
```

---

# 🎯 VERIFICACIÓN FINAL

## **Comandos de Verificación**

```bash
# Verificar cluster
kubectl get nodes

# Verificar Tekton
kubectl get pods -n tekton-pipelines

# Verificar ArgoCD
kubectl get pods -n argocd

# Verificar SonarQube (si instalado)
kubectl get pods -n sonarqube

# Verificar tasks
kubectl get tasks

# Verificar pipelines
tkn pipeline list

# Verificar aplicación desplegada
kubectl get deployments,services,ingress | grep hello-tekton

# Verificar aplicación ArgoCD
kubectl get applications -n argocd
```

## **URLs de Acceso**

- **ArgoCD**: https://localhost:8080 (admin / contraseña-obtenida)
- **SonarQube**: http://localhost:9000 (admin / admin)
- **Aplicación**: http://localhost (si configuraste ingress)

---

# 🚨 TROUBLESHOOTING

## **Problemas Comunes Linux**

### **Disk Pressure**
```bash
# Verificar espacio
df -h /

# Limpiar logs del sistema
sudo journalctl --vacuum-time=1d

# Limpiar cache de apt
sudo apt clean && sudo apt autoremove -y

# Remover taint si es necesario
kubectl taint nodes <node-name> node.kubernetes.io/disk-pressure:NoSchedule-
```

### **Permisos kubectl**
```bash
sudo chown $USER:$USER ~/.kube/config
chmod 600 ~/.kube/config
```

## **Problemas Comunes Windows**

### **WSL2 no funciona**
```powershell
# Verificar WSL
wsl --version

# Actualizar WSL
wsl --update

# Reiniciar WSL
wsl --shutdown
wsl -d Ubuntu-22.04
```

### **Permisos en WSL**
```bash
# NUNCA usar /mnt/c/ para Kubernetes
# Siempre usar home de Linux
cd ~
pwd  # Debe mostrar /home/usuario
```

### **Docker Desktop no conecta**
- Verificar que Docker Desktop esté corriendo
- En Docker Desktop → Settings → Resources → WSL Integration
- Habilitar integración con Ubuntu-22.04

### **K3s no inicia en WSL**
```bash
# Usar certificados inseguros si hay proxy
sudo wget --no-check-certificate -O /usr/local/bin/k3s https://github.com/k3s-io/k3s/releases/latest/download/k3s

# Verificar que no hay conflictos de puerto
sudo netstat -tulpn | grep :6443
```

---

# 🏆 RESULTADO FINAL

Al completar esta guía tendrás:

### ✅ **Infraestructura Completa**
- Kubernetes funcionando (K3s/K3d/Minikube)
- Tekton Pipelines operativo
- ArgoCD configurado y accesible
- SonarQube instalado (opcional)

### ✅ **Pipeline CI/CD Funcional**
- 6 tasks empresariales creadas
- Pipeline básico ejecutándose exitosamente
- Testing automático con JUnit
- Despliegue a Kubernetes operativo

### ✅ **GitOps Completo**
- ArgoCD sincronizando desde GitHub
- Aplicación desplegada automáticamente
- Dashboard visual para monitoreo

### ✅ **Flujo Completo**
**GitHub → Tekton → Kubernetes → ArgoCD** 🚀

---

## 📋 **Comandos de Demo**

```bash
# Pipeline que funciona al 100%
tkn pipeline start basic-java-ci-cd-pipeline \
  --param repo-url=https://github.com/milymoreno/creating-cicd-pipelines-with-tekton-2 \
  --param app-name=kcd-demo-app \
  --workspace name=shared-data,volumeClaimTemplateFile=creating-cicd-pipelines-with-tekton-2/tekton/tekton-pvc.yaml \
  --showlog

# Acceso a ArgoCD
kubectl port-forward svc/argocd-server -n argocd 8080:443 &
echo "ArgoCD: https://localhost:8080"

# Verificar estado
tkn pipelinerun list
kubectl get applications -n argocd
```

---

**¡Workshop listo para KCD Colombia 2025!** 🇨🇴🚀

> **Autor:** MilySoftArchCloud  
> **Evento:** KCD Colombia 2025  
> **Tema:** CI/CD en acción con Tekton y ArgoCD