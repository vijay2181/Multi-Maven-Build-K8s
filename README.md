# Multi-Module Maven CI/CD Pipeline with Jenkins + Kubernetes

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



# GitHub → Jenkins Multi-Branch Pipeline → Kubernetes
## Complete Guide for Multi-Maven Project Builds

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

### Jenkins Plugins (Install via Manage Jenkins → Manage Plugins)

| Plugin | Purpose |
|--------|---------|
| **GitHub Branch Source** | Multi-branch GitHub integration |
| **Kubernetes** | K8s pod agents |
| **Pipeline: Multibranch** | Multi-branch support |
| **Git** | SCM operations |
| **Credentials** | Credential management |

---

## 🚀 Quick Start Guide

### Step 1: Repository Structure

Create this structure in your GitHub repository:

```
your-repo/
├── Jenkinsfile              # REQUIRED - Pipeline definition
├── project-a/
│   ├── pom.xml
│   └── src/
├── project-b/
│   ├── pom.xml
│   └── src/
└── project-c/
    ├── pom.xml
    └── src/
```

### Step 2: Create Branches

```bash
# Initialize and create branches
git checkout -b main
git push -u origin main

git checkout -b develop
git push -u origin develop

git checkout -b release/v1.0
git push -u origin release/v1.0
```

### Step 3: GitHub Personal Access Token

1. GitHub → Settings → Developer settings → Personal access tokens
2. Generate new token (classic)
3. Scopes: ✅ `repo`, ✅ `admin:repo_hook`
4. Copy token (save it securely!)

### Step 4: Configure Jenkins Kubernetes Cloud

**Manage Jenkins → Manage Nodes and Clouds → Configure Clouds → Add Kubernetes**

```yaml
Name: kubernetes
Kubernetes URL: https://your-k8s-api:6443
Namespace: jenkins
Credentials: [K8s token]
Jenkins URL: http://jenkins.jenkins.svc.cluster.local:8080
```

Create K8s service account:
```bash
kubectl create namespace jenkins
kubectl create serviceaccount jenkins -n jenkins
kubectl create clusterrolebinding jenkins-admin \
  --clusterrole=cluster-admin \
  --serviceaccount=jenkins:jenkins
```

### Step 5: Add GitHub Credentials in Jenkins

**Manage Jenkins → Manage Credentials → Global → Add Credentials**

- Kind: `Username with password`
- Username: Your GitHub username
- Password: GitHub Personal Access Token
- ID: `github-token`

### Step 6: Create Multi-Branch Pipeline Job

**IMPORTANT: Select "Multibranch Pipeline", NOT "Pipeline"**

1. Jenkins → **New Item**
2. Name: `maven-multi-project`
3. Type: **Multibranch Pipeline** ✅
4. Click **OK**

### Step 7: Configure Branch Sources

**Branch Sources → Add source → GitHub**

```
Credentials: [Select: github-token]
Repository HTTPS URL: https://github.com/your-org/your-repo
```

**Behaviors (click Add):**
- ✅ Discover branches (Strategy: All branches)
- ✅ Discover pull requests from origin
- ✅ Filter by name: Include `main develop release/* hotfix/*`

**Build Configuration:**
- Mode: `by Jenkinsfile`
- Script Path: `Jenkinsfile`

**Scan Multibranch Pipeline Triggers:**
- ✅ Periodically if not otherwise run: `1 minute`

**Orphaned Item Strategy:**
- Days to keep: `7`
- Max # to keep: `10`

### Step 8: Save and Scan

Click **Save** → Jenkins automatically scans and discovers all branches!

---

## 📝 Jenkinsfile (Complete)

Create this `Jenkinsfile` in your repository root:

```groovy
pipeline {
  agent {
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: maven
    image: maven:3.9-eclipse-temurin-17
    command: ['cat']
    tty: true
    resources:
      requests:
        memory: "1Gi"
        cpu: "500m"
      limits:
        memory: "2Gi"
        cpu: "1000m"
    volumeMounts:
    - name: maven-cache
      mountPath: /root/.m2
  volumes:
  - name: maven-cache
    emptyDir: {}
"""
      defaultContainer 'maven'
    }
  }

  parameters {
    choice(name: 'PROJECTS', choices: ['auto', 'all', 'project-a', 'project-b', 'project-c'], 
           description: 'Projects to build (auto = only changed)')
    booleanParam(name: 'SKIP_TESTS', defaultValue: false, description: 'Skip tests')
  }

  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '10'))
    timeout(time: 30, unit: 'MINUTES')
  }

  stages {
    stage('Initialize') {
      steps {
        script {
          echo "Branch: ${env.BRANCH_NAME}"
          echo "Build: #${env.BUILD_NUMBER}"
          if (env.CHANGE_ID) {
            echo "PR: #${env.CHANGE_ID} → ${env.CHANGE_TARGET}"
          }
        }
      }
    }

    stage('Determine Environment') {
      steps {
        script {
          def branch = env.BRANCH_NAME
          def environment = 'dev'
          
          if (branch == 'main' || branch == 'master') {
            environment = 'prod'
          } else if (branch == 'develop') {
            environment = 'dev'
          } else if (branch.startsWith('release/')) {
            environment = 'qa'
          } else if (branch.startsWith('hotfix/')) {
            environment = 'prod'
          } else if (env.CHANGE_ID) {
            environment = 'test'
          }
          
          env.DEPLOY_ENV = environment
          echo "Environment: ${environment}"
        }
      }
    }

    stage('Detect Changed Projects') {
      steps {
        script {
          def changedFiles = []
          try {
            if (env.CHANGE_ID) {
              changedFiles = sh(script: "git diff --name-only origin/${env.CHANGE_TARGET}...HEAD", 
                               returnStdout: true).trim().split('\n') as List
            } else {
              changedFiles = sh(script: "git diff --name-only HEAD~1..HEAD 2>/dev/null || echo ''", 
                               returnStdout: true).trim().split('\n') as List
            }
          } catch (Exception e) {
            changedFiles = []
          }
          
          def autoList = []
          if (changedFiles.any { it.startsWith('project-a/') }) autoList << 'project-a'
          if (changedFiles.any { it.startsWith('project-b/') }) autoList << 'project-b'
          if (changedFiles.any { it.startsWith('project-c/') }) autoList << 'project-c'
          if (changedFiles.any { it == 'Jenkinsfile' }) autoList = ['project-a', 'project-b', 'project-c']
          
          if (params.PROJECTS == 'all') {
            env.PROJECT_LIST = 'project-a project-b project-c'
          } else if (params.PROJECTS == 'auto') {
            env.PROJECT_LIST = autoList.isEmpty() ? 'none' : autoList.join(' ')
          } else {
            env.PROJECT_LIST = params.PROJECTS
          }
          
          echo "Projects to build: ${env.PROJECT_LIST}"
        }
      }
    }

    stage('Abort if Nothing') {
      when { expression { env.PROJECT_LIST == 'none' } }
      steps {
        script {
          currentBuild.result = 'ABORTED'
          error("No changes detected")
        }
      }
    }

    stage('Maven Build') {
      when { expression { env.PROJECT_LIST != 'none' } }
      steps {
        script {
          def projects = env.PROJECT_LIST.split(' ') as List
          def skipTests = params.SKIP_TESTS ? '-DskipTests' : ''
          
          for (proj in projects) {
            echo "Building ${proj} for ${env.DEPLOY_ENV}..."
            sh """
              mvn -B -f ${proj}/pom.xml clean package assembly:single \
                ${skipTests} \
                -Dbuild.env=${env.DEPLOY_ENV} \
                -Dbuild.branch=${env.BRANCH_NAME} \
                -Dbuild.number=${env.BUILD_NUMBER}
            """
          }
        }
      }
    }

    stage('Archive') {
      when { expression { env.PROJECT_LIST != 'none' } }
      steps {
        archiveArtifacts artifacts: '*/target/*.jar', fingerprint: true, allowEmptyArchive: true
      }
    }
  }

  post {
    success { echo "✓ Build succeeded" }
    failure { echo "✗ Build failed" }
    always { cleanWs() }
  }
}
```

