#!/bin/bash

# Alternancia completa entre K3s Demo y OpenShift

case "$1" in
    "to-openshift")
        echo "🔄 Cambiando a OpenShift..."
        echo "⏸️  Pausando Traefik en K3s..."
        kubectl config use-context default > /dev/null 2>&1
        kubectl scale deployment traefik --replicas=0 -n kube-system
        echo "🚀 Iniciando OpenShift/CRC..."
        crc start
        echo "✅ Listo para usar OpenShift"
        ;;
    "to-k3s-demo")
        echo "🔄 Cambiando a demo K3s..."
        echo "🛑 Deteniendo OpenShift/CRC..."
        crc stop
        echo "▶️  Reanudando Traefik en K3s..."
        kubectl config use-context default > /dev/null 2>&1
        kubectl scale deployment traefik --replicas=1 -n kube-system
        echo "✅ Demo K3s listo"
        echo "🎯 Verificando servicios:"
        sleep 5
        kubectl get pods -n argocd | head -3
        tkn pipeline list | head -3
        ;;
    "status")
        echo "📊 Estado de las plataformas:"
        echo ""
        echo "🔧 K3s:"
        kubectl config use-context default > /dev/null 2>&1
        echo "   API: $(kubectl cluster-info | grep 'control plane' | awk '{print $6}')"
        echo "   Traefik: $(kubectl get deployment traefik -n kube-system --no-headers | awk '{print $2}')"
        echo ""
        echo "🚀 OpenShift/CRC:"
        if command -v crc &> /dev/null; then
            crc status 2>/dev/null || echo "   Estado: No disponible"
        else
            echo "   CRC no instalado"
        fi
        ;;
    *)
        echo "🎛️  Alternancia entre K3s Demo y OpenShift"
        echo ""
        echo "Uso: $0 [to-openshift|to-k3s-demo|status]"
        echo ""
        echo "Comandos:"
        echo "  to-openshift  - Cambiar a OpenShift (pausa K3s demo)"
        echo "  to-k3s-demo   - Volver a demo K3s (para OpenShift)"
        echo "  status        - Ver estado de ambas plataformas"
        echo ""
        echo "💡 Mantiene tu demo intacto mientras alternas"
        ;;
esac