#!/bin/bash

# 🔍 Script de Instalación de SonarQube para KCD Colombia 2025
# Instala SonarQube en Kubernetes para usar con tekton-tasks/sonarqube-task.yaml

set -e

echo "🔍 Instalando SonarQube en Kubernetes..."

# Crear namespace
echo "📁 Creando namespace sonarqube..."
kubectl create namespace sonarqube --dry-run=client -o yaml | kubectl apply -f -

# Verificar si Helm está instalado
if ! command -v helm &> /dev/null; then
    echo "❌ Helm no está instalado. Instalando con método alternativo..."
    
    # Método alternativo sin Helm
    echo "🚀 Desplegando SonarQube con kubectl..."
    kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sonarqube
  namespace: sonarqube
  labels:
    app: sonarqube
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
        - name: SONAR_JDBC_URL
          value: "jdbc:h2:mem:sonarqube"
        resources:
          requests:
            memory: "1Gi"
            cpu: "500m"
          limits:
            memory: "2Gi"
            cpu: "1000m"
        readinessProbe:
          httpGet:
            path: /api/system/status
            port: 9000
          initialDelaySeconds: 60
          periodSeconds: 30
        livenessProbe:
          httpGet:
            path: /api/system/status
            port: 9000
          initialDelaySeconds: 120
          periodSeconds: 30
---
apiVersion: v1
kind: Service
metadata:
  name: sonarqube
  namespace: sonarqube
  labels:
    app: sonarqube
spec:
  selector:
    app: sonarqube
  ports:
  - name: http
    port: 9000
    targetPort: 9000
  type: ClusterIP
EOF

else
    echo "✅ Helm encontrado. Instalando con Helm..."
    
    # Agregar repositorio de SonarQube
    echo "📦 Agregando repositorio de SonarQube..."
    helm repo add sonarqube https://SonarSource.github.io/helm-chart-sonarqube
    helm repo update
    
    # Instalar SonarQube
    echo "🚀 Instalando SonarQube..."
    helm install sonarqube sonarqube/sonarqube \
      --namespace sonarqube \
      --set persistence.enabled=false \
      --set postgresql.enabled=false \
      --set "sonarqube.env[0].name=SONAR_JDBC_URL" \
      --set "sonarqube.env[0].value=jdbc:h2:mem:sonarqube" \
      --set resources.requests.memory=1Gi \
      --set resources.requests.cpu=500m \
      --set resources.limits.memory=2Gi \
      --set resources.limits.cpu=1000m
fi

echo "⏳ Esperando a que SonarQube esté listo..."
kubectl wait --for=condition=Ready pod --all -n sonarqube --timeout=600s

echo "✅ SonarQube instalado correctamente!"
echo ""
echo "🌐 Para acceder a SonarQube:"
echo "   kubectl port-forward -n sonarqube svc/sonarqube 9000:9000"
echo "   Luego abrir: http://localhost:9000"
echo ""
echo "🔐 Credenciales iniciales:"
echo "   Usuario: admin"
echo "   Contraseña: admin"
echo "   (Cambiar en el primer acceso)"
echo ""
echo "🔧 Para usar en Tekton:"
echo "   1. Crear un proyecto en SonarQube"
echo "   2. Generar un token de autenticación"
echo "   3. Usar el token en la task sonarqube-analysis"
echo ""
echo "📋 Verificar instalación:"
echo "   kubectl get pods -n sonarqube"
echo "   kubectl get svc -n sonarqube"
echo ""
echo "🎉 ¡SonarQube listo para el workshop KCD Colombia 2025!"