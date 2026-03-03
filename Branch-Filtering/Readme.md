
# Enhanced Jenkins Pipeline with Branch Filtering & Manual Build Control

## 🎯 Overview

This enhanced Jenkins pipeline provides:
- ✅ **Smart Branch Filtering** - Auto-builds only for feature branches
- ✅ **Manual Build Control** - Select specific projects to build
- ✅ **Branch Restrictions** - Prevent accidental auto-builds on main/release branches
- ✅ **Environment Detection** - Automatic environment based on branch
- ✅ **Selective Building** - Build only changed projects or choose manually

---

## 📋 Table of Contents

1. [Key Features](#key-features)
2. [Branch Strategy](#branch-strategy)
3. [Build Modes](#build-modes)
4. [Setup Instructions](#setup-instructions)
5. [Usage Examples](#usage-examples)
6. [Troubleshooting](#troubleshooting)

---

## 🚀 Key Features

### 1. Branch Filtering (Auto-Build Control)

**Problem:** You don't want every code push to trigger builds automatically, especially on critical branches like `main` or `release/*`.

**Solution:** The pipeline automatically detects branch type and decides whether to allow auto-builds.

| Branch Type | Auto-Build | Manual Build | Environment |
|-------------|-----------|--------------|-------------|
| `feature/*` | ✅ Enabled | ✅ Allowed | dev |
| `bugfix/*` | ✅ Enabled | ✅ Allowed | dev |
| `main` | ❌ Disabled | ✅ Allowed | prod |
| `develop` | ❌ Disabled | ✅ Allowed | dev |
| `release/*` | ❌ Disabled | ✅ Allowed | qa |
| `hotfix/*` | ❌ Disabled | ✅ Allowed | prod |

### 2. Build with Parameters

**Manual Build Options:**

```
BUILD_MODE:
├─ auto     → Build only changed projects (default)
├─ all      → Build all projects
└─ custom   → Select specific projects

Custom Project Selection:
├─ BUILD_PROJECT_A  [✓]
├─ BUILD_PROJECT_B  [ ]
└─ BUILD_PROJECT_C  [✓]

FORCE_BUILD:
└─ Override branch restrictions (for manual builds)
```

### 3. Intelligent Project Detection

The pipeline automatically detects which projects changed:

```bash
# Changed files detection
project-a/src/main/App.java  → Builds project-a
project-b/pom.xml            → Builds project-b
Jenkinsfile                  → Builds ALL projects
```

---

## 🌿 Branch Strategy

### Branch-to-Environment Mapping

```
Repository Structure:
├── main (prod)              ← Manual builds only
├── develop (dev)            ← Manual builds only
├── release/
│   ├── v1.0 (qa)           ← Manual builds only
│   └── v2.0 (qa)           ← Manual builds only
├── hotfix/
│   └── critical-fix (prod) ← Manual builds only
├── feature/
│   ├── new-api (dev)       ← Auto-builds enabled ✓
│   └── user-auth (dev)     ← Auto-builds enabled ✓
└── bugfix/
    └── fix-login (dev)     ← Auto-builds enabled ✓
```

### Workflow Example

```bash
# 1. Create feature branch (auto-build enabled)
git checkout -b feature/new-api
echo "new code" >> project-a/src/App.java
git commit -am "Add new API endpoint"
git push origin feature/new-api
# ✅ Jenkins auto-builds project-a with dev environment

# 2. Push to main (auto-build disabled)
git checkout main
git merge feature/new-api
git push origin main
# ❌ Jenkins aborts with message: "Auto-build disabled for main"
# ℹ️  Use "Build with Parameters" for manual builds

# 3. Manual build on main
# Jenkins UI → Build with Parameters
#   BUILD_MODE: all
#   FORCE_BUILD: ✓
# ✅ Builds all projects with prod environment
```

---

## 🔧 Build Modes

### Mode 1: Auto (Default)

**When:** Webhook triggers or manual build with auto mode

**Behavior:** Builds only changed projects

```bash
# Example: Changed project-a and project-c
git diff HEAD~1 HEAD
  project-a/src/App.java
  project-c/pom.xml

# Result: Builds project-a and project-c only
```

### Mode 2: All

**When:** Manual build with "all" mode

**Behavior:** Builds all projects regardless of changes

```
Jenkins → Build with Parameters
  BUILD_MODE: all
  
Result: Builds project-a, project-b, project-c
```

### Mode 3: Custom

**When:** Manual build with "custom" mode

**Behavior:** Builds only selected projects

```
Jenkins → Build with Parameters
  BUILD_MODE: custom
  BUILD_PROJECT_A: ✓
  BUILD_PROJECT_C: ✓
  
Result: Builds project-a and project-c only
```

---

## 📦 Setup Instructions

### Step 1: Repository Structure

```
your-repo/
├── Branch-Filtering/Jenkinsfile     # Use this pipeline
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

### Step 2: Rename Jenkinsfile

```bash
# In your repository
mv Jenkinsfile-Enhanced Jenkinsfile
git add Jenkinsfile
git commit -m "Update to enhanced pipeline"
git push origin main
```

### Step 3: Jenkins Job Configuration

**Option A: Regular Pipeline Job**

1. Jenkins → New Item → Pipeline
2. Name: `maven-multi-project`
3. Pipeline → Definition: `Pipeline script from SCM`
4. SCM: Git
5. Repository URL: `https://github.com/your-org/your-repo`
6. Branch: `*/main` (or `*/*` for all branches)
7. Script Path: `Jenkinsfile`
8. Save

**Option B: Multi-Branch Pipeline (Recommended)**

1. Jenkins → New Item → Multibranch Pipeline
2. Name: `maven-multi-project`
3. Branch Sources → Add → GitHub
4. Repository URL: `https://github.com/your-org/your-repo`
5. Behaviors → Add:
   - Discover branches (All branches)
   - Filter by name: `main develop release/* hotfix/* feature/* bugfix/*`
6. Build Configuration → Script Path: `Jenkinsfile`
7. Save

### Step 4: GitHub Webhook (Optional)

**For auto-triggering builds on feature branches:**

1. GitHub → Repository → Settings → Webhooks → Add webhook
2. Payload URL: `http://your-jenkins-url/github-webhook/`
3. Content type: `application/json`
4. Events: ✅ Just the push event
5. Active: ✅
6. Add webhook

**Note:** Webhook will trigger builds, but pipeline will abort for restricted branches.

---

## 💡 Usage Examples

### Example 1: Feature Branch Development

```bash
# Developer creates feature branch
git checkout -b feature/user-authentication
git push origin feature/user-authentication

# Make changes to project-a
echo "new auth code" >> project-a/src/Auth.java
git commit -am "Add authentication"
git push origin feature/user-authentication

# ✅ Jenkins automatically:
#   - Detects feature branch
#   - Allows auto-build
#   - Builds only project-a
#   - Uses dev environment
```

**Console Output:**
```
=== BUILD INFO ===
Branch: feature/user-authentication
Build: #42
Triggered by: Webhook/SCM
==================

=== BRANCH VALIDATION ===
Branch: feature/user-authentication
Is Restricted: false
Is Manual Build: false
✓ Auto-build enabled for feature branch
========================

=== ENVIRONMENT ===
Detected: dev
===================

=== PROJECTS TO BUILD ===
  ✓ project-a
=========================

✓ project-a completed successfully
```

### Example 2: Main Branch (Auto-Build Blocked)

```bash
# Push to main branch
git checkout main
git merge feature/user-authentication
git push origin main

# ❌ Jenkins automatically:
#   - Detects main branch
#   - Blocks auto-build
#   - Aborts with message
```

**Console Output:**
```
=== BUILD INFO ===
Branch: main
Build: #43
Triggered by: Webhook/SCM
==================

=== BRANCH VALIDATION ===
Branch: main
Is Restricted: true
Is Manual Build: false
⚠️  Auto-build DISABLED for branch: main
ℹ️  This branch requires manual 'Build with Parameters'
ℹ️  Allowed auto-build branches: feature/*, bugfix/*, etc.
========================

=== BUILD ABORTED ===
Reason: Auto-build disabled for main
Use 'Build with Parameters' for manual builds
====================
```

### Example 3: Manual Build on Main

```
Jenkins UI Steps:
1. Go to job: maven-multi-project
2. Click "Build with Parameters"
3. Select:
   BUILD_MODE: all
   FORCE_BUILD: ✓ (checked)
4. Click "Build"

✅ Result:
   - Builds all projects
   - Uses prod environment
   - Creates artifacts
```

**Console Output:**
```
=== BUILD INFO ===
Branch: main
Build: #44
Triggered by: Manual
==================

=== BRANCH VALIDATION ===
Branch: main
Is Restricted: true
Is Manual Build: true
Force Build: true
✓ Manual build allowed for restricted branch: main
========================

=== ENVIRONMENT ===
Detected: prod
===================

Manual build - Building all projects

=== PROJECTS TO BUILD ===
  ✓ project-a
  ✓ project-b
  ✓ project-c
=========================

✓ project-a completed successfully
✓ project-b completed successfully
✓ project-c completed successfully
```

### Example 4: Custom Project Selection

```
Jenkins UI Steps:
1. Click "Build with Parameters"
2. Select:
   BUILD_MODE: custom
   BUILD_PROJECT_A: ✓ (checked)
   BUILD_PROJECT_C: ✓ (checked)
   BUILD_PROJECT_B: (unchecked)
3. Click "Build"

✅ Result: Builds only project-a and project-c
```

### Example 5: Release Branch

```bash
# Create release branch
git checkout -b release/v1.0
git push origin release/v1.0

# Push changes
echo "release prep" >> README.md
git commit -am "Prepare v1.0 release"
git push origin release/v1.0

# ❌ Auto-build blocked (restricted branch)
# ✅ Manual build required
```

**Manual Build:**
```
BUILD_MODE: all
Environment: qa (automatically detected)
```

---

## 🔍 Troubleshooting

### Issue 1: Build Aborted on Feature Branch

**Symptom:**
```
Build aborted: Auto-build not allowed for feature/my-feature
```

**Cause:** Branch name doesn't match allowed patterns

**Solution:**
```bash
# Check branch name
git branch --show-current

# Ensure it starts with: feature/, bugfix/, etc.
# If not, rename:
git branch -m old-name feature/new-name
git push origin feature/new-name
```

### Issue 2: Manual Build Not Working

**Symptom:** "Build with Parameters" option not visible

**Cause:** Parameters not initialized

**Solution:**
1. Run build once (will fail/abort)
2. Parameters will be registered
3. "Build with Parameters" will appear
4. Use it for subsequent builds

### Issue 3: All Projects Building When Only One Changed

**Symptom:** Changed project-a, but all projects built

**Possible Causes:**
- Jenkinsfile was modified (triggers all)
- First build after job creation (builds all)
- BUILD_MODE set to "all"

**Solution:**
```bash
# Check what changed
git diff HEAD~1 HEAD --name-only

# If Jenkinsfile changed, all projects build (expected)
# Otherwise, check BUILD_MODE parameter
```

### Issue 4: Wrong Environment Detected

**Symptom:** Branch `feature/api` using `prod` instead of `dev`

**Debug:**
```groovy
// Check in console output
=== ENVIRONMENT ===
Detected: prod  ← Should be dev
===================
```

**Solution:** Check branch name format:
```bash
# Correct formats:
feature/my-feature  → dev
bugfix/fix-issue    → dev
release/v1.0        → qa
main                → prod
```

### Issue 5: Webhook Not Triggering

**Check:**
1. GitHub → Settings → Webhooks → Recent Deliveries
2. Look for green ✓ (success) or red ✗ (failure)

**Common Issues:**
- Jenkins URL not accessible from GitHub
- Webhook URL incorrect (should end with `/github-webhook/`)
- Jenkins not configured to accept webhooks

**Test Webhook:**
```bash
curl -X POST http://your-jenkins-url/github-webhook/
```

---

## 📊 Build Decision Matrix

| Trigger | Branch | BUILD_MODE | FORCE_BUILD | Result |
|---------|--------|-----------|-------------|--------|
| Webhook | feature/* | - | - | ✅ Auto-build (changed projects) |
| Webhook | main | - | - | ❌ Aborted |




```bash
Enhanced Jenkinsfile Explanation
🎯 Key New Features Added
1. Branch Filtering (Auto-Build Control)
Problem Solved: Webhooks should NOT auto-trigger builds for main, develop, and release branches.

Solution:

Restricted Branches: main, master, develop, release/*, hotfix/*
Allowed Auto-Build: feature/*, bugfix/*, and other branches
Stage: "Branch Validation" checks if branch is restricted
If restricted + auto-triggered → Build ABORTED with message
If restricted + manual build → Build ALLOWED
Example:

Push to feature/new-api → ✅ Auto-builds
Push to main → ❌ Aborted (use manual build)
Push to release/v1.0 → ❌ Aborted (use manual build)

2. Build with Parameters (Manual Project Selection)
Problem Solved: Users should manually select which projects to build.

New Parameters:

BUILD_MODE: Choose auto (changed only), all (all projects), or custom (select specific)
BUILD_PROJECT_A/B/C: Checkboxes to select individual projects (custom mode)
FORCE_BUILD: Override branch restrictions for manual builds
Usage:

Manual Build → Build with Parameters
├─ BUILD_MODE: custom
├─ ✅ BUILD_PROJECT_A
├─ ✅ BUILD_PROJECT_C
└─ Build → Only project-a and project-c built

3. Smart Build Detection
Detects:

Manual vs Webhook trigger
Which projects changed (git diff)
Branch restrictions
Custom selections
Logic:

IF manual + custom mode → Build selected projects
IF manual + all mode → Build all projects
IF auto mode → Build only changed projects
IF restricted branch + webhook → ABORT
IF restricted branch + manual → ALLOW

📊 Workflow Examples
Scenario 1: Feature Branch (Auto-Build Enabled)
git checkout -b feature/new-api
# Make changes to project-a
git commit -am "Add new API"
git push origin feature/new-api

Result: ✅ Webhook triggers → Auto-builds project-a with dev environment

Scenario 2: Main Branch (Auto-Build Disabled)
git checkout main
# Make changes
git commit -am "Update config"
git push origin main

Result: ❌ Webhook triggers → Build ABORTED with message:

⚠️ Auto-build DISABLED for branch: main
ℹ️ This branch requires manual 'Build with Parameters'

Scenario 3: Manual Build on Main
Jenkins → Job → Build with Parameters
├─ BUILD_MODE: all
├─ FORCE_BUILD: ✅
└─ Build

Result: ✅ Builds all projects for prod environment

Scenario 4: Custom Project Selection
Jenkins → Job → Build with Parameters
├─ BUILD_MODE: custom
├─ BUILD_PROJECT_A: ✅
├─ BUILD_PROJECT_C: ✅
└─ Build

Result: ✅ Builds only project-a and project-c

🔧 Configuration Summary
Branch Restrictions:

main, master, develop → Manual only
release/*, hotfix/* → Manual only
feature/*, bugfix/* → Auto-build enabled
Environment Mapping:

main/master → prod
develop → dev
release/* → qa
hotfix/* → prod
feature/* → dev
Build Modes:

auto → Changed projects only
all → All projects
custom → User-selected projects
This solves all requirements: webhook filtering, manual project selection, and branch-based build control!
```
