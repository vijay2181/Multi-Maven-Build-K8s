# Multi-Module Maven CI/CD Pipeline with Jenkins + Kubernetes

<img width="3600" height="623" alt="image" src="https://github.com/user-attachments/assets/f8087006-4bb8-4abe-b30e-032290f5083b" />

## 📌 Overview

This project provides a **smart, automated CI/CD pipeline** for a monorepo containing multiple Maven applications.

Instead of building everything every time, the pipeline:

* ✅ Builds **only the Maven projects that changed**
* ✅ Automatically selects the correct environment (`dev / qa / prod`) based on the Git branch
* ✅ Runs builds inside **temporary Kubernetes pods**
* ✅ Generates **environment-specific JAR files**
* ✅ Cleans up build infrastructure automatically

This solution is ideal for teams managing multiple microservices in a single GitHub repository.

---

## 🎯 Problem Statement

You have **2–3 Maven applications inside one GitHub repository**.

When developers push code:

* ❌ You don’t want to build all projects unnecessarily.
* ❌ You don’t want manual environment configuration.
* ❌ You don’t want permanent build servers consuming resources.

You need:

* Automatic detection of changed modules
* Environment-aware builds
* On-demand scalable infrastructure
* Clean artifact management

---

## ✅ Solution

This repository implements a **Jenkins Declarative Pipeline** integrated with:

* **GitHub Webhooks**
* **Jenkins**
* **Kubernetes**
* **Maven**

### 🔥 What It Does

1. Watches your GitHub repository
2. Automatically triggers Jenkins on push
3. Creates a temporary Kubernetes pod
4. Builds only modified Maven modules
5. Generates environment-specific JAR files:

   * `user-service-1.0.0-dev.jar`
   * `order-service-1.0.0-prod.jar`
6. Archives artifacts in Jenkins
7. Deletes the build pod after completion

---

## 📦 Example Repository Structure

```
my-company-repo/
├── user-service/
├── order-service/
└── payment-service/
```

Each folder is an independent Maven project.

---

## 🧠 How It Works

### 🟢 Scenario 1: Developer pushes to `develop`

* Jenkins detects branch = `develop`
* Environment = `dev`
* Builds only changed modules
* Generates:

```
user-service-1.0.0-dev.jar
```

---

### 🔴 Scenario 2: Release to Production (`main` branch)

* Jenkins detects branch = `main`
* Environment = `prod`
* Builds all changed services
* Generates:

```
user-service-1.0.0-prod.jar
order-service-1.0.0-prod.jar
```

---

## 🔄 Complete Pipeline Flow

```
1. Developer writes code
        ↓
2. Push to GitHub
        ↓
3. GitHub Webhook triggers Jenkins
        ↓
4. Jenkins reads Jenkinsfile
        ↓
5. Jenkins requests Kubernetes build pod
        ↓
6. Pod starts (Java + Maven)
        ↓
7. Maven builds changed modules
        ↓
8. Environment-specific JARs created
        ↓
9. Jenkins archives artifacts
        ↓
10. Pod is destroyed
```

---

## 🌿 Branch-to-Environment Mapping

| Branch  | Environment | Output Suffix |
| ------- | ----------- | ------------- |
| develop | dev         | `-dev.jar`    |
| qa      | qa          | `-qa.jar`     |
| main    | prod        | `-prod.jar`   |

---

## 📦 Artifacts Generated

Each build generates:

```
<service-name>-<version>-<environment>.jar
```

Example:

```
payment-service-1.0.0-prod.jar
```

Artifacts are stored in:

* Jenkins build archive
* (Optional) Nexus / Artifactory / S3

---

## 📂 Jenkinsfile Highlights

* Uses Kubernetes agent
* Detects changed directories using Git diff
* Maps branch → environment
* Builds specific modules via:

```
mvn clean package -pl <module> -am
```

* Archives artifacts

---

## 🔐 Why This Approach?

### Traditional Approach

