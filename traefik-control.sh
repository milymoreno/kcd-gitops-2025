#!/bin/bash

# Control de Traefik para alternar entre K3s y OpenShift/CRC

case "$1" in
    "pause")
        echo "⏸️  Pausando Traefik para usar OpenShift..."
        kubectl config use-context default > /dev/null 2>&1
        kubectl scale deployment traefik --replicas=0 -n kube-system
        echo "✅ Traefik pausado. Ahora puedes usar OpenShift/CRC"
        echo "📋 Para reanudar tu demo: $0 resume"
        ;;
    "resume")
        echo "▶️  Reanudando Traefik para tu demo K3s..."
        kubectl config use-context default > /dev/null 2>&1
        kubectl scale deployment traefik --replicas=1 -n kube-system
        echo "✅ Traefik reanudado. Tu demo K3s está listo"
        ;;
    "status")
        echo "📊 Estado de Traefik:"
        kubectl config use-context default > /dev/null 2>&1
        kubectl get deployment traefik -n kube-system
        echo ""
        echo "📋 Pods de Traefik:"
        kubectl get pods -n kube-system | grep traefik
        ;;
    *)
        echo "🎛️  Control de Traefik para K3s/OpenShift"
        echo ""
        echo "Uso: $0 [pause|resume|status]"
        echo ""
        echo "Comandos:"
        echo "  pause  - Pausar Traefik para usar OpenShift"
        echo "  resume - Reanudar Traefik para demo K3s"
        echo "  status - Ver estado actual de Traefik"
        echo ""
        echo "💡 Esto te permite alternar sin perder tu demo"
        ;;
esac