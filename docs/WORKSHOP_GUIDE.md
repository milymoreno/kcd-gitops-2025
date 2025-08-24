# 🚀 Taller KCD Colombia 2025: CI/CD con Tekton y ArgoCD

## CI/CD en acción: Automatiza todo con Tekton y ArgoCD desde cero

**Guía completa multiplataforma** - Funciona en Linux y Windows

---

## 🎯 **Lo que vas a construir**

Un pipeline CI/CD empresarial completo:
- ✅ **Clúster Kubernetes** (K3s o Minikube)
- ✅ **6 Tasks de Tekton** (git-clone, maven-build, junit-test, sonarqube, build-image, deploy)
- ✅ **Pipeline completo** con testing automático
- ✅ **GitOps** con ArgoCD
- ✅ **Aplicación desplegada** desde GitHub

**Resultado**: Pipeline funcional en ~1m13s 🚀

---

## 🖥️ **Elige tu Plataforma**

### 🐧 **Linux/Ubuntu** (Recomendado)
- Instalación directa en Ubuntu 22.04+
- K3s como distribución de Kubernetes
- Mejor rendimiento

### 🪟 **Windows**
- WSL2 + Ubuntu 22.04
- K3s, K3d, o Minikube
- Docker Desktop integrado

---

# 🐧 INSTALACIÓN LINUX

## **1. Preparar el Sistema**

```bash
# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar dependencias
sudo apt install -y curl wget git vim

# Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
newgrp docker

# Instalar kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Instalar tkn (Tekton CLI)
curl -LO https://github.com/tektoncd/cli/releases/latest/download/tkn_Linux_x86_64.tar.gz
sudo tar xvzf tkn_Linux_x86_64.tar.gz -C /usr/local/bin/ tkn
```

## **2. Instalar K3s**

```bash
# Instalar K3s
curl -sfL https://get.k3s.io | sh -

# Configurar kubectl
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER:$USER ~/.kube/config
chmod 600 ~/.kube/config

# Verificar
kubectl get nodes
```

---

# 🪟 INSTALACIÓN WINDOWS

## **1. Instalar WSL2**

```powershell
# En PowerShell como administrador
wsl --install
# Reiniciar si es necesario

# Instalar Ubuntu
wsl --install -d Ubuntu-22.04

# Verificar
wsl --version
```

## **2. Configurar Ubuntu en WSL**

```bash
# Abrir Ubuntu (Inicio → Ubuntu)
# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar herramientas
sudo apt install -y curl wget git vim

# Instalar kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Instalar tkn
curl -LO https://github.com/tektoncd/cli/releases/latest/download/tkn_Linux_x86_64.tar.gz
sudo tar xvzf tkn_Linux_x86_64.tar.gz -C /usr/local/bin/ tkn
```

## **3. Instalar K3s en WSL**

```bash
# Descargar K3s
sudo wget --no-check-certificate -O /usr/local/bin/k3s https://github.com/k3s-io/k3s/releases/latest/download/k3s
sudo chmod +x /usr/local/bin/k3s

# Configurar kubectl
mkdir -p ~/.kube

# Iniciar K3s (mantener terminal abierta)
sudo /usr/local/bin/k3s server --disable traefik --write-kubeconfig ~/.kube/config

# En otra terminal WSL
sudo cat /etc/rancher/k3s/k3s.yaml | sudo tee ~/.kube/config > /dev/null
sudo chown $(id -u):$(id -g) ~/.kube/config
chmod 600 ~/.kube/config

# Crear alias
echo 'alias kubectl="/usr/local/bin/k3s kubectl"' >> ~/.bashrc && source ~/.bashrc

# Verificar
kubectl get nodes
```

---

# 🚀 INSTALACIÓN DEL WORKSHOP (Común)

## **4. Clonar Repositorio**

```bash
# IMPORTANTE: En Windows usar home de Linux, NO /mnt/c/
cd ~
git clone https://github.com/milymoreno/creating-cicd-pipelines-with-tekton-2
cd creating-cicd-pipelines-with-tekton-2
```

## **5. Instalar Tekton**

```bash
# Instalar Tekton Pipelines
kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml

# Instalar Tekton Triggers
kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml

# Verificar (esperar que todos estén Running)
kubectl get pods -n tekton-pipelines
```