---

## 🔧 Maven Configuration

### pom.xml for Each Project

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>com.example</groupId>
  <artifactId>project-a</artifactId>
  <version>1.0.0</version>

  <properties>
    <maven.compiler.source>17</maven.compiler.source>
    <maven.compiler.target>17</maven.compiler.target>
    <build.env>dev</build.env>
    <build.branch>unknown</build.branch>
    <build.number>0</build.number>
  </properties>

  <build>
    <finalName>${project.artifactId}-${project.version}-${build.env}</finalName>
    
    <resources>
      <resource>
        <directory>src/main/resources</directory>
        <filtering>true</filtering>
      </resource>
    </resources>

    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-assembly-plugin</artifactId>
        <version>3.6.0</version>
        <configuration>
          <descriptorRefs>
            <descriptorRef>jar-with-dependencies</descriptorRef>
          </descriptorRefs>
          <finalName>${project.artifactId}-${project.version}-${build.env}</finalName>
          <appendAssemblyId>false</appendAssemblyId>
          <archive>
            <manifestEntries>
              <Build-Environment>${build.env}</Build-Environment>
              <Build-Branch>${build.branch}</Build-Branch>
              <Build-Number>${build.number}</Build-Number>
            </manifestEntries>
          </archive>
        </configuration>
        <executions>
          <execution>
            <phase>package</phase>
            <goals>
              <goal>single</goal>
            </goals>
          </execution>
        </executions>
      </plugin>
    </plugins>
  </build>
</project>
```

### application.properties

```properties
app.name=${project.artifactId}
app.version=${project.version}
app.environment=${build.env}
app.branch=${build.branch}
app.build=${build.number}

