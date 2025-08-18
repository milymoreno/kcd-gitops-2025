# ⚙️ Comparación: K3s vs Minikube para el Taller KCD Colombia 2025

## 🎯 **Resumen Ejecutivo**

| Aspecto | K3s | Minikube |
|---------|-----|----------|
| **Instalación** | Más simple (1 comando) | Requiere driver |
| **Recursos** | Más ligero | Más pesado |
| **Producción** | ✅ Listo para producción | ❌ Solo desarrollo |
| **Windows** | Solo WSL2 | ✅ Nativo |
| **Persistencia** | ✅ Automática | ⚠️ Requiere configuración |

---

## 🚀 **Instalación y Setup**

### **K3s (Actual)**
```bash
# Instalación (1 comando)
curl -sfL https://get.k3s.io | sh -

# Configuración
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER:$USER ~/.kube/config

# Verificación
kubectl get nodes
```

### **Minikube (Alternativo)**
```bash
# Instalación
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Inicio con recursos suficientes
minikube start --memory=4096 --cpus=2 --disk-size=20g --driver=docker

# Verificación
kubectl get nodes
minikube status
```

---

## 📊 **Comparación Detallada**

### **1. Recursos del Sistema**

#### **K3s:**
- **RAM**: ~500MB base
- **CPU**: Mínimo 1 core
- **Disco**: ~200MB instalación
- **Procesos**: Integrado con systemd

#### **Minikube:**
- **RAM**: ~1GB base + VM overhead
- **CPU**: Mínimo 2 cores recomendado
- **Disco**: ~1GB + imágenes
- **Procesos**: VM separada

### **2. Tiempo de Inicio**

#### **K3s:**
```bash
time curl -sfL https://get.k3s.io | sh -
# ~30-60 segundos (primera vez)
# ~5 segundos (reinicio)
```

#### **Minikube:**
```bash
time minikube start --memory=4096 --cpus=2
# ~2-5 minutos (primera vez)
# ~30-60 segundos (reinicio)
```

### **3. Persistencia de Datos**

#### **K3s:**
- ✅ **Automática**: Los datos persisten entre reinicios
- ✅ **Local Path Provisioner**: Storage dinámico incluido
- ✅ **Producción ready**: Configuración real

#### **Minikube:**
- ⚠️ **Manual**: Requiere configuración específica
- ⚠️ **Addons**: Necesita habilitar storage
- ❌ **Desarrollo only**: No para producción

---

## 🧪 **Prueba Práctica: Minikube**

Vamos a probar el taller completo con Minikube:

### **Paso 1: Instalar Minikube**
```bash
# Si no tienes minikube instalado
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Verificar instalación
minikube version
```

### **Paso 2: Iniciar Cluster**
```bash
# Iniciar con recursos suficientes para el taller
minikube start --memory=4096 --cpus=2 --disk-size=20g --driver=docker

# Verificar estado
minikube status
kubectl get nodes
kubectl get pods -A
```

### **Paso 3: Habilitar Addons Necesarios**
```bash
# Habilitar ingress (equivalente a Traefik en K3s)
minikube addons enable ingress

# Habilitar storage (equivalente a local-path en K3s)
minikube addons enable default-storageclass
minikube addons enable storage-provisioner

# Ver addons habilitados
minikube addons list
```

### **Paso 4: Instalar Tekton**
```bash
# Mismo proceso que con K3s
kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml

# Verificar
kubectl get pods -n tekton-pipelines
```

### **Paso 5: Instalar ArgoCD**
```bash
# Mismo proceso que con K3s
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Verificar
kubectl get pods -n argocd
```

---

## 🔍 **Diferencias en el Taller**

### **Comandos que cambian:**

#### **Acceso a servicios:**
```bash
# K3s (directo)
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Minikube (igual, pero también puedes usar)
minikube service argocd-server -n argocd --url
```

#### **Ver aplicación desplegada:**
```bash
# K3s (con Traefik)
kubectl get ingress
curl -H "Host: hello.local" http://localhost

# Minikube (con nginx-ingress)
minikube addons enable ingress
kubectl get ingress
minikube tunnel  # En otra terminal
curl -H "Host: hello.local" http://$(minikube ip)
```

#### **Acceso al dashboard:**
```bash
# K3s (solo ArgoCD)
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Minikube (ArgoCD + Dashboard nativo)
kubectl port-forward svc/argocd-server -n argocd 8080:443
minikube dashboard  # Dashboard adicional de Kubernetes
```

---

## 🎯 **Ventajas y Desventajas**

### **K3s - Ventajas:**
✅ **Más rápido** de instalar y iniciar  
✅ **Menos recursos** del sistema  
✅ **Más realista** para producción  
✅ **Persistencia automática**  
✅ **Traefik incluido**  

### **K3s - Desventajas:**
❌ **Solo Linux** (WSL2 en Windows)  
❌ **Menos herramientas** de debug  
❌ **Configuración manual** para desarrollo  

### **Minikube - Ventajas:**
✅ **Multiplataforma** (Windows, Mac, Linux)  
✅ **Muchos addons** disponibles  
✅ **Dashboard integrado**  
✅ **Mejor para aprendizaje**  
✅ **Fácil reset** (`minikube delete`)  

### **Minikube - Desventajas:**
❌ **Más pesado** en recursos  
❌ **Más lento** para iniciar  
❌ **Solo desarrollo** (no producción)  
❌ **Configuración adicional** requerida  

---

## 🏆 **Recomendaciones por Escenario**

### **Para el Taller KCD Colombia 2025:**

#### **Usar K3s cuando:**
- ✅ Participantes con **Linux/Ubuntu**
- ✅ Enfoque en **producción real**
- ✅ **Recursos limitados** del sistema
- ✅ Quieren **experiencia realista**

#### **Usar Minikube cuando:**
- ✅ Participantes con **Windows/Mac**
- ✅ Enfoque en **aprendizaje**
- ✅ **Recursos abundantes** del sistema
- ✅ Quieren **herramientas de debug**

### **Configuración Híbrida (Recomendada):**
```markdown
## Opción 1: K3s (Recomendado para servidores Linux)
- Instalación rápida y ligera
- Experiencia de producción real

## Opción 2: Minikube (Recomendado para desarrollo local)
- Mejor compatibilidad multiplataforma
- Más herramientas de debugging
```

---

## 🚀 **Script de Instalación Automática**

### **Para K3s:**
```bash
#!/bin/bash
echo "🚀 Instalando K3s para Taller KCD Colombia 2025..."
curl -sfL https://get.k3s.io | sh -
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER:$USER ~/.kube/config
echo "✅ K3s instalado correctamente"
kubectl get nodes
```

### **Para Minikube:**
```bash
#!/bin/bash
echo "🚀 Instalando Minikube para Taller KCD Colombia 2025..."
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
minikube start --memory=4096 --cpus=2 --disk-size=20g --driver=docker
minikube addons enable ingress
minikube addons enable default-storageclass
echo "✅ Minikube instalado correctamente"
kubectl get nodes
```

---

## 📝 **Conclusión**

**Ambas opciones funcionan perfectamente** para el taller. La elección depende del público objetivo:

- **K3s**: Mejor para **experiencia realista** y **recursos limitados**
- **Minikube**: Mejor para **compatibilidad** y **herramientas de desarrollo**

**Recomendación**: Ofrecer **ambas opciones** en el taller y que cada participante elija según su entorno.