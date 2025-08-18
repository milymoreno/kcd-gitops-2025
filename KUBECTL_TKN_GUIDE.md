# 🛠️ Guía Completa: kubectl vs tkn para Tekton

## 🎯 **¿Cuándo usar cada uno?**

- **kubectl**: Comandos genéricos de Kubernetes, funciona con cualquier recurso
- **tkn**: CLI específico de Tekton, más fácil y con funciones especializadas

---

## 📋 **Comandos Básicos de Información**

### Ver Pipelines
```bash
# Con kubectl
kubectl get pipelines

# Con tkn (más información)
tkn pipeline list
tkn pipeline describe java-ci-cd-pipeline
```

### Ver PipelineRuns
```bash
# Con kubectl
kubectl get pipelineruns

# Con tkn (más detallado)
tkn pipelinerun list
tkn pipelinerun describe java-ci-cd-pipeline-run-003
tkn pipelinerun logs java-ci-cd-pipeline-run-003 -f
```

### Ver Tasks
```bash
# Con kubectl
kubectl get tasks

# Con tkn
tkn task list
tkn task describe git-clone
```

### Ver TaskRuns
```bash
# Con kubectl
kubectl get taskruns

# Con tkn
tkn taskrun list
tkn taskrun logs <taskrun-name> -f
```

---

## 🚀 **Ejecutar Pipelines**

### Método 1: Con kubectl (usando archivos YAML)
```bash
# Crear PipelineRun desde archivo
kubectl apply -f tekton-pipeline/pipeline-run-test.yaml

# Ver estado
kubectl get pipelinerun java-ci-cd-pipeline-run-003

# Ver logs (más complejo)
kubectl logs -f $(kubectl get pods --selector=tekton.dev/pipelineRun=java-ci-cd-pipeline-run-003 -o name | head -1)
```

### Método 2: Con tkn (más fácil)
```bash
# Ejecutar pipeline directamente
tkn pipeline start java-ci-cd-pipeline \
  --param repo-url=https://github.com/milymoreno/creating-cicd-pipelines-with-tekton-2 \
  --param revision=main \
  --param app-name=kcd-demo-app \
  --param environment=development \
  --workspace name=shared-data,volumeClaimTemplateFile=creating-cicd-pipelines-with-tekton-2/tekton/tekton-pvc.yaml \
  --showlog

# Ejecutar con valores por defecto
tkn pipeline start java-ci-cd-pipeline --showlog

# Ejecutar de forma interactiva (te pregunta los parámetros)
tkn pipeline start java-ci-cd-pipeline -i
```

---

## 📊 **Monitoreo y Logs**

### Ver logs en tiempo real
```bash
# Con kubectl (complejo)
kubectl logs -f deployment/hello-tekton

# Con tkn (fácil)
tkn pipelinerun logs --last -f
tkn pipelinerun logs java-ci-cd-pipeline-run-003 -f
```

### Ver estado detallado
```bash
# Con kubectl
kubectl describe pipelinerun java-ci-cd-pipeline-run-003

# Con tkn (más legible)
tkn pipelinerun describe java-ci-cd-pipeline-run-003
```

---

## 🔧 **Gestión de Recursos**

### Eliminar recursos
```bash
# Con kubectl
kubectl delete pipelinerun java-ci-cd-pipeline-run-001
kubectl delete pipeline java-ci-cd-pipeline
kubectl delete task git-clone

# Con tkn
tkn pipelinerun delete java-ci-cd-pipeline-run-001
tkn pipeline delete java-ci-cd-pipeline
tkn task delete git-clone
```

### Limpiar PipelineRuns antiguos
```bash
# Con tkn (súper útil)
tkn pipelinerun delete --keep 5  # Mantener solo los últimos 5
tkn pipelinerun delete --all     # Eliminar todos
```

---

## 🎯 **Comandos Útiles para el Taller**

