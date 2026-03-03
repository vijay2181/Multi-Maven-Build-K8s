# Complete Multi-Maven Project Setup for Jenkins
# Run this script to create the entire project structure

echo "=== Multi-Maven Project Setup ==="
echo ""

# 1. Get repository details
read -p "Enter your GitHub username: " GITHUB_USER
read -p "Enter repository name (e.g., maven-multi-project): " REPO_NAME

REPO_URL="https://github.com/${GITHUB_USER}/${REPO_NAME}.git"

echo ""
echo "Repository: $REPO_URL"
echo ""

# 2. Clone or create repository
if [ -d "$REPO_NAME" ]; then
    echo "Directory $REPO_NAME already exists. Using existing directory."
    cd "$REPO_NAME"
else
    echo "Cloning repository..."
    git clone "$REPO_URL" 2>/dev/null || {
        echo "Repository doesn't exist. Creating new directory..."
        mkdir "$REPO_NAME"
        cd "$REPO_NAME"
        git init
        git remote add origin "$REPO_URL"
    }
fi

cd "$REPO_NAME"
# 3. Create project structure
echo "Creating project structure..."
mkdir -p project-a/src/main/java/com/example
mkdir -p project-a/src/main/resources
mkdir -p project-a/src/test/java/com/example

mkdir -p project-b/src/main/java/com/example
mkdir -p project-b/src/main/resources
mkdir -p project-b/src/test/java/com/example

mkdir -p project-c/src/main/java/com/example
mkdir -p project-c/src/main/resources
mkdir -p project-c/src/test/java/com/example

# 4. Create Jenkinsfile
echo "Creating Jenkinsfile..."
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
          echo "═══════════════════════════════════════"
          echo "Branch: ${env.BRANCH_NAME}"
          echo "Build: #${env.BUILD_NUMBER}"
          if (env.CHANGE_ID) {
            echo "PR: #${env.CHANGE_ID} → ${env.CHANGE_TARGET}"
          }
          echo "═══════════════════════════════════════"
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
          
          echo "Projects to build: ${env.PROJECT_LIST}"
        }
      }
    }

    stage('Abort if Nothing') {
      when { expression { env.PROJECT_LIST == 'none' } }
      steps {
        script {
          currentBuild.result = 'ABORTED'
          error("No changes detected in project folders")
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
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "Building ${proj} for ${env.DEPLOY_ENV}..."
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            
            sh """
              mvn -B -f ${proj}/pom.xml clean package assembly:single \
                ${skipTests} \
                -Dbuild.env=${env.DEPLOY_ENV} \
                -Dbuild.branch=${env.BRANCH_NAME} \
                -Dbuild.number=${env.BUILD_NUMBER}
            """
            
            echo "✓ ${proj} build completed"
          }
        }
      }
    }
  }
}
EOF

# 5. Create pom.xml for each project
echo "Creating pom.xml files..."

for PROJECT in project-a project-b project-c; do
cat <<EOF > ${PROJECT}/pom.xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>com.example</groupId>
  <artifactId>${PROJECT}</artifactId>
  <version>1.0.0</version>
  <packaging>jar</packaging>

  <name>${PROJECT}</name>
  <description>Multi-branch Maven project with K3s Jenkins</description>

  <properties>
    <maven.compiler.source>17</maven.compiler.source>
    <maven.compiler.target>17</maven.compiler.target>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    
    <!-- Build properties (passed from Jenkins) -->
    <build.env>dev</build.env>
    <build.branch>unknown</build.branch>
    <build.number>0</build.number>
  </properties>

  <dependencies>
    <!-- JUnit for testing -->
    <dependency>
      <groupId>org.junit.jupiter</groupId>
      <artifactId>junit-jupiter</artifactId>
      <version>5.9.3</version>
      <scope>test</scope>
    </dependency>
  </dependencies>

  <build>
    <finalName>\${project.artifactId}-\${project.version}-\${build.env}</finalName>
    
    <!-- Enable resource filtering -->
    <resources>
      <resource>
        <directory>src/main/resources</directory>
        <filtering>true</filtering>
      </resource>
    </resources>

    <plugins>
      <!-- Maven Compiler Plugin -->
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-compiler-plugin</artifactId>
        <version>3.11.0</version>
        <configuration>
          <source>17</source>
          <target>17</target>
        </configuration>
      </plugin>

      <!-- Maven Surefire Plugin (Tests) -->
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-surefire-plugin</artifactId>
        <version>3.1.2</version>
      </plugin>

      <!-- Maven Assembly Plugin -->
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-assembly-plugin</artifactId>
        <version>3.6.0</version>
        <configuration>
          <descriptorRefs>
            <descriptorRef>jar-with-dependencies</descriptorRef>
          </descriptorRefs>
          <finalName>\${project.artifactId}-\${project.version}-\${build.env}</finalName>
          <appendAssemblyId>false</appendAssemblyId>
          <archive>
            <manifest>
              <mainClass>com.example.Main</mainClass>
            </manifest>
            <manifestEntries>
              <Build-Environment>\${build.env}</Build-Environment>
              <Build-Branch>\${build.branch}</Build-Branch>
              <Build-Number>\${build.number}</Build-Number>
              <Build-Time>\${maven.build.timestamp}</Build-Time>
            </manifestEntries>
          </archive>
        </configuration>
        <executions>
          <execution>
            <id>make-assembly</id>
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
done

# 6. Create Main.java for each project
echo "Creating Main.java files..."

cat <<'EOF' > project-a/src/main/java/com/example/Main.java
package com.example;

