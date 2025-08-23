# 🚀 Guía de Tasks Avanzadas - KCD Colombia 2025

## CI/CD Empresarial con Tekton: Testing, Calidad y Contenedores

---

## 📋 **Resumen de Tasks Avanzadas**

El workshop ahora incluye **6 tasks completas** que forman un pipeline CI/CD de nivel empresarial:

### ✅ **Tasks Básicas**
1. **`git-clone-task.yaml`** - Clona repositorio Git
2. **`maven-build-task.yaml`** - Compila aplicación Java con Maven
3. **`deploy-artifact-task.yaml`** - Despliega y crea manifiestos para ArgoCD

### 🆕 **Tasks Avanzadas**
4. **`junit-test-task.yaml`** - Ejecuta pruebas unitarias JUnit
5. **`sonarqube-task.yaml`** - Análisis de calidad de código
6. **`build-image-task.yaml`** - Construye imágenes Docker con Kaniko

---

## 🧪 **Task 4: JUnit Testing**

### Descripción
Ejecuta pruebas unitarias con Maven y genera reportes JUnit.

### Características
- **Imagen base**: `maven:3.9-eclipse-temurin-17`
- **Comando**: `mvn -B test`
- **Reportes**: Genera reportes en `target/surefire-reports`
- **Resultados**: Expone resultado de pruebas y ruta de reportes

### Uso en Pipeline
```yaml
- name: run-tests
  taskRef:
    name: junit-test
  workspaces:
    - name: source
      workspace: shared-data
  runAfter:
    - build-artifact
```

### Parámetros
- `maven-image`: Imagen de Maven (default: `maven:3.9-eclipse-temurin-17`)
- `maven-args`: Argumentos de Maven (default: `["-B", "test"]`)

---

## 🔍 **Task 5: SonarQube Analysis**

### Descripción
Ejecuta análisis de calidad de código con SonarQube Scanner.

### ⚠️ **Prerequisito: Instalar SonarQube**

#### Opción 1: Con Helm (Recomendado)
```bash
# Agregar repositorio de SonarQube
helm repo add sonarqube https://SonarSource.github.io/helm-chart-sonarqube
helm repo update

# Crear namespace
kubectl create namespace sonarqube

# Instalar SonarQube
helm install sonarqube sonarqube/sonarqube \
  --namespace sonarqube \
  --set persistence.enabled=true \
  --set persistence.size=10Gi

# Esperar a que esté listo
kubectl wait --for=condition=Ready pod --all -n sonarqube --timeout=600s

# Acceder a la UI
kubectl port-forward -n sonarqube svc/sonarqube-sonarqube 9000:9000
# http://localhost:9000 (admin/admin)
```

#### Opción 2: Con kubectl
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

### Configuración de SonarQube
1. **Acceder a SonarQube**: http://localhost:9000
2. **Login inicial**: admin/admin (cambiar en primer acceso)
3. **Crear proyecto** y obtener token de autenticación
4. **Configurar Quality Gate** según tus estándares

### Uso en Pipeline
```yaml
- name: code-analysis
  taskRef:
    name: sonarqube-analysis
  workspaces:
    - name: source
      workspace: shared-data
  params:
    - name: project-key
      value: "kcd-demo-app"
    - name: project-name
      value: "KCD Demo Application"
    - name: project-version
      value: "1.0.0"
    - name: sonar-host-url
      value: "http://sonarqube.sonarqube:9000"
    - name: sonar-token
      value: "your-sonarqube-token"
  runAfter:
    - run-tests
```

### Parámetros Requeridos
- `project-key`: Clave única del proyecto
- `project-name`: Nombre del proyecto
- `project-version`: Versión de la aplicación
- `sonar-host-url`: URL de SonarQube
- `sonar-token`: Token de autenticación

---

## 🐳 **Task 6: Build Image con Kaniko**

### Descripción
Construye y publica imágenes Docker usando Kaniko (sin daemon Docker).

### Ventajas de Kaniko
- ✅ **No requiere Docker daemon** - Funciona en Kubernetes
- ✅ **Más seguro** - No necesita privilegios especiales
- ✅ **Reproducible** - Builds consistentes
- ✅ **Multi-registry** - Soporta múltiples registros

### Uso en Pipeline
```yaml
- name: build-image
  taskRef:
    name: build-image
  workspaces:
    - name: source
      workspace: shared-data
  params:
    - name: image-url
      value: "ghcr.io/milymoreno/kcd-demo-app:latest"
    - name: context
      value: "."
    - name: dockerfile
      value: "./Dockerfile"
    - name: insecure-registry
      value: "false"
    - name: skip-tls-verify
      value: "false"
  runAfter:
    - code-analysis
```

### Parámetros
- `image-url`: URL destino de la imagen (ej: `ghcr.io/org/app:tag`)
- `context`: Ruta del contexto de build (default: `.`)
- `dockerfile`: Ruta al Dockerfile (default: `./Dockerfile`)
- `build-args`: Argumentos de build opcionales
- `insecure-registry`: true/false para registros inseguros
- `skip-tls-verify`: true/false para saltar validación TLS