* Always builds everything
* Static build agents
* Slower pipelines
* Wasted compute resources

### This Approach

* Smart change detection
* Dynamic build infrastructure
* Faster feedback
* Cost efficient
* Scalable

---

## 📈 Benefits for Teams

* Faster pull request validation
* Environment-safe releases
* Microservice-friendly architecture
* Production-ready CI/CD design
* Cloud-native build strategy

---

## 🎯 Ideal For

* Microservices architecture
* Multi-module Maven projects
* DevOps teams using Kubernetes
* Organizations practicing GitOps
* Teams wanting scalable CI/CD

---

## 📌 Future Enhancements

* Add Docker image build per service
* Push images to container registry
* Add Helm-based deployment
* Integrate SonarQube analysis
* Add automated rollback support



# Jenkins Multi-Branch Pipeline

---

## 🎯 Overview

This guide sets up a **Jenkins Multi-Branch Pipeline** that:
- ✅ Auto-discovers all branches in your GitHub repository
- ✅ Builds each branch separately with appropriate environment (dev/qa/prod)
- ✅ Automatically builds Pull Requests before merging
- ✅ Uses Kubernetes pod agents for isolated builds
- ✅ Builds only changed Maven projects intelligently
- ✅ Creates environment-specific artifacts
- ✅ Auto-cleans up deleted branches

---

## 📊 Why Multi-Branch Pipeline?

### Comparison: Regular vs Multi-Branch

| Feature | Regular Pipeline | Multi-Branch Pipeline ✅ |
|---------|-----------------|-------------------------|
| Branch Discovery | Manual | Automatic |
| Multiple Branches | Separate jobs needed | One job for all |
| New Branches | Manual setup | Auto-discovered |
| Pull Requests | Not supported | Auto-builds PRs |
| Branch Cleanup | Manual | Automatic |
| Scalability | Poor (many jobs) | Excellent (one job) |

### Visual Comparison

```
Regular Pipeline:                Multi-Branch Pipeline: ✅
├── maven-build-main            └── maven-multi-project/
├── maven-build-develop             ├── main (auto)
├── maven-build-release-v1          ├── develop (auto)
└── maven-build-release-v2          ├── release/v1.0 (auto)
    (Manual creation)                ├── release/v2.0 (auto)
                                     └── PR-123 (auto)
```

---

## 🏗️ Architecture

```
GitHub Repository (All Branches)
         │
         │ Webhook
         ▼
Jenkins Multi-Branch Job
         │
         ├─→ main branch → prod environment → K8s Pod → Build → Artifacts
         ├─→ develop branch → dev environment → K8s Pod → Build → Artifacts
         ├─→ release/v1 → qa environment → K8s Pod → Build → Artifacts
         └─→ PR-123 → test environment → K8s Pod → Build → Artifacts
```

---

## 📋 Prerequisites

### Required Infrastructure
- GitHub repository with admin access
- Jenkins Server (v2.300+)
- Kubernetes Cluster (v1.20+)
- Maven projects (v3.6+)



# Jenkins Multi-Branch Pipeline on K3s (Linux)
---

## 🎯 Overview

This guide sets up a **complete CI/CD pipeline** using:
- ✅ **K3s** - Lightweight Kubernetes (perfect for 4GB RAM)
- ✅ **Jenkins** - Running as a pod in K3s cluster
- ✅ **Multi-Branch Pipeline** - Auto-discovers GitHub branches
- ✅ **Dynamic Build Pods** - Maven builds in isolated containers
- ✅ **Internet Access** - Full connectivity for image pulls and builds

**Perfect for low-resource systems and private VMs!**

---

## 📋 System Requirements

### Minimum Requirements
- **OS**: Linux (Ubuntu 20.04+, Debian, CentOS, RHEL)
- **RAM**: 4GB (2GB for K3s + 1.5GB for Jenkins + 0.5GB for builds)
- **CPU**: 2 cores
- **Disk**: 20GB free space
- **Internet**: Required for initial setup