public class Main {
    public static void main(String[] args) {
        System.out.println("╔═══════════════════════════════════════╗");
        System.out.println("║         PROJECT A - K3S JENKINS       ║");
        System.out.println("╚═══════════════════════════════════════╝");
        System.out.println("Environment: " + System.getProperty("build.env", "unknown"));
        System.out.println("Branch: " + System.getProperty("build.branch", "unknown"));
        System.out.println("Build: #" + System.getProperty("build.number", "0"));
        System.out.println("Hello from Project A!");
    }
}
EOF

cat <<'EOF' > project-b/src/main/java/com/example/Main.java
package com.example;

public class Main {
    public static void main(String[] args) {
        System.out.println("╔═══════════════════════════════════════╗");
        System.out.println("║         PROJECT B - K3S JENKINS       ║");
        System.out.println("╚═══════════════════════════════════════╝");
        System.out.println("Environment: " + System.getProperty("build.env", "unknown"));
        System.out.println("Branch: " + System.getProperty("build.branch", "unknown"));
        System.out.println("Build: #" + System.getProperty("build.number", "0"));
        System.out.println("Hello from Project B!");
    }
}
EOF

cat <<'EOF' > project-c/src/main/java/com/example/Main.java
package com.example;

public class Main {
    public static void main(String[] args) {
        System.out.println("╔═══════════════════════════════════════╗");
        System.out.println("║         PROJECT C - K3S JENKINS       ║");
        System.out.println("╚═══════════════════════════════════════╝");
        System.out.println("Environment: " + System.getProperty("build.env", "unknown"));
        System.out.println("Branch: " + System.getProperty("build.branch", "unknown"));
        System.out.println("Build: #" + System.getProperty("build.number", "0"));
        System.out.println("Hello from Project C!");
    }
}
EOF

# 7. Create application.properties for each project
echo "Creating application.properties files..."

for PROJECT in project-a project-b project-c; do
cat <<EOF > ${PROJECT}/src/main/resources/application.properties
# Application Configuration
app.name=\${project.artifactId}
app.version=\${project.version}
app.environment=\${build.env}
app.branch=\${build.branch}
app.build.number=\${build.number}
app.build.time=\${maven.build.timestamp}

# Environment-specific configuration
database.url=jdbc:mysql://db-\${build.env}.example.com:3306/mydb
database.username=app_user_\${build.env}
database.pool.size=10

api.base.url=https://api-\${build.env}.example.com
api.timeout=30000

# Feature flags
feature.debug=\${build.env} == 'dev'
feature.analytics=\${build.env} == 'prod'
EOF
done

# 8. Create README.md
echo "Creating README.md..."
cat <<EOF > README.md
# Multi-Maven Project with Jenkins Multi-Branch Pipeline

This repository contains 3 Maven projects that are built automatically by Jenkins using a Multi-Branch Pipeline on K3s.

## Projects

- **project-a**: First Maven project
- **project-b**: Second Maven project
- **project-c**: Third Maven project

## Branch Strategy

| Branch | Environment | Purpose |
|--------|-------------|---------|
| \`main\` | prod | Production releases |
| \`develop\` | dev | Development |
| \`release/*\` | qa | QA/Staging |

## Jenkins Pipeline

The pipeline automatically:
- Detects which projects changed
- Builds only changed projects
- Uses environment-specific configuration
- Creates JAR files with Maven Assembly

## Local Build

\`\`\`bash
# Build all projects
mvn clean package -Dbuild.env=dev

# Build specific project
mvn -f project-a/pom.xml clean package -Dbuild.env=dev
\`\`\`

## Artifacts

Built artifacts are named: \`{project}-{version}-{environment}.jar\`

Example: \`project-a-1.0.0-prod.jar\`
EOF

# 9. Create .gitignore
echo "Creating .gitignore..."
cat <<'EOF' > .gitignore
# Maven
target/
pom.xml.tag
pom.xml.releaseBackup
pom.xml.versionsBackup
pom.xml.next
release.properties
dependency-reduced-pom.xml
buildNumber.properties
.mvn/timing.properties
.mvn/wrapper/maven-wrapper.jar

# IDE
.idea/
*.iml
.vscode/
.settings/
.project
.classpath

# OS
.DS_Store
Thumbs.db
EOF

# 10. Initialize git and create branches
echo "Initializing git repository..."
git add .
git commit -m "Initial commit: Multi-Maven project setup" 2>/dev/null || echo "Already committed"

# Create branches
echo "Creating branches..."
git branch -M main
git checkout -b develop 2>/dev/null || git checkout develop
git checkout -b release/v1.0 2>/dev/null || git checkout release/v1.0
git checkout main

# 11. Push to GitHub
echo ""
echo "═══════════════════════════════════════════════════════"
echo "Setup complete!"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "Repository structure created:"
tree -L 3 -I 'target' . 2>/dev/null || find . -maxdepth 3 -type d | grep -v '.git' | sed 's|[^/]*/| |g'
echo ""
echo "Next steps:"
echo "1. Push to GitHub:"
echo "   git push -u origin main"
echo "   git push -u origin develop"
echo "   git push -u origin release/v1.0"
echo ""
echo "2. Create Multi-Branch Pipeline in Jenkins:"
echo "   http://localhost:30000/view/all/newJob"
echo ""
echo "3. Configure:"
echo "   - Name: maven-multi-project"
echo "   - Type: Multibranch Pipeline"
echo "   - Branch Sources → GitHub"
echo "   - Repository: $REPO_URL"
echo "   - Scan Triggers: Periodically (1 minute)"
echo ""
echo "4. Save and wait for first scan!"
echo ""