### Verificar que todo funciona
```bash
# Estado general
kubectl get pipelines,tasks,pipelineruns
tkn pipeline list
tkn task list

# Ver el último PipelineRun
tkn pipelinerun list --limit 1
tkn pipelinerun logs --last -f
```

### Ejecutar pipeline de prueba
```bash
# Método rápido con tkn
tkn pipeline start java-ci-cd-pipeline \
  --param repo-url=https://github.com/milymoreno/creating-cicd-pipelines-with-tekton-2 \
  --showlog

# Método con archivo (kubectl)
kubectl apply -f tekton-pipeline/pipeline-run-test.yaml
kubectl logs -f $(kubectl get pods -l tekton.dev/pipelineRun=java-ci-cd-pipeline-run-003 -o name | head -1)
```

### Debug cuando algo falla
```bash
# Ver detalles del error
tkn pipelinerun describe <pipelinerun-name>
kubectl describe pipelinerun <pipelinerun-name>

# Ver logs específicos de una task
tkn taskrun logs <taskrun-name>
kubectl logs <pod-name> -c step-<step-name>
```

---

## 💡 **Tips y Mejores Prácticas**

### 1. **Usar tkn para desarrollo**
- Más fácil para probar pipelines
- Mejor visualización de logs
- Comandos más intuitivos

### 2. **Usar kubectl para producción**
- Archivos YAML versionados en Git
- Más control sobre la configuración
- Mejor para CI/CD automatizado

### 3. **Combinación recomendada**
```bash
# Desarrollo: tkn para pruebas rápidas
tkn pipeline start my-pipeline --showlog

# Producción: kubectl con archivos
kubectl apply -f pipelines/production-pipeline-run.yaml
```

### 4. **Monitoreo continuo**
```bash
# Ver estado en tiempo real
watch kubectl get pipelineruns
watch tkn pipelinerun list
```

---

## 🚨 **Solución de Problemas Comunes**

### Pipeline no inicia
```bash
# Verificar que el pipeline existe
tkn pipeline list

# Verificar parámetros requeridos
tkn pipeline describe <pipeline-name>

# Verificar workspaces
kubectl get pvc
```

### Logs no aparecen
```bash
# Verificar que el PipelineRun existe
tkn pipelinerun list

# Ver estado detallado
tkn pipelinerun describe <pipelinerun-name>

# Ver pods relacionados
kubectl get pods -l tekton.dev/pipelineRun=<pipelinerun-name>
```

### Task falla
```bash
# Ver logs específicos de la task
tkn taskrun logs <taskrun-name>

# Ver configuración de la task
tkn task describe <task-name>

# Verificar imágenes y permisos
kubectl describe pod <pod-name>
```

---

## 🎓 **Comandos del Taller KCD Colombia 2025**

### Setup inicial
```bash
# Verificar instalación
kubectl get pods -n tekton-pipelines
tkn version

# Aplicar tasks
kubectl apply -f tekton-tasks/
tkn task list
```

### Ejecutar pipeline del taller
```bash
# Con tkn (recomendado)
tkn pipeline start java-ci-cd-pipeline \
  --param repo-url=https://github.com/milymoreno/creating-cicd-pipelines-with-tekton-2 \
  --param revision=main \
  --param app-name=kcd-demo-app \
  --param environment=development \
  --workspace name=shared-data,volumeClaimTemplateFile=creating-cicd-pipelines-with-tekton-2/tekton/tekton-pvc.yaml \
  --showlog

# Con kubectl (alternativo)
kubectl apply -f tekton-pipeline/pipeline-run-test.yaml
kubectl get pipelineruns -w
```

### Monitorear resultados
```bash
# Ver aplicación desplegada
kubectl get deployments,services,ingress | grep hello-tekton

# Ver en ArgoCD
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Acceder a https://localhost:8080
```

---

## 🏆 **¡Felicitaciones!**

Ahora tienes una guía completa para usar tanto **kubectl** como **tkn** con Tekton. 

**Recomendación**: Usa **tkn** para desarrollo y pruebas, **kubectl** para producción y automatización.