### Your System
```bash
# Check your resources
free -h        # RAM
nproc          # CPU cores
df -h          # Disk space
curl -I google.com  # Internet connectivity
```

---

## 🚀 Quick Start (5 Minutes)

### Installation

```bash
- install docker

# Update package index
sudo apt-get update

# Install dependencies
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up stable repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Add your user to docker group (avoid sudo)
sudo usermod -aG docker $USER

# Apply group changes (or logout/login)
newgrp docker

# Verify installation
docker --version
docker run hello-world

```

---

## 📝 Step-by-Step Installation

### Step 1: Install K3s

```bash
# Install K3s (takes 30 seconds)
curl -sfL https://get.k3s.io | sh -

# Verify installation
k3s --version
k3s kubectl get nodes

# Set up kubectl
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> ~/.bashrc

# Test kubectl
kubectl get nodes
```

**Expected Output:**
```
NAME                          STATUS   ROLES           AGE   VERSION
your-hostname                 Ready    control-plane   1m    v1.34.4+k3s1
```

### Step 2: Install Helm (if not installed)

```bash
# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verify
helm version
```

### Step 3: Create Jenkins Namespace

```bash
kubectl create namespace jenkins

# Verify
kubectl get namespaces
```

### Step 4: Add Jenkins Helm Repository

```bash
# Add repository
helm repo add jenkins https://charts.jenkins.io

# Update repositories
helm repo update

# Verify
helm search repo jenkins
```

### Step 5: Create Jenkins Configuration

```bash
# Create jenkins-values.yaml
cat <<EOF > jenkins-values.yaml
controller:
  # Service configuration
  serviceType: NodePort
  nodePort: 30000
  
  # Admin credentials
  admin:
    username: "admin"
    # Password will be auto-generated
  
  # Essential plugins for Multi-Branch Pipeline
  installPlugins:
    - kubernetes:latest
    - workflow-aggregator:latest
    - git:latest
    - configuration-as-code:latest
    - github-branch-source:latest
    - pipeline-stage-view:latest
    - credentials-binding:latest
    - github:latest
  
  # Resource limits (optimized for 4GB RAM)
  resources:
    requests:
      cpu: "500m"
      memory: "1Gi"
    limits:
      cpu: "1000m"
      memory: "1.5Gi"
  
  # JVM heap settings
  javaOpts: "-Xms512m -Xmx1g"
  
  # Jenkins Configuration as Code
  JCasC:
    defaultConfig: true
    configScripts:
      welcome-message: |
        jenkins:
          systemMessage: "Jenkins Multi-Branch Pipeline on K3s"

# Disable default agent (we'll use Kubernetes plugin)
agent:
  enabled: false

# Disable persistence (for testing - enable for production)
persistence:
  enabled: false

# Enable RBAC
rbac:
  create: true
  readSecrets: true
EOF
```

### Step 6: Install Jenkins

```bash
# Install Jenkins using Helm
helm install jenkins jenkins/jenkins \
  --namespace jenkins \
  --values jenkins-values.yaml

# Monitor installation
kubectl get pods -n jenkins -w
```

**Wait for pod to show "2/2 Running"** (takes 3-5 minutes)

### Step 7: Get Admin Password

```bash
# Get admin password
kubectl exec --namespace jenkins -it svc/jenkins -c jenkins -- \
  /bin/cat /run/secrets/additional/chart-admin-password && echo

# Save this password!
```

### Step 8: Access Jenkins

```bash
- i have a remote vm -> kind-ubuntu.dev.com
- connected to remote vm and installed k3s there

# SSH with port forwarding in one command
ssh -i key.pem -L 30000:localhost:30000 root@kind-ubuntu.dev.com \
  "kubectl port-forward -n jenkins svc/jenkins 30000:8080 --address=127.0.0.1"

# This will:
# 1. SSH to remote VM
# 2. Start port-forward on VM
# 3. Forward port to your Mac
# 4. Keep connection open

# Open browser on Mac: http://localhost:30000
```