### Configuración de Registry
Para usar registros privados, necesitas configurar autenticación:

```bash
# Crear secret para Docker registry
kubectl create secret docker-registry regcred \
  --docker-server=ghcr.io \
  --docker-username=your-username \
  --docker-password=your-token \
  --docker-email=your-email@example.com

# Usar en el pipeline con workspace dockerconfig
```

---

## 🔄 **Pipeline Completo con Todas las Tasks**

### Ejemplo de Pipeline Empresarial
```yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: enterprise-java-ci-cd-pipeline
spec:
  params:
    - name: repo-url
      type: string
    - name: revision
      type: string
      default: main
    - name: app-name
      type: string
      default: kcd-demo-app
    - name: image-url
      type: string
    - name: sonar-token
      type: string
  workspaces:
    - name: shared-data
    - name: dockerconfig
  tasks:
    # 1. Clone source code
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
    
    # 2. Build with Maven
    - name: build-artifact
      taskRef:
        name: maven-build-java-artifact-from-source
      workspaces:
        - name: source
          workspace: shared-data
      runAfter:
        - fetch-source
    
    # 3. Run unit tests
    - name: run-tests
      taskRef:
        name: junit-test
      workspaces:
        - name: source
          workspace: shared-data
      runAfter:
        - build-artifact
    
    # 4. Code quality analysis
    - name: code-analysis
      taskRef:
        name: sonarqube-analysis
      workspaces:
        - name: source
          workspace: shared-data
      params:
        - name: project-key
          value: $(params.app-name)
        - name: project-name
          value: "KCD Demo Application"
        - name: project-version
          value: "1.0.0"
        - name: sonar-host-url
          value: "http://sonarqube.sonarqube:9000"
        - name: sonar-token
          value: $(params.sonar-token)
      runAfter:
        - run-tests
    
    # 5. Build container image
    - name: build-image
      taskRef:
        name: build-image
      workspaces:
        - name: source
          workspace: shared-data
        - name: dockerconfig
          workspace: dockerconfig
      params:
        - name: image-url
          value: $(params.image-url)
        - name: context
          value: "."
        - name: dockerfile
          value: "./Dockerfile"
      runAfter:
        - code-analysis
    
    # 6. Deploy to Kubernetes
    - name: deploy-app
      taskRef:
        name: deploy-artifact-to-ibm-cloud-functions
      workspaces:
        - name: source
          workspace: shared-data
      params:
        - name: APP_NAME
          value: $(params.app-name)
        - name: ENVIRONMENT
          value: "development"
      runAfter:
        - build-image
```

---

## 🚀 **Ejecutar el Pipeline Completo**

### Con tkn (Recomendado)
```bash
tkn pipeline start enterprise-java-ci-cd-pipeline \
  --param repo-url=https://github.com/milymoreno/creating-cicd-pipelines-with-tekton-2 \
  --param revision=main \
  --param app-name=kcd-demo-app \
  --param image-url=ghcr.io/milymoreno/kcd-demo-app:latest \
  --param sonar-token=your-sonarqube-token \
  --workspace name=shared-data,volumeClaimTemplateFile=creating-cicd-pipelines-with-tekton-2/tekton/tekton-pvc.yaml \
  --workspace name=dockerconfig,secret=regcred \
  --showlog
```

### Monitorear Ejecución
```bash
# Ver estado del pipeline
tkn pipelinerun list

# Ver logs en tiempo real
tkn pipelinerun logs --last -f

# Ver detalles específicos
tkn pipelinerun describe <pipelinerun-name>
```

---

## 🎯 **Beneficios del Pipeline Empresarial**

### 🔒 **Calidad Garantizada**
- **Pruebas automáticas** en cada build
- **Análisis de código** con SonarQube
- **Quality Gates** que bloquean código defectuoso

### 🚀 **Despliegue Seguro**
- **Imágenes inmutables** con Kaniko
- **GitOps** con ArgoCD
- **Rollback automático** en caso de fallos

### 📊 **Visibilidad Completa**
- **Reportes de pruebas** JUnit
- **Métricas de calidad** SonarQube
- **Dashboard visual** ArgoCD

### ⚡ **Eficiencia Operacional**
- **Pipeline declarativo** versionado en Git
- **Ejecución paralela** de tasks independientes
- **Reutilización** de tasks entre proyectos

---

## 🏆 **¡Felicitaciones!**

Ahora tienes un pipeline CI/CD de nivel empresarial que incluye:

✅ **Control de versiones** con Git  
✅ **Compilación** con Maven  
✅ **Pruebas unitarias** con JUnit  
✅ **Análisis de calidad** con SonarQube  
✅ **Construcción de imágenes** con Kaniko  
✅ **Despliegue GitOps** con ArgoCD

**¡Listo para producción!** 🚀