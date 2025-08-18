# 🪟 Taller Práctico KCD Colombia 2025 - Guía para Windows
## CI/CD con Tekton y ArgoCD desde cero - Versión Windows

---

## 🎯 **Requisitos Previos para Windows**

### **Opción 1: WSL2 (Recomendado)**
```powershell
# Habilitar WSL2
wsl --install

# Instalar Ubuntu
wsl --install -d Ubuntu-22.04

# Acceder a WSL2
wsl
```

### **Opción 2: Docker Desktop + PowerShell**
- Descargar Docker Desktop para Windows
- Habilitar Kubernetes en Docker Desktop
- Usar PowerShell como administrador

---

## 🛠️ **Instalación de Herramientas en Windows**

### **En WSL2 (Ubuntu):**
```bash
# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Instalar kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Instalar helm
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm

# Instalar tkn CLI
curl -LO https://github.com/tektoncd/cli/releases/latest/download/tkn_Linux_x86_64.tar.gz
sudo tar xvzf tkn_Linux_x86_64.tar.gz -C /usr/local/bin/ tkn

# Instalar git
sudo apt install git -y
```

### **En PowerShell (Nativo Windows):**
```powershell
# Instalar Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Instalar herramientas
choco install kubernetes-cli -y
choco install kubernetes-helm -y
choco install git -y
choco install docker-desktop -y

# Instalar tkn CLI
Invoke-WebRequest -Uri https://github.com/tektoncd/cli/releases/latest/download/tkn_Windows_x86_64.zip -OutFile tkn.zip
Expand-Archive tkn.zip -DestinationPath C:\tools\tkn
$env:PATH += ";C:\tools\tkn"
```

---

## ☸️ **Opciones de Kubernetes para Windows**

### **Opción 1: Minikube**
```bash
# En WSL2
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Iniciar con recursos suficientes
minikube start --memory=4096 --cpus=2 --disk-size=20g --driver=docker

# Verificar
kubectl get nodes
```

```powershell
# En PowerShell
choco install minikube -y

# Iniciar
minikube start --memory=4096 --cpus=2 --disk-size=20g

# Verificar
kubectl get nodes
```

### **Opción 2: Docker Desktop Kubernetes**
```powershell
# Habilitar Kubernetes en Docker Desktop
# Settings > Kubernetes > Enable Kubernetes

# Verificar
kubectl config current-context  # Debería mostrar "docker-desktop"
kubectl get nodes
```

### **Opción 3: K3s en WSL2**
```bash
# Solo en WSL2
curl -sfL https://get.k3s.io | sh -
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER:$USER ~/.kube/config
```

---

## 🔧 **Configuración Específica para Windows**

### **Variables de Entorno**
```powershell
# PowerShell
$env:KUBECONFIG = "$HOME\.kube\config"

# Permanente
[Environment]::SetEnvironmentVariable("KUBECONFIG", "$HOME\.kube\config", "User")
```

```bash
# WSL2
echo 'export KUBECONFIG=~/.kube/config' >> ~/.bashrc
source ~/.bashrc
```

### **Acceso a Servicios**
```powershell
# Port forwarding funciona igual
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Acceder desde Windows
# https://localhost:8080
```

---

## 📁 **Estructura de Archivos Windows**

### **Rutas en WSL2:**
```bash
# Archivos del taller
/home/usuario/taller-kcd/
├── tekton-tasks/
├── tekton-pipeline/
├── argocd-apps/
└── creating-cicd-pipelines-with-tekton-2/
```

### **Rutas en Windows:**
```powershell
# Archivos del taller
C:\Users\Usuario\taller-kcd\
├── tekton-tasks\
├── tekton-pipeline\
├── argocd-apps\
└── creating-cicd-pipelines-with-tekton-2\
```

---

## 🚀 **Comandos Adaptados para Windows**

### **Crear directorios:**
```powershell
# PowerShell
New-Item -ItemType Directory -Path "tekton-tasks", "tekton-pipeline", "argocd-apps"
```

```bash
# WSL2 (igual que Linux)
mkdir -p tekton-tasks tekton-pipeline argocd-apps
```

### **Aplicar manifiestos:**
```powershell
# PowerShell (igual)
kubectl apply -f tekton-tasks\
kubectl apply -f tekton-pipeline\pipeline-run-test.yaml
```

```bash
# WSL2 (igual que Linux)
kubectl apply -f tekton-tasks/
kubectl apply -f tekton-pipeline/pipeline-run-test.yaml
```