database.url=jdbc:mysql://db-${build.env}.example.com:3306/mydb
api.url=https://api-${build.env}.example.com
```

---

## 🌿 Branch Strategy

### Branch-to-Environment Mapping

| Branch | Environment | Use Case |
|--------|-------------|----------|
| `main` | `prod` | Production releases |
| `develop` | `dev` | Development |
| `release/*` | `qa` | QA/Staging |
| `hotfix/*` | `prod` | Emergency fixes |
| `feature/*` | `dev` | New features |
| `PR-*` | `test` | Pull request testing |

### Workflow Example

```bash
# 1. Create feature branch
git checkout develop
git checkout -b feature/new-feature
# ... make changes ...
git push origin feature/new-feature
# Jenkins auto-builds with dev environment

# 2. Create Pull Request
# GitHub: feature/new-feature → develop
# Jenkins auto-builds PR with test environment

# 3. Merge to develop
# Jenkins auto-builds develop with dev environment

# 4. Create release
git checkout -b release/v1.0
git push origin release/v1.0
# Jenkins auto-builds with qa environment

# 5. Merge to main
git checkout main
git merge release/v1.0
git push origin main
# Jenkins auto-builds with prod environment
```

---

## 🧪 Testing

### 1. Verify Branch Discovery

After creating the job, check:
```
Jenkins → maven-multi-project
  ├── main
  ├── develop
  └── release/v1.0
```

### 2. Test Branch Build

```bash
git checkout develop
echo "test" >> README.md
git commit -am "test: trigger build"
git push origin develop
```

Check Jenkins → maven-multi-project → develop → Latest build

### 3. Test PR Build

```bash
git checkout -b feature/test
echo "test" >> README.md
git push origin feature/test
```

Create PR in GitHub → Jenkins creates PR-X job automatically

### 4. Verify Environment Detection

Check console output:
- main → prod ✓
- develop → dev ✓
- release/v1 → qa ✓
- PR-123 → test ✓

---

## 🔍 Troubleshooting

### Branches Not Discovered

**Check:**
1. Scan log: Job → Scan Multibranch Pipeline Log
2. GitHub credentials valid
3. Repository URL correct (HTTPS, not SSH)
4. Jenkinsfile exists in repo root

**Fix:**
```bash
# Manual scan
Jenkins → maven-multi-project → Scan Multibranch Pipeline Now
```

### Webhook Not Working

**Check:**
1. GitHub → Settings → Webhooks → Recent Deliveries
2. Webhook URL: `http://jenkins-url/github-webhook/`
3. Jenkins accessible from GitHub

**Fix:**
```bash
# Test webhook
curl -X POST http://your-jenkins-url/github-webhook/
```

### PR Builds Not Working

**Check:**
1. Branch Source → Behaviors → "Discover pull requests" enabled
2. GitHub token has `repo` scope
3. Webhook includes "Pull requests" event

### Environment Wrong

**Debug in Jenkinsfile:**
```groovy
echo "BRANCH_NAME: ${env.BRANCH_NAME}"
echo "CHANGE_ID: ${env.CHANGE_ID}"
echo "CHANGE_TARGET: ${env.CHANGE_TARGET}"
```

---

## ✅ Best Practices

### 1. Branch Protection

GitHub → Settings → Branches → Add rule:
- ✅ Require pull request reviews
- ✅ Require status checks (Jenkins build)
- ✅ Require branches up to date

### 2. Cleanup Strategy

Configure orphaned item strategy:
- Days to keep: 7
- Max to keep: 10

### 3. Resource Management

Set appropriate K8s limits:
```yaml
resources:
  requests:
    memory: "1Gi"
    cpu: "500m"
  limits:
    memory: "2Gi"
    cpu: "1000m"
```

### 4. Build Optimization

- Use Maven cache volume
- Skip tests in CI (run separately)
- Build only changed projects
- Set build timeouts

---

## 📊 Comparison Summary

### Before (Regular Pipeline)

```
❌ Manual job creation for each branch
❌ No PR support
❌ Manual cleanup
❌ Difficult to scale
❌ Separate configurations
```

### After (Multi-Branch Pipeline)

```
✅ Automatic branch discovery
✅ Automatic PR builds
✅ Automatic cleanup
✅ Easy to scale
✅ Single configuration
✅ Branch-specific environments
✅ Better organization
```

---

## 🎯 Key Takeaways

1. **Multi-Branch Pipeline** is superior for projects with multiple branches
2. **Automatic discovery** eliminates manual job creation
3. **PR builds** ensure code quality before merging
4. **Branch-based environments** (main=prod, develop=dev, release=qa)
5. **Kubernetes pods** provide isolated build environments
6. **Selective building** saves time by building only changed projects

---

## 📚 Additional Resources

- [Jenkins Multi-Branch Pipeline](https://www.jenkins.io/doc/book/pipeline/multibranch/)
- [GitHub Branch Source Plugin](https://plugins.jenkins.io/github-branch-source/)
- [Kubernetes Plugin](https://plugins.jenkins.io/kubernetes/)
- [Maven Assembly Plugin](https://maven.apache.org/plugins/maven-assembly-plugin/)

---

**Version:** 1.0.0  
**Last Updated:** 2026-03-02  
**Author:** DevOps Team




# Local Jenkins Multi-Branch Pipeline with Kind on Linux
## Complete Setup Guide for GitHub → Jenkins → Kind Cluster → Maven Builds

---

## 🎯 What This Guide Does

Sets up a **complete CI/CD pipeline on your Linux machine** using:
- ✅ **Kind** (Kubernetes in Docker) - Local K8s cluster
- ✅ **Jenkins** - Running as a pod in Kind cluster
- ✅ **Multi-Branch Pipeline** - Auto-discovers GitHub branches
- ✅ **Maven Build Pods** - Spawned dynamically in same cluster
- ✅ **GitHub Integration** - Webhook triggers (via ngrok)

**Everything runs locally on your Linux machine - NO cloud required!**

---

## 📋 Prerequisites

### System Requirements
- **OS**: Linux (Ubuntu 20.04+, Debian, CentOS, etc.)
- **RAM**: 8GB minimum (16GB recommended)
- **CPU**: 4 cores recommended
- **Disk**: 50GB free space
- **Internet**: Required for downloads

### Required Software
- Docker
- kubectl
- Kind
- Helm
- Git
- ngrok (for GitHub webhooks)

---

## 🚀 Step-by-Step Installation

### Step 1: Install Docker

```bash
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

### Step 2: Install kubectl

```bash
# Download kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Make it executable
chmod +x kubectl

# Move to PATH
sudo mv kubectl /usr/local/bin/

# Verify installation
kubectl version --client
```

### Step 3: Install Kind

```bash
# Download Kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64

# Make it executable
chmod +x ./kind

# Move to PATH
sudo mv ./kind /usr/local/bin/kind

# Verify installation
kind --version
```

### Step 4: Install Helm

```bash
# Download Helm installation script
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verify installation
helm version
```

### Step 5: Install ngrok (for GitHub webhooks)

```bash
# Download ngrok
curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | \
  sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null && \
  echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | \
  sudo tee /etc/apt/sources.list.d/ngrok.list && \
  sudo apt update && sudo apt install ngrok

# Sign up at https://ngrok.com and get auth token
# Configure ngrok with your token
ngrok config add-authtoken YOUR_NGROK_TOKEN

# Verify installation
ngrok --version
```

---

## 🏗️ Create Kind Cluster with Jenkins

### Step 1: Create Kind Cluster Configuration

```bash
# Create a directory for configs
mkdir -p ~/jenkins-kind
cd ~/jenkins-kind

# Create Kind cluster config file
cat <<EOF > kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: jenkins-cluster
nodes:
- role: control-plane
  extraPortMappings:
  # Jenkins UI
  - containerPort: 30000
    hostPort: 8080
    protocol: TCP
  # Jenkins Agent
  - containerPort: 30001
    hostPort: 50000
    protocol: TCP
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
EOF
```

### Step 2: Create Kind Cluster

```bash
# Create cluster
kind create cluster --config kind-config.yaml

# Verify cluster is running
kubectl cluster-info --context kind-jenkins-cluster
kubectl get nodes

# Expected output:
# NAME                            STATUS   ROLES           AGE   VERSION
# jenkins-cluster-control-plane   Ready    control-plane   1m    v1.27.3

root@kind-ubuntu:~/jenkins-kind# ls
kind-config.yaml
root@kind-ubuntu:~/jenkins-kind# kind create cluster --config kind-config.yaml
Creating cluster "jenkins-cluster" ...
 ✓ Ensuring node image (kindest/node:v1.27.3) 🖼 
 ✓ Preparing nodes 📦  
 ✓ Writing configuration 📜 
 ✓ Starting control-plane 🕹️ 
 ✓ Installing CNI 🔌 
 ✓ Installing StorageClass 💾 
Set kubectl context to "kind-jenkins-cluster"
You can now use your cluster with:

kubectl cluster-info --context kind-jenkins-cluster

root@kind-ubuntu:~/jenkins-kind# kubectl cluster-info --context kind-jenkins-cluster
Kubernetes control plane is running at https://127.0.0.1:40621
CoreDNS is running at https://127.0.0.1:40621/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

### Step 3: Create Jenkins Namespace and Service Account

```bash
# Create namespace
kubectl create namespace jenkins

# Create service account
Helm manages everything
```

### Step 4: Create Jenkins Values File

```bash
# Create Helm values file for Jenkins
# Update jenkins-values.yaml to let Helm create it
cat <<EOF > jenkins-values.yaml
controller:
  serviceType: NodePort
  nodePort: 30000
  
  # Let Helm create and manage the service account
  serviceAccount:
    create: true
    name: jenkins
  
  admin:
    username: "admin"
  
  installPlugins:
    - kubernetes:latest
    - workflow-aggregator:latest
    - git:latest
    - configuration-as-code:latest
    - github-branch-source:latest
    - pipeline-stage-view:latest
    - credentials-binding:latest
    - github:latest
  
  resources:
    requests:
      cpu: "1000m"
      memory: "2Gi"
    limits:
      cpu: "2000m"
      memory: "4Gi"
  
  javaOpts: "-Xms2g -Xmx2g"
  
  JCasC:
    defaultConfig: true

agent:
  enabled: false

persistence:
  enabled: false

# RBAC settings
rbac:
  create: true
  readSecrets: true
EOF
```

### Step 5: Install Jenkins using Helm

```bash
# Add Jenkins Helm repository
helm repo add jenkins https://charts.jenkins.io
helm repo update

# Install Jenkins
helm install jenkins jenkins/jenkins \
  --namespace jenkins \
  --values jenkins-values.yaml \
  --wait \
  --timeout 10m

# Wait for Jenkins to be ready (may take 2-3 minutes)
kubectl wait --for=condition=ready pod -l app.kubernetes.io/component=jenkins-controller -n jenkins --timeout=600s

# Check Jenkins pod status
kubectl get pods -n jenkins

# Expected output:
# NAME        READY   STATUS    RESTARTS   AGE
# jenkins-0   2/2     Running   0          2m




root@kind-ubuntu:~/jenkins-kind# helm install jenkins jenkins/jenkins \
  --namespace jenkins \
  --values jenkins-values.yaml \
  --wait \
  --timeout 10m

NAME: jenkins
LAST DEPLOYED: Mon Mar  2 10:21:57 2026
NAMESPACE: jenkins
STATUS: deployed
REVISION: 1
NOTES:
1. Get your 'admin' user password by running:
  kubectl exec --namespace jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo
2. Get the Jenkins URL to visit by running these commands in the same shell:
  export NODE_PORT=$(kubectl get --namespace jenkins -o jsonpath="{.spec.ports[0].nodePort}" services jenkins)
  export NODE_IP=$(kubectl get nodes --namespace jenkins -o jsonpath="{.items[0].status.addresses[0].address}")
  echo http://$NODE_IP:$NODE_PORT

3. Login with the password from step 1 and the username: admin
4. Configure security realm and authorization strategy
5. Use Jenkins Configuration as Code by specifying configScripts in your values.yaml file, see documentation: http://$NODE_IP:$NODE_PORT/configuration-as-code and examples: https://github.com/jenkinsci/configuration-as-code-plugin/tree/master/demos

For more information on running Jenkins on Kubernetes, visit:
https://cloud.google.com/solutions/jenkins-on-container-engine

For more information about Jenkins Configuration as Code, visit:
https://jenkins.io/projects/jcasc/


NOTE: Consider using a custom image with pre-installed plugins
#################################################################################
######   WARNING: Persistence is disabled!!! You will lose your data when   #####
######            the Jenkins pod is terminated.                            #####
#################################################################################
root@kind-ubuntu:~/jenkins-kind# kubectl get pods
No resources found in default namespace.
root@kind-ubuntu:~/jenkins-kind# kubectl get pods -n jenkins
NAME        READY   STATUS    RESTARTS   AGE
jenkins-0   2/2     Running   0          5m22s
root@kind-ubuntu:~/jenkins-kind# kubectl exec --namespace jenkins -it svc/jenkins -c jenkins -- \
  /bin/cat /run/secrets/additional/chart-admin-password && echo
OrtmOKSZIssu4jecrJU
```

### Step 6: Get Jenkins Admin Password

```bash
# Get admin password
kubectl exec -n jenkins -it svc/jenkins -c jenkins -- \
  cat /run/secrets/additional/chart-admin-password

# Save this password - you'll need it to login
```

### Step 7: Access Jenkins UI

```bash
# Jenkins is now accessible at:
# http://localhost:8080

# Open in browser
xdg-open http://localhost:8080

# Login with:
# Username: admin
# Password: (from previous step)
```

---

## 🔧 Configure Jenkins

### Step 1: Configure Kubernetes Cloud

1. **Login to Jenkins** at http://localhost:8080

2. **Manage Jenkins** → **Manage Nodes and Clouds** → **Configure Clouds**

3. Click **Add a new cloud** → **Kubernetes**

4. Configure:
   ```
   Name: kubernetes
   
   Kubernetes URL: https://kubernetes.default.svc.cluster.local
   (Leave empty - uses in-cluster config)
   
   Kubernetes Namespace: jenkins
   
   Credentials: (None - uses service account)
   
   Jenkins URL: http://jenkins.jenkins.svc.cluster.local:8080
   
   Jenkins tunnel: jenkins-agent.jenkins.svc.cluster.local:50000
   ```

5. Click **Test Connection**
   - Should show: "Connected to Kubernetes v1.27.3"

6. **Save**

### Step 2: Install Additional Plugins

**Manage Jenkins** → **Manage Plugins** → **Available**

Search and install:
- ✅ GitHub Branch Source Plugin
- ✅ Pipeline: Multibranch
- ✅ Kubernetes Plugin (should already be installed)

Click **Install without restart**

---

## 🌐 Setup GitHub Webhook with ngrok

### Step 1: Start ngrok

```bash
# In a new terminal, start ngrok
ngrok http 8080

# You'll see output like:
# Forwarding  https://abc123.ngrok.io -> http://localhost:8080
```

**Keep this terminal open!** Copy the `https://abc123.ngrok.io` URL.

### Step 2: Configure GitHub Webhook

1. Go to your GitHub repository
2. **Settings** → **Webhooks** → **Add webhook**
3. Configure:
   ```
   Payload URL: https://abc123.ngrok.io/github-webhook/
   Content type: application/json
   Secret: (leave empty for testing)
   SSL verification: Enable
   Events: Just the push event
   Active: ✓
   ```
4. Click **Add webhook**
5. Check **Recent Deliveries** - should show green checkmark

---

## 📁 Setup Your Repository

### Step 1: Create Repository Structure

```bash
# Clone your repository
git clone https://github.com/your-org/your-repo.git
cd your-repo

# Create project structure
mkdir -p project-a/src/main/{java/com/example,resources}
mkdir -p project-b/src/main/{java/com/example,resources}
mkdir -p project-c/src/main/{java/com/example,resources}
```

### Step 2: Create Jenkinsfile

```bash
cat <<'EOF' > Jenkinsfile
pipeline {
  agent {
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: maven
    image: maven:3.9-eclipse-temurin-17
    command: ['cat']
    tty: true
    resources:
      requests:
        memory: "1Gi"
        cpu: "500m"
      limits:
        memory: "2Gi"
        cpu: "1000m"
    volumeMounts:
    - name: maven-cache
      mountPath: /root/.m2
  volumes:
  - name: maven-cache
    emptyDir: {}
"""
      defaultContainer 'maven'
    }
  }

  parameters {
    choice(name: 'PROJECTS', choices: ['auto', 'all', 'project-a', 'project-b', 'project-c'], 
           description: 'Projects to build')
    booleanParam(name: 'SKIP_TESTS', defaultValue: false, description: 'Skip tests')
  }

  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '10'))
    timeout(time: 30, unit: 'MINUTES')
  }

  stages {
    stage('Initialize') {
      steps {
        script {
          echo "Branch: ${env.BRANCH_NAME}"
          echo "Build: #${env.BUILD_NUMBER}"
        }
      }
    }

    stage('Determine Environment') {
      steps {
        script {
          def branch = env.BRANCH_NAME
          def environment = 'dev'
          
          if (branch == 'main') environment = 'prod'
          else if (branch == 'develop') environment = 'dev'
          else if (branch.startsWith('release/')) environment = 'qa'
          else if (env.CHANGE_ID) environment = 'test'
          
          env.DEPLOY_ENV = environment
          echo "Environment: ${environment}"
        }
      }
    }

    stage('Detect Changed Projects') {
      steps {
        script {
          def changedFiles = []
          try {
            if (env.CHANGE_ID) {
              changedFiles = sh(script: "git diff --name-only origin/${env.CHANGE_TARGET}...HEAD", 
                               returnStdout: true).trim().split('\n') as List
            } else {
              changedFiles = sh(script: "git diff --name-only HEAD~1..HEAD 2>/dev/null || echo ''", 
                               returnStdout: true).trim().split('\n') as List
            }
          } catch (Exception e) {
            changedFiles = []
          }
          
          def autoList = []
          if (changedFiles.any { it.startsWith('project-a/') }) autoList << 'project-a'
          if (changedFiles.any { it.startsWith('project-b/') }) autoList << 'project-b'
          if (changedFiles.any { it.startsWith('project-c/') }) autoList << 'project-c'
          
          if (params.PROJECTS == 'all') {
            env.PROJECT_LIST = 'project-a project-b project-c'
          } else if (params.PROJECTS == 'auto') {
            env.PROJECT_LIST = autoList.isEmpty() ? 'none' : autoList.join(' ')
          } else {
            env.PROJECT_LIST = params.PROJECTS
          }
          
          echo "Projects: ${env.PROJECT_LIST}"
        }
      }
    }

    stage('Maven Build') {
      when { expression { env.PROJECT_LIST != 'none' } }
      steps {
        script {
          def projects = env.PROJECT_LIST.split(' ') as List
          def skipTests = params.SKIP_TESTS ? '-DskipTests' : ''
          
          for (proj in projects) {
            echo "Building ${proj}..."
            sh """
              mvn -B -f ${proj}/pom.xml clean package assembly:single \
                ${skipTests} \
                -Dbuild.env=${env.DEPLOY_ENV} \
                -Dbuild.branch=${env.BRANCH_NAME}
            """
          }
        }
      }
    }

    stage('Archive') {
      when { expression { env.PROJECT_LIST != 'none' } }
      steps {
        archiveArtifacts artifacts: '*/target/*.jar', fingerprint: true
      }
    }
  }

  post {
    success { echo "✓ Build succeeded" }
    failure { echo "✗ Build failed" }
    always { cleanWs() }
  }
}
EOF
```

### Step 3: Create pom.xml for Each Project

```bash
# Create pom.xml for project-a
cat <<'EOF' > project-a/pom.xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>com.example</groupId>
  <artifactId>project-a</artifactId>
  <version>1.0.0</version>

  <properties>
    <maven.compiler.source>17</maven.compiler.source>
    <maven.compiler.target>17</maven.compiler.target>
    <build.env>dev</build.env>
    <build.branch>unknown</build.branch>
  </properties>

  <build>
    <finalName>${project.artifactId}-${project.version}-${build.env}</finalName>
    
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-assembly-plugin</artifactId>
        <version>3.6.0</version>
        <configuration>
          <descriptorRefs>
            <descriptorRef>jar-with-dependencies</descriptorRef>
          </descriptorRefs>
          <finalName>${project.artifactId}-${project.version}-${build.env}</finalName>
          <appendAssemblyId>false</appendAssemblyId>
        </configuration>
        <executions>
          <execution>
            <phase>package</phase>
            <goals>
              <goal>single</goal>
            </goals>
          </execution>
        </executions>
      </plugin>
    </plugins>
  </build>
</project>
EOF

# Copy for project-b and project-c (change artifactId)
sed 's/project-a/project-b/g' project-a/pom.xml > project-b/pom.xml
sed 's/project-a/project-c/g' project-a/pom.xml > project-c/pom.xml
```

### Step 4: Create Sample Java Files

```bash
# Create Main.java for project-a
cat <<'EOF' > project-a/src/main/java/com/example/Main.java
package com.example;

public class Main {
    public static void main(String[] args) {
        System.out.println("Project A - Hello from Kind Cluster!");
    }
}
EOF

# Copy for other projects
sed 's/Project A/Project B/g' project-a/src/main/java/com/example/Main.java > project-b/src/main/java/com/example/Main.java
sed 's/Project A/Project C/g' project-a/src/main/java/com/example/Main.java > project-c/src/main/java/com/example/Main.java
```

### Step 5: Create Branches and Push

```bash
# Initialize git (if not already)
git init
git add .
git commit -m "Initial commit: Multi-branch pipeline setup"

# Create and push main branch
git branch -M main
git remote add origin https://github.com/your-org/your-repo.git
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

## 🎯 Create Jenkins Multi-Branch Pipeline Job

### Step 1: Create Job

1. **Jenkins Dashboard** → **New Item**
2. Name: `maven-multi-project`
3. Type: **Multibranch Pipeline**
4. Click **OK**

### Step 2: Configure Branch Sources

**Branch Sources** → **Add source** → **GitHub**

1. **Credentials**: Click **Add** → **Jenkins**
   - Kind: `Username with password`
   - Username: Your GitHub username
   - Password: GitHub Personal Access Token
   - ID: `github-token`
   - Click **Add**

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

### Step 3: Save and Scan

Click **Save** → Jenkins will automatically scan and discover branches!

---

## ✅ Test the Setup

### Test 1: Verify Branch Discovery

```bash
# Check Jenkins UI
# You should see:
# maven-multi-project/
#   ├── main
#   ├── develop
#   └── release/v1.0
```

### Test 2: Trigger Manual Build

1. Click on `maven-multi-project` → `develop`
2. Click **Build Now**
3. Watch console output

### Test 3: Watch Kubernetes Pods

```bash
# In terminal, watch pods being created
kubectl get pods -n jenkins -w

# You'll see:
# jenkins-0                           2/2   Running
# maven-multi-project-develop-1-xxx   0/1   Pending
# maven-multi-project-develop-1-xxx   1/1   Running
# maven-multi-project-develop-1-xxx   0/1   Completed
```

### Test 4: Trigger Build via Git Push

```bash
# Make a change
git checkout develop
echo "test" >> README.md
git add .
git commit -m "test: trigger build"
git push origin develop

# Jenkins should automatically build within 1 minute
# Check Jenkins UI for new build
```

### Test 5: Create Pull Request

```bash
# Create feature branch
git checkout -b feature/test
echo "feature test" >> README.md
git add .
git commit -m "feat: test PR build"
git push origin feature/test

# Create PR in GitHub: feature/test → develop
# Jenkins should automatically create PR-X job and build
```

---

## 🔍 Monitoring and Debugging

### View Jenkins Logs

```bash
# View Jenkins controller logs
kubectl logs -f jenkins-0 -n jenkins -c jenkins

# View build pod logs (while running)
kubectl logs -f <pod-name> -n jenkins
```

### View All Pods

```bash
# List all pods in jenkins namespace
kubectl get pods -n jenkins

# Describe a pod
kubectl describe pod <pod-name> -n jenkins

# Get pod events
kubectl get events -n jenkins --sort-by='.lastTimestamp'
```

### Access Jenkins Pod Shell

```bash
# Exec into Jenkins pod
kubectl exec -it jenkins-0 -n jenkins -c jenkins -- /bin/bash

# Inside pod, check Jenkins home
ls -la /var/jenkins_home/
```

### Check Cluster Resources

```bash
# Check node resources
kubectl top nodes

# Check pod resources
kubectl top pods -n jenkins

# Check cluster info
kubectl cluster-info
```

---

## 🛠️ Troubleshooting

### Issue: Build Pod Stuck in Pending

```bash
# Check pod status
kubectl describe pod <pod-name> -n jenkins

# Common causes:
# 1. Insufficient resources
# 2. Image pull issues
# 3. Node selector issues

# Solution: Check events
kubectl get events -n jenkins | grep <pod-name>
```

### Issue: Jenkins Can't Spawn Pods

```bash
# Check service account permissions
kubectl get clusterrolebinding jenkins-admin

# Verify service account
kubectl get sa jenkins -n jenkins

# Check Jenkins logs
kubectl logs jenkins-0 -n jenkins -c jenkins | grep -i kubernetes
```

### Issue: GitHub Webhook Not Working

```bash
# Check ngrok is running
curl http://localhost:4040/api/tunnels

# Check webhook deliveries in GitHub
# Settings → Webhooks → Recent Deliveries

# Test webhook manually
curl -X POST https://your-ngrok-url.ngrok.io/github-webhook/
```

### Issue: Maven Build Fails

```bash
# Check build pod logs
kubectl logs <build-pod-name> -n jenkins

# Common issues:
# 1. Java version mismatch
# 2. Maven dependencies not downloading
# 3. Insufficient memory

# Solution: Increase pod resources in Jenkinsfile
```

---

## 🧹 Cleanup

### Delete Everything

```bash
# Delete Jenkins
helm uninstall jenkins -n jenkins

# Delete namespace
kubectl delete namespace jenkins

# Delete Kind cluster
kind delete cluster --name jenkins-cluster

# Stop ngrok
# Press Ctrl+C in ngrok terminal
```

### Start Fresh

```bash
# Recreate cluster
kind create cluster --config kind-config.yaml

# Reinstall Jenkins
helm install jenkins jenkins/jenkins -n jenkins --values jenkins-values.yaml
```

---

## 📊 Resource Usage

### Typical Resource Consumption

```
Jenkins Controller Pod:  2GB RAM, 1 CPU
Maven Build Pod:         1-2GB RAM, 0.5-1 CPU
Kind Cluster Overhead:   1GB RAM, 0.5 CPU
-------------------------------------------
Total (idle):            ~4GB RAM, 2 CPU
Total (building):        ~6-8GB RAM, 3-4 CPU
```

### Optimize for Low Resources

If you have limited resources, modify `jenkins-values.yaml`:

```yaml
controller:
  resources:
    requests:
      cpu: "500m"
      memory: "1Gi"
    limits:
      cpu: "1000m"
      memory: "2Gi"
```

And in Jenkinsfile, reduce build pod resources:

```yaml
resources:
  requests:
    memory: "512Mi"
    cpu: "250m"
  limits:
    memory: "1Gi"
    cpu: "500m"
```

---

## 🎓 Next Steps

1. ✅ **Add more projects** to your repository
2. ✅ **Create more branches** (feature/, bugfix/, etc.)
3. ✅ **Test PR builds** by creating pull requests
4. ✅ **Add tests** to your Maven projects
5. ✅ **Configure notifications** (Slack, email)
6. ✅ **Add deployment stages** (deploy to test/prod)
7. ✅ **Explore Jenkins plugins** (SonarQube, Artifactory, etc.)

---

## 📚 Useful Commands Reference

```bash
# Kind Cluster
kind create cluster --config kind-config.yaml
kind get clusters
kind delete cluster --name jenkins-cluster

# Kubernetes
kubectl get pods -n jenkins
kubectl get all -n jenkins
kubectl logs -f <pod-name> -n jenkins
kubectl describe pod <pod-name> -n jenkins
kubectl exec -it <pod-name> -n jenkins -- /bin/bash

# Jenkins
helm list -n jenkins
helm status jenkins -n jenkins
helm upgrade jenkins jenkins/jenkins -n jenkins --values jenkins-values.yaml

# ngrok
ngrok http 8080
curl http://localhost:4040/api/tunnels

# Docker
docker ps
docker stats
docker system df
```

---

## ✅ Summary

You now have:
- ✅ Local Kind Kubernetes cluster
- ✅ Jenkins running as a pod in the cluster
- ✅ Multi-Branch Pipeline configured
- ✅ Automatic branch discovery
- ✅ Dynamic Maven build pods
- ✅ GitHub webhook integration
- ✅ Environment-based builds (dev/qa/prod)

**Everything runs locally on your Linux machine!**

---

## 🆘 Getting Help

If you encounter issues:

1. Check Jenkins logs: `kubectl logs jenkins-0 -n jenkins -c jenkins`
2. Check build pod logs: `kubectl logs <pod-name> -n jenkins`
3. Check Kind cluster: `kubectl get nodes`
4. Check GitHub webhook deliveries
5. Verify ngrok is running: `curl http://localhost:4040/api/tunnels`

---

**Version:** 1.0.0  
**Last Updated:** 2026-03-02  
**Platform:** Linux  
**Author:** DevOps Team





# Jenkins Multi-Branch Pipeline on K3s (Linux)
## Complete Setup Guide with Internet Access

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

### One-Command Installation

```bash
# Complete setup in one command
curl -sfL https://get.k3s.io | sh - && \
sleep 10 && \
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml && \
kubectl create namespace jenkins && \
helm repo add jenkins https://charts.jenkins.io && \
helm repo update && \
cat <<EOF > jenkins-values.yaml
controller:
  serviceType: NodePort
  nodePort: 30000
  admin:
    username: "admin"
  installPlugins:
    - kubernetes:latest
    - workflow-aggregator:latest
    - git:latest
    - github-branch-source:latest
  resources:
    requests:
      cpu: "500m"
      memory: "1Gi"
    limits:
      cpu: "1000m"
      memory: "1.5Gi"
  javaOpts: "-Xms512m -Xmx1g"
  JCasC:
    defaultConfig: true
agent:
  enabled: false
persistence:
  enabled: false
rbac:
  create: true
EOF
helm install jenkins jenkins/jenkins --namespace jenkins --values jenkins-values.yaml && \
echo "Waiting for Jenkins..." && \
kubectl wait --for=condition=ready pod/jenkins-0 -n jenkins --timeout=600s && \
echo "" && \
echo "=== Jenkins Ready! ===" && \
echo "Password: $(kubectl exec -n jenkins -it svc/jenkins -c jenkins -- cat /run/secrets/additional/chart-admin-password)" && \
echo "URL: http://localhost:30000"
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
# SSH with port forwarding in one command
ssh -i fyre.pem -L 30000:localhost:30000 root@kind-ubuntu.dev.fyre.ibm.com \
  "kubectl port-forward -n jenkins svc/jenkins 30000:8080 --address=127.0.0.1"

# This will:
# 1. SSH to Fyre VM
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
# Clone your repository
git clone https://github.com/your-org/your-repo.git
cd your-repo

# Create project structure
mkdir -p project-a/src/main/{java/com/example,resources}
mkdir -p project-b/src/main/{java/com/example,resources}
mkdir -p project-c/src/main/{java/com/example,resources}
```

### Step 2: Create Jenkinsfile

```bash
cat <<'EOF' > Jenkinsfile
pipeline {
  agent {
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: maven
    image: maven:3.9-eclipse-temurin-17
    command: ['cat']
    tty: true
    resources:
      requests:
        memory: "512Mi"
        cpu: "250m"
      limits:
        memory: "1Gi"
        cpu: "500m"
    volumeMounts:
    - name: maven-cache
      mountPath: /root/.m2
  volumes:
  - name: maven-cache
    emptyDir: {}
"""
      defaultContainer 'maven'
    }
  }

  parameters {
    choice(name: 'PROJECTS', choices: ['auto', 'all', 'project-a', 'project-b', 'project-c'], 
           description: 'Projects to build (auto = only changed)')
    booleanParam(name: 'SKIP_TESTS', defaultValue: false, description: 'Skip tests')
  }

  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '10'))
    timeout(time: 30, unit: 'MINUTES')
  }

  stages {
    stage('Initialize') {
      steps {
        script {
          echo "Branch: ${env.BRANCH_NAME}"
          echo "Build: #${env.BUILD_NUMBER}"
          if (env.CHANGE_ID) {
            echo "PR: #${env.CHANGE_ID} → ${env.CHANGE_TARGET}"
          }
        }
      }
    }

    stage('Determine Environment') {
      steps {
        script {
          def branch = env.BRANCH_NAME
          def environment = 'dev'
          
          if (branch == 'main') environment = 'prod'
          else if (branch == 'develop') environment = 'dev'
          else if (branch.startsWith('release/')) environment = 'qa'
          else if (env.CHANGE_ID) environment = 'test'
          
          env.DEPLOY_ENV = environment
          echo "Environment: ${environment}"
        }
      }
    }

    stage('Detect Changed Projects') {
      steps {
        script {
          def changedFiles = []
          try {
            if (env.CHANGE_ID) {
              changedFiles = sh(script: "git diff --name-only origin/${env.CHANGE_TARGET}...HEAD", 
                               returnStdout: true).trim().split('\n') as List
            } else {
              changedFiles = sh(script: "git diff --name-only HEAD~1..HEAD 2>/dev/null || echo ''", 
                               returnStdout: true).trim().split('\n') as List
            }
          } catch (Exception e) {
            changedFiles = []
          }
          
          def autoList = []
          if (changedFiles.any { it.startsWith('project-a/') }) autoList << 'project-a'
          if (changedFiles.any { it.startsWith('project-b/') }) autoList << 'project-b'
          if (changedFiles.any { it.startsWith('project-c/') }) autoList << 'project-c'
          if (changedFiles.any { it == 'Jenkinsfile' }) autoList = ['project-a', 'project-b', 'project-c']
          
          if (params.PROJECTS == 'all') {
            env.PROJECT_LIST = 'project-a project-b project-c'
          } else if (params.PROJECTS == 'auto') {
            env.PROJECT_LIST = autoList.isEmpty() ? 'none' : autoList.join(' ')
          } else {
            env.PROJECT_LIST = params.PROJECTS
          }
          
          echo "Projects: ${env.PROJECT_LIST}"
        }
      }
    }

    stage('Abort if Nothing') {
      when { expression { env.PROJECT_LIST == 'none' } }
      steps {
        script {
          currentBuild.result = 'ABORTED'
          error("No changes detected")
        }
      }
    }

    stage('Maven Build') {
      when { expression { env.PROJECT_LIST != 'none' } }
      steps {
        script {
          def projects = env.PROJECT_LIST.split(' ') as List
          def skipTests = params.SKIP_TESTS ? '-DskipTests' : ''
          
          for (proj in projects) {
            echo "Building ${proj} for ${env.DEPLOY_ENV}..."
            sh """
              mvn -B -f ${proj}/pom.xml clean package assembly:single \
                ${skipTests} \
                -Dbuild.env=${env.DEPLOY_ENV} \
                -Dbuild.branch=${env.BRANCH_NAME} \
                -Dbuild.number=${env.BUILD_NUMBER}
            """
          }
        }
      }
    }

    stage('Archive') {
      when { expression { env.PROJECT_LIST != 'none' } }
      steps {
        archiveArtifacts artifacts: '*/target/*.jar', fingerprint: true, allowEmptyArchive: true
      }
    }
  }

  post {
    success { echo "✓ Build succeeded" }
    failure { echo "✗ Build failed" }
    always { cleanWs() }
  }
}
EOF
```

### Step 3: Create pom.xml Files

```bash
# Create pom.xml for project-a
cat <<'EOF' > project-a/pom.xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>com.example</groupId>
  <artifactId>project-a</artifactId>
  <version>1.0.0</version>

  <properties>
    <maven.compiler.source>17</maven.compiler.source>
    <maven.compiler.target>17</maven.compiler.target>
    <build.env>dev</build.env>
    <build.branch>unknown</build.branch>
    <build.number>0</build.number>
  </properties>

  <build>
    <finalName>${project.artifactId}-${project.version}-${build.env}</finalName>
    
    <resources>
      <resource>
        <directory>src/main/resources</directory>
        <filtering>true</filtering>
      </resource>
    </resources>

    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-assembly-plugin</artifactId>
        <version>3.6.0</version>
        <configuration>
          <descriptorRefs>
            <descriptorRef>jar-with-dependencies</descriptorRef>
          </descriptorRefs>
          <finalName>${project.artifactId}-${project.version}-${build.env}</finalName>
          <appendAssemblyId>false</appendAssemblyId>
          <archive>
            <manifestEntries>
              <Build-Environment>${build.env}</Build-Environment>
              <Build-Branch>${build.branch}</Build-Branch>
              <Build-Number>${build.number}</Build-Number>
            </manifestEntries>
          </archive>
        </configuration>
        <executions>
          <execution>
            <phase>package</phase>
            <goals>
              <goal>single</goal>
            </goals>
          </execution>
        </executions>
      </plugin>
    </plugins>
  </build>
</project>
EOF

# Copy for other projects
sed 's/project-a/project-b/g' project-a/pom.xml > project-b/pom.xml
sed 's/project-a/project-c/g' project-a/pom.xml > project-c/pom.xml
```

### Step 4: Create Sample Java Files

```bash
# Create Main.java for project-a
cat <<'EOF' > project-a/src/main/java/com/example/Main.java
package com.example;

public class Main {
    public static void main(String[] args) {
        System.out.println("Project A - Hello from K3s Cluster!");
        System.out.println("Environment: " + System.getProperty("build.env", "unknown"));
    }
}
EOF

# Copy for other projects
sed 's/Project A/Project B/g' project-a/src/main/java/com/example/Main.java > project-b/src/main/java/com/example/Main.java
sed 's/Project A/Project C/g' project-a/src/main/java/com/example/Main.java > project-c/src/main/java/com/example/Main.java
```

### Step 5: Create application.properties

```bash
# Create for project-a
cat <<'EOF' > project-a/src/main/resources/application.properties
app.name=${project.artifactId}
app.version=${project.version}
app.environment=${build.env}
app.branch=${build.branch}
app.build=${build.number}

database.url=jdbc:mysql://db-${build.env}.example.com:3306/mydb
api.url=https://api-${build.env}.example.com
EOF

# Copy for other projects
cp project-a/src/main/resources/application.properties project-b/src/main/resources/
cp project-a/src/main/resources/application.properties project-c/src/main/resources/
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

## ✅ Test the Setup

### Test 1: Verify Branch Discovery

```bash
# Check Jenkins UI
# You should see:
# maven-multi-project/
#   ├── main
#   ├── develop
#   └── release/v1.0
```

### Test 2: Trigger Manual Build

1. Click `maven-multi-project` → `develop`
2. Click **Build with Parameters**
3. Select PROJECTS: `all`
4. Click **Build**

### Test 3: Watch Build Pods

```bash
# Watch pods being created
kubectl get pods -n jenkins -w

# You'll see:
# jenkins-0                           2/2   Running
# maven-multi-project-develop-1-xxx   0/1   Pending
# maven-multi-project-develop-1-xxx   1/1   Running
# maven-multi-project-develop-1-xxx   0/1   Completed
```

### Test 4: Verify Internet Access in Build

Check Jenkins console output - should show:
```
Downloading from central: https://repo.maven.apache.org/maven2/...
Downloaded: https://repo.maven.apache.org/maven2/...
```

### Test 5: Trigger via Git Push

```bash
# Make a change
git checkout develop
echo "test" >> README.md
git add .
git commit -m "test: trigger build"
git push origin develop

# Jenkins should automatically build within 1 minute
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
