
# 🚀 Guía de Instalación y Configuración de K3s en WSL2 (Ubuntu 22.04)

Este documento resume **solo los comandos que funcionaron** para instalar, configurar y usar **K3s** en **WSL2**.

---

## **1. Copiar el kubeconfig**
```bash
sudo cat /etc/rancher/k3s/k3s.yaml | tee ~/.kube/config > /dev/null
sudo chmod 600 ~/.kube/config
```

---

## **2. Iniciar K3s Server**
```bash
sudo /usr/local/bin/k3s server --disable traefik --write-kubeconfig ~/.kube/config
```

> Dejar esta terminal abierta, ya que aquí corre el **servidor principal**.

---

## **3. Verificar el estado del nodo**
En **otra terminal WSL**:
```bash
/usr/local/bin/k3s kubectl get nodes -o wide
```

Si todo está bien, deberías ver algo como:
```
NAME          STATUS   ROLES                  AGE   VERSION        INTERNAL-IP     EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION                     CONTAINER-RUNTIME
swopf59m84s   Ready    control-plane,master   40m   v1.33.3+k3s1   172.26.166.31   <none>        Ubuntu 22.04.5 LTS   6.6.87.2-microsoft-standard-WSL2   containerd://2.0.5-k3s2
```

---

## **4. Crear un alias para usar kubectl**
```bash
echo 'alias kubectl="/usr/local/bin/k3s kubectl"' >> ~/.bashrc && source ~/.bashrc
```

Ahora puedes usar:
```bash
kubectl get pods -A
```

---

## **Resumen**
- K3s corre en **WSL2 Ubuntu 22.04**
- El servidor K3s se lanza manualmente
- Para interactuar con el clúster, usa `kubectl` con alias

---

## **Próximos pasos**
- Configurar **ingress** y **traefik** si lo necesitamos.
- Automatizar el arranque del servidor K3s al iniciar WSL.

