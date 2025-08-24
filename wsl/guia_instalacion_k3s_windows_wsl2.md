
# 🐳 Taller Kubernetes: Instalación de K3s en Windows con WSL2

Esta guía documenta **los pasos exactos y funcionales** para instalar y configurar **k3s** en **Windows 10/11** usando **WSL2 + Ubuntu 22.04**.  
Incluye la solución a los problemas de permisos y certificados encontrados durante la instalación. 🚀

---

## **1. Preparar el entorno**

### **Requisitos previos**
- Windows 10/11 actualizado
- **WSL2 habilitado**
- **Ubuntu 22.04 LTS** instalado en WSL2
- **Docker Desktop** *(opcional)*
- Acceso a **PowerShell con permisos de administrador**

Verificar versión de WSL:
```bash
wsl --version
```

---

## **2. Descargar el binario de k3s manualmente**

En **Ubuntu** dentro de WSL, ejecuta:

```bash
sudo wget --no-check-certificate -O /usr/local/bin/k3s https://github.com/k3s-io/k3s/releases/latest/download/k3s
```

Dar permisos de ejecución:

```bash
sudo chmod +x /usr/local/bin/k3s
```

Verificar instalación:
```bash
k3s --version
```

---

## **3. Iniciar k3s manualmente**

```bash
sudo /usr/local/bin/k3s server --disable traefik --write-kubeconfig ~/.kube/config
```

- `--disable traefik`: evita instalar el Ingress Controller por defecto.
- `--write-kubeconfig`: genera el archivo de configuración para `kubectl`.

**Importante:** Deja esta terminal abierta para mantener el clúster activo.

---

## **4. Configurar kubectl para usar k3s**

Abrir **otra terminal** de Ubuntu y crear la carpeta `.kube` si no existe:

```bash
mkdir -p ~/.kube
```

Copiar el archivo de configuración de k3s:

```bash
sudo cat /etc/rancher/k3s/k3s.yaml | sudo tee ~/.kube/config > /dev/null
```

Dar propiedad al usuario actual:

```bash
sudo chown $(id -u):$(id -g) ~/.kube/config
```

Asignar permisos correctos:

```bash
chmod 600 ~/.kube/config
```

---

## **5. Probar el clúster**

Verificar que k3s está funcionando correctamente:

```bash
kubectl get nodes -o wide
```

Deberías ver algo como:
```
NAME        STATUS   ROLES                  AGE   VERSION
mily-wsl    Ready    control-plane,master   25s   v1.30.x+k3s1
```

---

## **6. Clonar el repositorio del taller**

```bash
git clone https://github.com/milymoreno/creating-cicd-pipelines-with-tekton-2
cd creating-cicd-pipelines-with-tekton-2
```

---

## **Notas importantes**

1. No uses rutas bajo **/mnt/c/** para configurar `k3s` o `kubectl`.  
   Usa siempre tu **home Linux**: `/home/tu_usuario`.
2. Si la red está detrás de **Zscaler** o un proxy, usa `--no-check-certificate` para evitar errores SSL.
3. Mantén la terminal donde corres `k3s server` abierta; si la cierras, el clúster se detendrá.

---

> **Autor:** MilySoftArchCloud  
> **Objetivo:** Instrucciones funcionales y probadas para instalar K3s en Windows usando WSL2.
