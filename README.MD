# Taller Práctico KCD Colombia 2025: CI/CD con Tekton y ArgoCD

## 🎯 Título

**CI/CD en acción: Automatiza todo con Tekton y ArgoCD desde cero**

---

## 🧩 Resumen

En este taller intensivo y 100% práctico, los participantes aprenderán a construir un pipeline CI/CD completamente declarativo desde cero, utilizando **Tekton** y **ArgoCD** sobre un clúster **K3s on-premise**. Este enfoque está diseñado para entornos reales en empresas que requieren **autonomía, seguridad y control completo** sobre su infraestructura CI/CD. 

El taller utilizará GitHub como repositorio fuente y demostrará una integración real de GitOps desde PR hasta despliegue.

---

## 🛠️ Paso a paso para dummies

### 1. Preparación del entorno

- Servidor físico con **Ubuntu 22.04 o superior**
- Acceso root (`sudo`) y conexión estable a internet
- Instalar: `Docker`, `kubectl`, `helm`, `git`
- Clonar el repositorio:  
  `https://github.com/milymoreno/creating-cicd-pipelines-with-tekton-2`

---

### 2. Instalación de Kubernetes con K3s

```bash
curl -sfL https://get.k3s.io | sh -
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
```

---

### 3. Instalación de Tekton, ArgoCD y SonarQube

**Tekton:**
```bash
kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml
```

**ArgoCD:**
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

**SonarQube (para análisis de calidad):**
```bash
kubectl create namespace sonarqube
helm repo add sonarqube https://SonarSource.github.io/helm-chart-sonarqube
helm install sonarqube sonarqube/sonarqube --namespace sonarqube
```

---

### 4. Crear Tasks

Se incluyen **6 Tasks empresariales**:
- `git-clone` - Clona repositorio Git
- `maven-build-java-artifact-from-source` - Compila con Maven
- `junit-test` - Ejecuta pruebas unitarias JUnit
- `sonarqube-analysis` - Análisis de calidad de código
- `build-image` - Construye imágenes Docker con Kaniko
- `deploy-artifact-to-ibm-cloud-functions` - Despliega a Kubernetes

**🆕 Pipeline CI/CD Completo**: Desde código fuente hasta despliegue con calidad garantizada

---

### 5. Crear Pipeline y PipelineRun

Declaración de recursos para la ejecución del pipeline y despliegue con Tekton

---

### 6. Añadir TriggerTemplate y TriggerBinding

Configuración de triggers por Pull Request con GitHub o Azure Repos

---

### 7. Configurar GitOps con ArgoCD

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

- Ingresar a http://localhost:8080
- Registrar repositorio Git
- Crear aplicación apuntando a manifiestos versionados
- Activar sincronización automática

---

### 8. Pruebas y demostración

- Realizar PR y observar ejecución del pipeline
- Validar despliegue en Kubernetes
- Introducir error y hacer rollback con ArgoCD

---

## 📂 Repositorio base

https://github.com/milymoreno/creating-cicd-pipelines-with-tekton-2

---

## 🎯 Resultados esperados

- **Clúster K3s funcional** con todas las herramientas
- **Pipeline CI/CD empresarial** con Tekton (6 tasks completas)
- **Análisis de calidad** automático con SonarQube
- **Construcción de imágenes** sin Docker daemon (Kaniko)
- **GitOps completo** con rollback usando ArgoCD
- **Aplicación Java desplegada** desde PR con calidad garantizada

**🏆 Pipeline de nivel empresarial listo para producción**