**Access Jenkins:**
- **From VM**: http://localhost:30000
- **Username**: admin
- **Password**: (from Step 7)

---

## 🌐 Internet Access Configuration

K3s has **full internet access by default**. Here's how to verify and troubleshoot:

### Verify Internet Access

```bash
# Test from K3s node
curl -I https://google.com

# Test from a pod
kubectl run test-internet --image=busybox --rm -it --restart=Never -- wget -O- https://google.com

# Test DNS resolution
kubectl run test-dns --image=busybox --rm -it --restart=Never -- nslookup google.com
```


## 🔧 Configure Jenkins

### Step 1: Initial Login

1. Open browser: http://localhost:30000
2. Login with admin / password
3. Click "Start using Jenkins"

### Step 2: Configure Kubernetes Cloud

1. **Manage Jenkins** → **Manage Nodes and Clouds** → **Configure Clouds**
2. Click **Add a new cloud** → **Kubernetes**
3. Configure:

```
Cloud Name: kubernetes

Kubernetes URL: https://kubernetes.default.svc.cluster.local
(Leave empty - uses in-cluster config)
(Leave empty - Jenkins will auto-detect since it's running in the cluster)

Kubernetes Namespace: jenkins

Credentials: (None - leave as "- none -")
(Jenkins uses the service account automatically)

Jenkins URL: http://jenkins.jenkins.svc.cluster.local:8080

Jenkins tunnel: jenkins-agent.jenkins.svc.cluster.local:50000

WebSocket: ✓ (checked)

Test Connection
Click Test Connection button
Should show: "Connected to Kubernetes v1.34.4+k3s1" ✅
If successful, click Save


TEST POD:
---------
Create Test Pipeline
New Item → Enter name: test-k8s-pod
Select Pipeline
Click OK
In Pipeline section, paste:
pipeline {
  agent {
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: busybox
    image: busybox
    command: ['cat']
    tty: true
"""
      defaultContainer 'busybox'
    }
  }
  stages {
    stage('Test') {
      steps {
        sh 'echo "Hello from K3s pod!"'
        sh 'hostname'
        sh 'pwd'
      }
    }
  }
}

Click Save
Click Build Now
Test 3: Watch Pod Creation
On Fyre VM (in another terminal):

# Watch pods being created
kubectl get pods -n jenkins -w
NAME                       READY   STATUS    RESTARTS   AGE
jenkins-0                  2/2     Running   0          27m
test-1-cvkmj-dfcl9-dns0n   2/2     Running   0          19s


```

4. Click **Test Connection**
   - Should show: "Connected to Kubernetes v1.34.4"

5. Click **Save**

### Step 3: Verify Kubernetes Plugin

1. **Manage Jenkins** → **Manage Plugins** → **Installed**
2. Search for "Kubernetes"
3. Should show: Kubernetes Plugin (installed)

---

## 📁 Setup GitHub Repository

### Step 1: Create Repository Structure

```bash
use project-setup.sh script to create all project files

root@test-vm:~/Multi-Maven-Build-K8s# tree
.
├── Jenkinsfile
├── project-a
│   ├── pom.xml
│   └── src
│       ├── main
│       │   ├── java
│       │   │   └── com
│       │   │       └── example
│       │   │           └── Main.java
│       │   └── resources
│       │       └── application.properties
│       └── test
│           └── java
│               └── com
│                   └── example
├── project-b
│   ├── pom.xml
│   └── src
│       ├── main
│       │   ├── java
│       │   │   └── com
│       │   │       └── example
│       │   │           └── Main.java
│       │   └── resources
│       │       └── application.properties
│       └── test
│           └── java
│               └── com
│                   └── example
├── project-c
│   ├── pom.xml
│   └── src
│       ├── main
│       │   ├── java
│       │   │   └── com
│       │   │       └── example
│       │   │           └── Main.java
│       │   └── resources
│       │       └── application.properties
│       └── test
│           └── java
│               └── com
│                   └── example
└── README.md

```