---

## 🎯 **Pasos del Taller en Windows**

### **1. Preparación del entorno**
```powershell
# Verificar instalaciones
kubectl version --client
helm version
tkn version
git --version

# Clonar repositorio
git clone https://github.com/milymoreno/creating-cicd-pipelines-with-tekton-2
cd creating-cicd-pipelines-with-tekton-2
```

### **2. Iniciar Kubernetes**
```powershell
# Opción A: Minikube
minikube start --memory=4096 --cpus=2 --disk-size=20g

# Opción B: Docker Desktop (ya habilitado)
kubectl config use-context docker-desktop

# Verificar
kubectl get nodes
kubectl get pods -A
```

### **3. Instalar Tekton**
```powershell
kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml

# Verificar
kubectl get pods -n tekton-pipelines
```

### **4. Instalar ArgoCD**
```powershell
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Verificar
kubectl get pods -n argocd
```

### **5. Acceder a ArgoCD**
```powershell
# Obtener contraseña
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }

# Port forward
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Acceder desde navegador Windows
# https://localhost:8080
# Usuario: admin
# Contraseña: (del comando anterior)
```

---

## 🔍 **Herramientas de Monitoreo para Windows**

### **Lens IDE**
```powershell
# Descargar desde: https://k8slens.dev/
# Instalar normalmente en Windows
# Detectará automáticamente ~/.kube/config
```

### **K9s (Terminal UI)**
```powershell
choco install k9s -y
k9s
```

### **Kubectl con PowerShell**
```powershell
# Ver recursos
kubectl get all -A

# Logs en tiempo real
kubectl logs -f deployment/hello-tekton

# Port forwarding
kubectl port-forward svc/hello-tekton-service 8080:80
```

---

## 🚨 **Problemas Comunes en Windows**

### **1. Permisos de PowerShell**
```powershell
# Habilitar ejecución de scripts
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### **2. Docker no funciona en WSL2**
```bash
# Reiniciar Docker service
sudo service docker start

# Agregar usuario al grupo docker
sudo usermod -aG docker $USER
newgrp docker
```

### **3. kubectl no encuentra config**
```powershell
# Verificar ubicación
echo $env:KUBECONFIG
ls $HOME\.kube\

# Copiar config si es necesario
copy $HOME\.kube\config $HOME\.kube\config.backup
```

### **4. Puertos ocupados**
```powershell
# Ver qué usa el puerto 8080
netstat -ano | findstr :8080

# Matar proceso si es necesario
taskkill /PID <PID> /F
```

---

## 🎓 **Comandos Específicos del Taller para Windows**

### **Ejecutar pipeline con tkn:**
```powershell
tkn pipeline start java-ci-cd-pipeline `
  --param repo-url=https://github.com/milymoreno/creating-cicd-pipelines-with-tekton-2 `
  --param revision=main `
  --param app-name=kcd-demo-app `
  --param environment=development `
  --workspace name=shared-data,volumeClaimTemplateFile=creating-cicd-pipelines-with-tekton-2\tekton\tekton-pvc.yaml `
  --showlog
```

### **Ver logs:**
```powershell
# Con tkn
tkn pipelinerun logs --last -f

# Con kubectl
kubectl get pipelineruns
kubectl logs -f $(kubectl get pods -l tekton.dev/pipelineRun=java-ci-cd-pipeline-run-003 -o name).Split('/')[1]
```

---

## 🏆 **Resultado Final en Windows**

Al completar el taller tendrás:

✅ **Kubernetes funcionando** (Minikube/Docker Desktop/K3s)  
✅ **Tekton CI/CD** ejecutando pipelines  
✅ **ArgoCD GitOps** desplegando aplicaciones  
✅ **Lens IDE** para monitoreo visual  
✅ **Aplicación Java** corriendo en el cluster  

**¡Todo funcionando nativamente en Windows!** 🪟🚀

---

## 💡 **Recomendaciones para Windows**

1. **Usa WSL2** para mejor compatibilidad con herramientas Linux
2. **Docker Desktop** es la opción más fácil para Kubernetes
3. **PowerShell 7** tiene mejor soporte que PowerShell 5.1
4. **Lens IDE** funciona perfectamente en Windows
5. **Git Bash** puede ser útil para comandos Unix-style

¡Listo para el taller en cualquier sistema operativo! 🎉