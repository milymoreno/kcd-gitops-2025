
# 🐳 Taller: Instalar Kubernetes en Windows con WSL2 + Docker Desktop + k3d

Esta guía te llevará paso a paso para instalar **Kubernetes** en Windows usando **WSL2**, **Docker Desktop**, **k3d** y **kubectl**.  
Ideal para desarrolladores y DevOps que necesitan un entorno rápido y ligero. 🚀

---

## **1. Verificar que WSL está instalado**

Abre **PowerShell** y ejecuta:

```bash
wsl --version
```

Si ves algo como:
```
Versión de WSL: 2.5.9.0
Versión de kernel: 6.6.x
Versión de Windows: 10.0.x
```
✅ Perfecto, WSL2 está habilitado.

Si te da error, instala WSL:
```bash
wsl --install
```

> **Nota:** Reinicia tu PC si lo pide.

---

## **2. Instalar Ubuntu (WSL2)**

Necesitamos una distribución Linux para correr Kubernetes.

### **Opción 1 — Microsoft Store (recomendada)**
1. Abre **Microsoft Store**.
2. Busca **"Ubuntu 22.04 LTS"**.
3. Haz clic en **Instalar**.
4. Ábrelo y crea **usuario** y **contraseña**.

### **Opción 2 — PowerShell**
```bash
wsl --install -d Ubuntu-22.04
```

### **Verificar instalación**
```bash
wsl --list --verbose
```
Salida esperada:
```
NAME            STATE      VERSION
Ubuntu-22.04    Stopped    2
docker-desktop  Running    2
```

---

## **Cómo abrir Ubuntu después de instalarlo (WSL2 en Windows)**

Cuando instalas **Ubuntu** por primera vez, Windows abre automáticamente la terminal para configurar tu **usuario** y **contraseña**.  
Para abrirlo en cualquier otro momento, **no necesitas reinstalarlo**. Aquí tienes las opciones:

### **1. Desde el Menú de Inicio (recomendado ✅)**
- Presiona **Inicio** → escribe **Ubuntu** → presiona **Enter**.
- Se abrirá directamente tu terminal Linux.

### **2. Desde PowerShell o CMD**
Abre **PowerShell** y ejecuta:

```bash
wsl -d Ubuntu-22.04
cd ~

```

> **Tip:** Si no sabes el nombre exacto de tu distro, verifica con:

```bash
wsl --list --verbose
```

Ejemplo de salida:
```
NAME            STATE      VERSION
Ubuntu-22.04    Running    2
docker-desktop  Stopped    2
```

### **3. Desde Windows Terminal (opcional)**
1. Abre **Windows Terminal**.
2. Haz clic en la flechita `˅` (al lado de la pestaña).
3. Selecciona **Ubuntu**.
4. Listo, entras directo al shell.

---

## **3. Instalar k3d (Kubernetes ligero sobre Docker)**

Abre **Ubuntu** y ejecuta:

```bash
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
```

Verifica la instalación:
```bash
k3d version
```

---

## **4. Instalar kubectl (Cliente oficial de Kubernetes)**

```bash
sudo apt update && sudo apt install -y ca-certificates curl
```

Instalar **kubectl**:
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

Verifica:
```bash
kubectl version --client
```

---

## **5. Crear el clúster de Kubernetes**

```bash
k3d cluster create demo-cluster --servers 1 --agents 2 --port 8080:80@loadbalancer
```

- `--servers 1`: 1 nodo master
- `--agents 2`: 2 nodos worker
- `--port 8080:80`: Expone puerto 80 en `http://localhost:8080`

Verificar nodos:
```bash
kubectl get nodes
```

---

## **6. Probar Kubernetes con un despliegue sencillo**

```bash
kubectl create deployment hello-k3d --image=nginx
kubectl expose deployment hello-k3d --type=LoadBalancer --port=80
kubectl get svc
```

Salida esperada:
```
NAME         TYPE           CLUSTER-IP     EXTERNAL-IP    PORT(S)        AGE
hello-k3d    LoadBalancer   10.43.123.45   localhost      80:8080/TCP    1m
```

Abrir en navegador:  
**http://localhost:8080** ✅

---

## **7. Comandos útiles**

| Comando                | Descripción                |
|-----------------------|---------------------------|
| `kubectl get nodes`   | Ver nodos del clúster     |
| `kubectl get pods`    | Listar pods activos       |
| `kubectl get svc`     | Listar servicios         |
| `k3d cluster list`    | Ver todos los clústeres   |
| `k3d cluster delete`  | Eliminar un clúster      |

---

## **8. Requisitos previos**

- **Windows 10/11 actualizado**
- **Docker Desktop instalado**
- **WSL2 habilitado**
- **Ubuntu 22.04 en WSL2**

---

## **Resumen de componentes**

| Componente        | Rol                                  |
|-------------------|--------------------------------------|
| **WSL2**         | Ejecutar Linux dentro de Windows    |
| **Ubuntu**       | Entorno donde instalamos k3d        |
| **Docker**       | Base para ejecutar los contenedores |
| **k3d**          | Crea clústeres Kubernetes ligeros   |
| **kubectl**      | Cliente para administrar Kubernetes |

---

> **Autor:** MilySoftArchCloud  
> **Objetivo:** Preparar el entorno para talleres de Kubernetes en Windows.