### Step 6: Create Branches and Push

```bash
# Initialize git (if not already)
git add .
git commit -m "Initial commit: K3s Jenkins Multi-Branch setup"

# Create and push main branch
git branch -M main
git push -u origin main

# Create develop branch
git checkout -b develop
git push -u origin develop

# Create release branch
git checkout -b release/v1.0
git push -u origin release/v1.0

# Return to main
git checkout main
```

---

## 🎯 Create Multi-Branch Pipeline Job

### Step 1: Create GitHub Personal Access Token

1. GitHub → Settings → Developer settings → Personal access tokens
2. Generate new token (classic)
3. Scopes: ✅ `repo`, ✅ `admin:repo_hook`
4. Copy token (save securely!)

### Step 2: Add Credentials in Jenkins

1. **Manage Jenkins** → **Manage Credentials** → **Global** → **Add Credentials**
2. Configure:
   - Kind: `Username with password`
   - Username: Your GitHub username
   - Password: GitHub Personal Access Token
   - ID: `github-token`
   - Description: `GitHub Access Token`
3. Click **Create**

### Step 3: Create Multi-Branch Pipeline Job

1. **Jenkins Dashboard** → **New Item**
2. Name: `maven-multi-project`
3. Type: **Multibranch Pipeline**
4. Click **OK**

### Step 4: Configure Branch Sources

**Branch Sources** → **Add source** → **GitHub**

1. **Credentials**: Select `github-token`
2. **Repository HTTPS URL**: `https://github.com/your-org/your-repo`
3. **Behaviors** → Click **Add**:
   - ✅ Discover branches
   - ✅ Discover pull requests from origin
4. **Build Configuration**:
   - Mode: `by Jenkinsfile`
   - Script Path: `Jenkinsfile`
5. **Scan Multibranch Pipeline Triggers**:
   - ✅ Periodically if not otherwise run: `1 minute`
6. **Orphaned Item Strategy**:
   - Days to keep: `7`
   - Max # to keep: `10`

### Step 5: Save and Scan

Click **Save** → Jenkins automatically scans and discovers branches!

---


### Test 5: Trigger via Git Push

```bash
# Make a change
git checkout develop
echo "test" >> README.md
git add .
git commit -m "test: trigger build"
git push origin main

# Jenkins should automatically build within 1 minute
this will trigger all 3 projects



NOW MAKE CHNAGES ONLY INSIDE project-a

🎯 expectation
Branch: main

Changed: Only project-a files

Built: Only project-a ✅

Environment: (should be prod for main branch)

Artifact: project-a-1.0.0-dev.jar ✅


[WARNING] Replacing pre-existing project main-artifact file: /home/jenkins/agent/workspace/multi-module-maven/project-a/target/archive-tmp/project-a-1.0.0-prod.jar
with assembly file: /home/jenkins/agent/workspace/multi-module-maven/project-a/target/project-a-1.0.0-prod.jar
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  36.094 s
[INFO] Finished at: 2026-03-03T04:35:24Z
[INFO] ------------------------------------------------------------------------
[Pipeline] echo
✓ project-a completed successfully

```

---

## 🔍 Monitoring and Debugging

### View Jenkins Logs

```bash
# View Jenkins controller logs
kubectl logs -f jenkins-0 -n jenkins -c jenkins

# View build pod logs (while running)
kubectl logs -f <build-pod-name> -n jenkins
```

### View All Pods

```bash
# List all pods
kubectl get pods -n jenkins

# Describe a pod
kubectl describe pod <pod-name> -n jenkins

# Get events
kubectl get events -n jenkins --sort-by='.lastTimestamp'
```

### Check Internet Connectivity

