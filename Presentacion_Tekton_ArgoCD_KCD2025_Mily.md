# 🎓 Presentación Taller – KCD Colombia 2025

## CI/CD en acción: Automatiza todo con Tekton y ArgoCD desde cero

**Mildred María Moreno Liscano (Mily)** – MilySoftArchCloud  
📅 28 de agosto de 2025 – Bogotá

---

## 🎯 Objetivo del Taller

En este workshop 100% práctico aprenderás a:

✅ Montar un entorno CI/CD declarativo desde cero  
✅ Usar Tekton para construir pipelines modulares  
✅ Integrar ArgoCD como solución GitOps  
✅ Automatizar desde el Pull Request hasta el despliegue  
✅ Aplicar rollback en caso de fallos con ArgoCD

Todo será sobre un clúster **on-premise con K3s**, ideal para empresas que buscan **autonomía y control completo** sobre su infraestructura.

---

## 📊 GitOps en cifras

### 35 %

**Reducción en tiempos de despliegue** reportada por equipos que adoptan GitOps  
📚 Fuente: [RadixWeb DevOps Statistics](https://radixweb.com/blog/devops-statistics)

---

### 30 %

**Menos incidentes de seguridad** en organizaciones con cultura GitOps madura  
📚 Fuente: [RadixWeb DevOps Statistics](https://radixweb.com/blog/devops-statistics)

---

## 🛣️ Ruta del Taller: CI/CD paso a paso

1️⃣ **Preparación del entorno**  
🖥️ Ubuntu + Docker + Git + Helm + kubectl

2️⃣ **Instalación de K3s (Kubernetes)**  
⚙️ Clúster local on-premise en minutos

3️⃣ **Instalación de Tekton + ArgoCD**  
🔧 Pipelines + GitOps sincronizado

4️⃣ **Creación de Tasks y Pipelines**  
🧱 Paso a paso desde PR hasta despliegue

5️⃣ **Integración GitHub → Tekton**  
🔁 Trigger automático al hacer pull request

6️⃣ **Despliegue GitOps con ArgoCD**  
🚀 Validación + rollback con un clic

7️⃣ **Demostración final**  
✅ Aplicación Java lista desde cero

---

## ⚙️ Instalación de Kubernetes con K3s

```bash
listo sigue cio# Instalar K3s
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

✅ K3s es una distribución ligera de Kubernetes  
🎯 Ideal para entornos de laboratorio y servidores físicos

📌 **Tips importantes:**

- Asegúrate de tener permisos `sudo`
- El servicio se inicia automáticamente
- La configuración se guarda en `~/.kube/config`

🔍 **Conectar con Lens:**

1. Abrir Lens IDE
2. Ir a "Add Cluster"
3. Seleccionar "From kubeconfig"
4. Lens detectará automáticamente `~/.kube/config`
5. ¡Listo! Ya puedes administrar tu cluster visualmente

---

## ⚙️ Instalación de Tekton

```bash
# Instalar Tekton Pipelines
kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml

# Instalar Tekton Triggers
kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml

# Verificar instalación de Tekton
kubectl get pods -n tekton-pipelines

# Esperar a que todos los pods estén Running
kubectl wait --for=condition=Ready pod --all -n tekton-pipelines --timeout=300s
```

✅ **Componentes instalados:**

- 🧩 **Tekton Pipelines** - Motor de CI/CD
- 🔔 **Tekton Triggers** - Webhooks y eventos
- 🎛️ **Controllers** - Gestión de recursos
- 🌐 **Webhooks** - Validación y mutación

📌 **Verificación exitosa:**

- Namespace `tekton-pipelines` creado
- Todos los CRDs (Custom Resource Definitions) instalados
- Controllers y webhooks funcionando

---

## 🚀 Instalación de ArgoCD

```bash
# Crear namespace para ArgoCD
kubectl create namespace argocd

# Instalar ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Verificar instalación
kubectl get pods -n argocd

# Esperar a que ArgoCD esté listo
kubectl wait --for=condition=Ready pod --all -n argocd --timeout=300s
```

✅ **Componentes de ArgoCD instalados:**

- 🎛️ **Application Controller** - Gestiona aplicaciones
- 🌐 **Server** - API y UI web
- 📦 **Repo Server** - Gestiona repositorios Git
- 🔐 **Dex Server** - Autenticación
- 📊 **Redis** - Cache y estado
- 🔔 **Notifications Controller** - Notificaciones

---

## 🔎 Notas clave para esta slide:

📌 Asegúrate de que el clúster K3s esté corriendo antes de ejecutar estos comandos.

🎨 Podés mostrar el ícono de Tekton y el de ArgoCD para distinguir cada bloque visualmente.

🧩 También podés usar bullets a la izquierda con íconos como 🧩 o 📦 si querés hacerlo más gráfico.

---

## 🧱 Crear Tasks y PipelineRun

📌 **Tasks clave incluidas:**

🔄 **git-clone**: clona el código desde GitHub  
⚙️ **maven-build-java-artifact-from-source**: compila el artefacto Java  
🚀 **deploy-artifact-to-ibm-cloud-functions**: despliega a un servicio

---

## 🧪 Declarar Pipeline y PipelineRun

```yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: java-ci-cd-pipeline
spec:
  params:
    - name: repo-url
      type: string
    - name: revision
      type: string
      default: main
  workspaces:
    - name: shared-data
  tasks:
    - name: fetch-source
      taskRef:
        name: git-clone
      workspaces:
        - name: output
          workspace: shared-data
      params:
        - name: url
          value: $(params.repo-url)
        - name: revision
          value: $(params.revision)
    - name: build-artifact
      taskRef:
        name: maven-build-java-artifact-from-source
      workspaces:
        - name: source
          workspace: shared-data
      runAfter:
        - fetch-source
    - name: deploy-app
      taskRef:
        name: deploy-artifact-to-ibm-cloud-functions
      workspaces:
        - name: source
          workspace: shared-data
      runAfter:
        - build-artifact
```

---

## 🔁 Automatización por Pull Request con Tekton

🧠 **¿Qué pasa cuando alguien hace un PR en GitHub?**

👇 Se dispara automáticamente un pipeline gracias a los siguientes componentes:

🔀 **Pull Request en GitHub**  
👂 **EventListener** → escucha el webhook de GitHub  
🔗 **TriggerBinding** → enlaza datos del evento (repo, rama, autor)  
🧩 **TriggerTemplate** → define el pipeline que se ejecutará  
🚀 **PipelineRun**

---

## 🤖 GitOps automático con ArgoCD

🧭 **¿Qué es GitOps?**

Es una forma de automatizar el despliegue usando manifiestos versionados en Git  
ArgoCD detecta los cambios y sincroniza tu clúster automáticamente.

⚙️ **Pasos clave para usar ArgoCD**

📦 **Redireccionar el servicio:**

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

🌐 **Ingresar al dashboard:**  
http://localhost:8080

🧷 **Registrar el repositorio Git**

🗂️ **Crear una aplicación ArgoCD**  
Apunta a los manifiestos del repo

🔁 **Activar la sincronización automática**

🛡️ **¿Qué ganas?**

🚀 **Despliegue inmediato** con cada commit  
👀 **Auditoría de cambios** desde Git  
🔙 **Rollback** con solo un clic

---

## 🧪 Demo: CI/CD en acción

✅ **Crear un Pull Request en GitHub**  
🔁 **Ver Tekton ejecutar el pipeline automáticamente**  
📦 **Validar despliegue de la aplicación en K3s**  
❌ **Simular un error en el manifiesto**  
🔙 **Recuperar versión anterior con ArgoCD (rollback)**

---

## 🎯 ¿Qué lograrás al final del taller?

🚀 **Montar un clúster Kubernetes (K3s) funcional**  
🧩 **Configurar un pipeline CI/CD con Tekton**  
🔁 **Desplegar con GitOps usando ArgoCD**  
🧪 **Ejecutar despliegues desde PRs**  
🔙 **Aplicar rollback automático en caso de error**

**Todo 100% declarativo, reproducible y open source**

---

## 🙋‍♀️ ¿Dudas? ¡Aquí estoy!

📬 **milydemendoza@gmail.com**  
📱 **+57 304 4123136**  
🔗 **https://github.com/milymoreno**  
💼 **www.linkedin.com/in/arquitectura-mily-moreno-cloud**  
🏢 **MilySoftArchCloud**

📸 **¡Toma una foto del QR y accede al repo del taller!**

🖤 **¡Nos vemos en el próximo KCD!**

---

## 💡 Reflexión final

> _"There's a lot of automation that can happen that isn't a replacement of humans, but of mind‑numbing behavior."_  
> **Stewart Butterfield (Slack)**

> _"Hay mucha automatización que puede suceder que no es un reemplazo de los humanos, sino de comportamientos que entumecen la mente."_

**¡Gracias por acompañarme 💜!**