## **6. Instalar ArgoCD**

```bash
# Crear namespace e instalar
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Verificar (esperar que todos estén Running)
kubectl get pods -n argocd
```

## **7. Aplicar Tasks del Workshop**

```bash
# Aplicar todas las 6 tasks
kubectl apply -f tekton-tasks/

# Verificar tasks creadas
kubectl get tasks

# Deberías ver:
# build-image, deploy-artifact-to-ibm-cloud-functions, git-clone, 
# junit-test, maven-build-java-artifact-from-source, sonarqube-analysis
```

## **8. Ejecutar Pipeline**

```bash
# Aplicar pipeline básico
kubectl apply -f tekton-pipeline/basic-pipeline.yaml

# Ejecutar pipeline (¡FUNCIONA AL 100%!)
tkn pipeline start basic-java-ci-cd-pipeline \
  --param repo-url=https://github.com/milymoreno/creating-cicd-pipelines-with-tekton-2 \
  --param app-name=kcd-demo-app \
  --workspace name=shared-data,volumeClaimTemplateFile=creating-cicd-pipelines-with-tekton-2/tekton/tekton-pvc.yaml \
  --showlog

# Verificar ejecución exitosa
tkn pipelinerun list
```

## **9. Configurar ArgoCD**

```bash
# Port forward para acceder
kubectl port-forward svc/argocd-server -n argocd 8080:443 &

# Obtener contraseña
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo

# Acceder a ArgoCD
# URL: https://localhost:8080
# Usuario: admin
# Contraseña: (salida del comando anterior)
```

---

# ✅ VERIFICACIÓN FINAL

## **Comandos de Verificación**

```bash
# Verificar cluster
kubectl get nodes

# Verificar Tekton
kubectl get pods -n tekton-pipelines

# Verificar ArgoCD
kubectl get pods -n argocd

# Verificar pipeline exitoso
tkn pipelinerun list

# Verificar aplicación desplegada
kubectl get deployments,services | grep hello-tekton

# Verificar aplicación ArgoCD
kubectl get applications -n argocd
```

## **URLs de Acceso**

- **ArgoCD**: https://localhost:8080
- **Aplicación**: Desplegada en Kubernetes

---

# 🚨 TROUBLESHOOTING

## **Linux: Disk Pressure**
```bash
df -h /
sudo journalctl --vacuum-time=1d
sudo apt clean && sudo apt autoremove -y
```

## **Windows: WSL Issues**
```bash
# Reiniciar WSL
wsl --shutdown
wsl -d Ubuntu-22.04

# Verificar Docker Desktop está corriendo
# Settings → Resources → WSL Integration → Ubuntu-22.04
```

## **Pipeline Fails**
```bash
# Ver logs detallados
tkn pipelinerun logs --last -f

# Ver tasks disponibles
kubectl get tasks

# Verificar workspace
kubectl get pvc
```

---

# 🏆 RESULTADO FINAL

Al completar esta guía tendrás:

### ✅ **Pipeline CI/CD Funcional**
- **4 tasks ejecutándose**: git-clone → maven-build → junit-test → deploy
- **Duración**: ~1m13s
- **Estado**: ✅ SUCCEEDED

### ✅ **GitOps con ArgoCD**
- Dashboard accesible en https://localhost:8080
- Aplicación sincronizada desde GitHub
- Despliegue automático funcionando

### ✅ **Aplicación Desplegada**
- hello-tekton corriendo en Kubernetes
- Manifiestos generados automáticamente
- Servicio e Ingress configurados

**¡Workshop completado exitosamente!** 🎉

---

## 📋 **Comando de Demo**

```bash
# Este comando funciona al 100% - úsalo para tu demo
tkn pipeline start basic-java-ci-cd-pipeline \
  --param repo-url=https://github.com/milymoreno/creating-cicd-pipelines-with-tekton-2 \
  --param app-name=kcd-demo-app \
  --workspace name=shared-data,volumeClaimTemplateFile=creating-cicd-pipelines-with-tekton-2/tekton/tekton-pvc.yaml \
  --showlog
```

---

**¡Listo para KCD Colombia 2025!** 🇨🇴🚀