```bash
# From Jenkins pod
kubectl exec -it jenkins-0 -n jenkins -c jenkins -- curl -I https://google.com

# From build pod (while running)
kubectl exec -it <build-pod-name> -n jenkins -- curl -I https://repo.maven.apache.org
```

### Check K3s Status

```bash
# Check K3s service
sudo systemctl status k3s

# Check K3s logs
sudo journalctl -u k3s -f

# Check node status
kubectl get nodes -o wide

# Check cluster info
kubectl cluster-info
```

---

## 🛠️ Troubleshooting

### Issue 1: Jenkins Pod Not Starting

```bash
# Check pod status
kubectl get pods -n jenkins
kubectl describe pod jenkins-0 -n jenkins

# Check events
kubectl get events -n jenkins --sort-by='.lastTimestamp' | tail -20

# Check logs
kubectl logs jenkins-0 -n jenkins -c init
kubectl logs jenkins-0 -n jenkins -c jenkins
```

### Issue 2: Build Pod Can't Pull Images

```bash
# Test internet from cluster
kubectl run test-internet --image=busybox --rm -it --restart=Never -- wget -O- https://google.com

# If fails, check K3s internet access
curl -I https://google.com

# Check DNS
kubectl run test-dns --image=busybox --rm -it --restart=Never -- nslookup google.com
```

### Issue 3: Maven Dependencies Not Downloading

```bash
# Check from build pod
kubectl exec -it <build-pod-name> -n jenkins -- curl -I https://repo.maven.apache.org

# If behind proxy, configure in Jenkinsfile:
# Add to maven command:
# -Dhttp.proxyHost=proxy.example.com -Dhttp.proxyPort=8080
```

### Issue 4: K3s Service Not Running

```bash
# Check service status
sudo systemctl status k3s

# Restart K3s
sudo systemctl restart k3s

# Check logs
sudo journalctl -u k3s -n 100 --no-pager
```

### Issue 5: Port 30000 Not Accessible

```bash
# Check if port is listening
sudo netstat -tulpn | grep 30000

# Check firewall
sudo ufw status
sudo ufw allow 30000/tcp

# Or disable firewall (testing only)
sudo ufw disable
```

---

## 🧹 Cleanup

### Uninstall Jenkins

```bash
# Uninstall Jenkins
helm uninstall jenkins -n jenkins

# Delete namespace
kubectl delete namespace jenkins
```

### Uninstall K3s

```bash
# Uninstall K3s completely
/usr/local/bin/k3s-uninstall.sh

# Verify
kubectl get nodes  # Should fail
```

### Clean Docker Images

```bash
# Remove unused images
docker system prune -a
```

---

## 📊 Resource Usage

### Typical Resource Consumption

```
K3s Control Plane:       ~512MB RAM, 0.5 CPU
Jenkins Controller:      ~1GB RAM, 0.5 CPU
Maven Build Pod:         ~512MB-1GB RAM, 0.25-0.5 CPU
-------------------------------------------
Total (idle):            ~1.5GB RAM, 1 CPU
Total (building):        ~2.5-3GB RAM, 1.5-2 CPU
```

### Monitor Resources

```bash
# System resources
free -h
top

# K3s resources
kubectl top nodes
kubectl top pods -n jenkins

# Docker resources
docker stats
```

---

## 🎓 Best Practices

### 1. Enable Persistence (Production)

```yaml
persistence:
  enabled: true
  size: 10Gi
  storageClass: local-path  # K3s default
```

### 2. Configure Resource Limits

Always set resource limits in Jenkinsfile:

```yaml
resources:
  requests:
    memory: "512Mi"
    cpu: "250m"
  limits:
    memory: "1Gi"
    cpu: "500m"
```

### 3. Use Maven Cache

Add persistent volume for Maven cache:

```yaml
volumes:
- name: maven-cache
  persistentVolumeClaim:
    claimName: maven-cache-pvc
```

### 4. Secure Jenkins

- Enable HTTPS
- Use strong passwords
- Configure RBAC properly
- Regular backups

