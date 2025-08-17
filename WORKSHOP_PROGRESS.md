# KCD Colombia 2025 Workshop Progress

## CI/CD with Tekton and ArgoCD - Step by Step

### ✅ COMPLETED STEPS

#### 1. Environment Setup

- ✅ Ubuntu 22.04 system ready
- ✅ Docker installed and running
- ✅ kubectl installed
- ✅ helm installed
- ✅ git available
- ✅ Lens IDE installed

#### 2. Kubernetes Installation (K3s chosen)

- ✅ K3s installed successfully (Alternative: Minikube available)
- ✅ kubeconfig configured at `~/.kube/config`
- ✅ Permissions set correctly
- ✅ Cluster node ready: `mily Ready control-plane,master`
- ✅ System pods running: CoreDNS, Traefik, Local Path Provisioner, Metrics Server

**Alternative Minikube Setup** (if needed):

```bash
minikube start --memory=4096 --cpus=2 --disk-size=20g
```

#### 3. Tekton Installation

- ✅ Tekton Pipelines installed
- ✅ Tekton Triggers installed
- ✅ All Tekton pods running in `tekton-pipelines` namespace
- ✅ CRDs created: Pipeline, PipelineRun, Task, TaskRun, etc.

#### 4. ArgoCD Installation

- ✅ ArgoCD namespace created
- ✅ ArgoCD components installed
- ✅ **DISK ISSUE RESOLVED**: Freed 3.1GB of space (90% → 83% usage)
- ✅ **TAINT REMOVED**: Kubernetes can schedule pods again
- 🔄 **STATUS**: ArgoCD pods initializing properly

### 🔄 CURRENT STATUS

From your terminal output, I can see:

- **Tekton**: All pods are Running (1/1 Ready)
- **ArgoCD**: All pods are Running (1/1 Ready)
- **System is ready** for the next steps!

### 🔄 DISK SPACE ISSUE RESOLVED

**Problem**: Disk was 90% full causing Kubernetes disk-pressure taint
**Root Cause**: System logs accumulated over time (3.1GB of old logs)
**Solution Applied**:

```bash
# Check disk usage
df -h /

# Clean system logs (freed 3.1GB)
sudo journalctl --vacuum-time=1d

# Remove disk-pressure taint manually
kubectl taint nodes mily node.kubernetes.io/disk-pressure:NoSchedule-

# Verify space freed
df -h /  # Now 83% usage with 7.5GB free
```

**Result**: ArgoCD pods can now be scheduled properly

### 🎯 CURRENT STEP

#### 6. Create Tekton Tasks

- ✅ **git-clone task** created and applied
- ✅ **maven-build task** created and applied
- ✅ **deploy-artifact task** created and applied
- ✅ **All tasks verified** with `kubectl get tasks`

**Tasks Created**:

```bash
# Files created:
tekton-tasks/git-clone-task.yaml           # Clones Git repository
tekton-tasks/maven-build-task.yaml         # Builds Java with Maven
tekton-tasks/deploy-artifact-task.yaml     # Simulates deployment + creates K8s manifests
```

#### 7. Pipeline and ArgoCD Setup

- ✅ **Pipeline created** using your repo: `https://github.com/milymoreno/creating-cicd-pipelines-with-tekton-2`
- ✅ **Pipeline running** (java-ci-cd-pipeline-run-002)
- ✅ **ArgoCD Dashboard accessible** at https://localhost:8080
- ✅ **Admin credentials**: admin / WeNiKsLkgNQRT-wm
- ✅ **ArgoCD UI confirmed working** - Login screen visible
- ✅ **ArgoCD Application created** (kcd-demo-app)

**ArgoCD Access**:

```bash
# Port forward (running in background)
kubectl port-forward svc/argocd-server -n argocd 8080:443 &

# Access: https://localhost:8080
# User: admin
# Password: WeNiKsLkgNQRT-wm
```

### 🎯 NEXT STEPS

#### 8. Configure GitOps with ArgoCD

```bash
# Check ArgoCD pod status
kubectl get pods -n argocd

# Get ArgoCD admin password (newer versions)
kubectl -n argocd get pods -l app.kubernetes.io/name=argocd-server -o jsonpath='{.items[0].metadata.name}'

# Delete and reinstall ArgoCD if needed
kubectl delete namespace argocd
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Port forward to access ArgoCD UI (when pods are ready)
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Access: https://localhost:8080
# User: admin
# Password: (pod name from command above)
```

#### 6. Create Tekton Tasks

- Create git-clone task
- Create maven-build-java-artifact-from-source task
- Create deploy-artifact task

#### 7. Create Pipeline and PipelineRun

- Define the complete CI/CD pipeline
- Test pipeline execution

#### 8. Configure Triggers

- Create EventListener
- Create TriggerBinding
- Create TriggerTemplate
- Configure GitHub webhook

#### 9. GitOps with ArgoCD

- Register Git repository
- Create ArgoCD application
- Enable auto-sync
- Test deployment

#### 10. Demo and Testing

- Create Pull Request
- Watch pipeline execution
- Validate deployment
- Test rollback functionality

### � RCOMMON ISSUES AND SOLUTIONS

#### Disk Pressure Issue

**Symptoms**: Pods stuck in `Pending` state, `disk-pressure` taint on nodes
**Diagnosis**:

```bash
df -h /                                    # Check disk usage
kubectl describe node | grep -i taint     # Check node taints
kubectl describe pod <pod-name>           # Check scheduling issues
```

**Solution**:

```bash
sudo journalctl --vacuum-time=1d          # Clean old logs
sudo apt clean && sudo apt autoremove -y  # Clean package cache
kubectl taint nodes <node> node.kubernetes.io/disk-pressure:NoSchedule-  # Remove taint
```

### 📝 RECOVERY COMMANDS (if IDE restarts)

```bash
# Check cluster status
kubectl get nodes
kubectl get pods -A

# Verify Tekton
kubectl get pods -n tekton-pipelines

# Verify ArgoCD
kubectl get pods -n argocd

# Access ArgoCD
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

### 🎉 CURRENT ACHIEVEMENT

**Infrastructure is 100% ready!**

- K3s cluster: ✅ Running
- Tekton: ✅ Running
- ArgoCD: ✅ Running
- Ready for pipeline creation and GitOps configuration