### 5. Monitor Builds

- Set up build notifications (Slack, email)
- Monitor resource usage
- Archive important artifacts

---

## 🌐 External Access Setup

### Option 1: Port Forwarding (SSH Tunnel)

From your local machine:

```bash
ssh -L 30000:localhost:30000 user@your-vm-ip

# Access at: http://localhost:30000
```

### Option 2: ngrok (for GitHub Webhooks)

```bash
# Install ngrok
curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | \
  sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null && \
  echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | \
  sudo tee /etc/apt/sources.list.d/ngrok.list && \
  sudo apt update && sudo apt install ngrok

# Configure with your token
ngrok config add-authtoken YOUR_TOKEN

# Expose Jenkins
ngrok http 30000

# Use ngrok URL in GitHub webhook
# https://your-ngrok-url.ngrok.io/github-webhook/
```

### Option 3: Firewall Configuration

```bash
# Allow port 30000
sudo ufw allow 30000/tcp

# Check status
sudo ufw status
```

---

## 📚 Useful Commands Reference

### K3s Commands

```bash
# Start/Stop/Restart K3s
sudo systemctl start k3s
sudo systemctl stop k3s
sudo systemctl restart k3s

# Check status
sudo systemctl status k3s

# View logs
sudo journalctl -u k3s -f

# Uninstall
/usr/local/bin/k3s-uninstall.sh
```

### kubectl Commands

```bash
# Get resources
kubectl get nodes
kubectl get pods -n jenkins
kubectl get all -n jenkins

# Describe resources
kubectl describe pod <pod-name> -n jenkins
kubectl describe node

# Logs
kubectl logs -f <pod-name> -n jenkins
kubectl logs -f <pod-name> -n jenkins -c <container-name>

# Execute commands
kubectl exec -it <pod-name> -n jenkins -- /bin/bash

# Port forward
kubectl port-forward -n jenkins svc/jenkins 8080:8080
```

### Helm Commands

```bash
# List releases
helm list -n jenkins

# Get values
helm get values jenkins -n jenkins

# Upgrade
helm upgrade jenkins jenkins/jenkins -n jenkins --values jenkins-values.yaml

# Uninstall
helm uninstall jenkins -n jenkins
```

### Jenkins Aliases

```bash
# Add to ~/.bashrc
echo 'alias jenkins-status="kubectl get pods -n jenkins"' >> ~/.bashrc
echo 'alias jenkins-logs="kubectl logs -f jenkins-0 -n jenkins -c jenkins"' >> ~/.bashrc
echo 'alias jenkins-password="kubectl exec -n jenkins -it svc/jenkins -c jenkins -- cat /run/secrets/additional/chart-admin-password"' >> ~/.bashrc
echo 'alias jenkins-url="echo http://localhost:30000"' >> ~/.bashrc
source ~/.bashrc

# Usage
jenkins-status
jenkins-logs
jenkins-password
jenkins-url
```

---

## ✅ Summary

You now have:
- ✅ K3s cluster running on Linux
- ✅ Jenkins running as a pod in K3s
- ✅ Multi-Branch Pipeline configured
- ✅ Full internet access for builds
- ✅ Automatic branch discovery
- ✅ Dynamic Maven build pods
- ✅ Environment-based builds (dev/qa/prod)

**Everything runs locally with full internet connectivity!**

---

## 🆘 Getting Help

If you encounter issues:

1. Check K3s status: `sudo systemctl status k3s`
2. Check Jenkins logs: `kubectl logs jenkins-0 -n jenkins -c jenkins`
3. Check build pod logs: `kubectl logs <pod-name> -n jenkins`
4. Check internet: `curl -I https://google.com`
5. Check events: `kubectl get events -n jenkins --sort-by='.lastTimestamp'`

---

**Version:** 1.0.0  
**Last Updated:** 2026-03-03  
**Platform:** Linux (K3s)  
**Author:** DevOps Team
