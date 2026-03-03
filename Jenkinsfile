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
    buildDiscarder(logRotator(numToKeepStr: '10'))
    timeout(time: 30, unit: 'MINUTES')
  }

  stages {
    stage('Initialize') {
      steps {
        script {
          def timestamp = new Date().format('yyyy-MM-dd HH:mm:ss')
          echo "═══════════════════════════════════════"
          echo "Time: ${timestamp}"
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

    stage('Archive Artifacts') {
      when { expression { env.PROJECT_LIST != 'none' } }
      steps {
        archiveArtifacts artifacts: '*/target/*.jar', 
                         fingerprint: true, 
                         allowEmptyArchive: true
        echo "✓ Artifacts archived"
      }
    }
  }

  post {
    success { 
      echo "✓ Build #${env.BUILD_NUMBER} succeeded for ${env.DEPLOY_ENV}" 
    }
    failure { 
      echo "✗ Build #${env.BUILD_NUMBER} failed" 
    }
    aborted {
      echo "⊘ Build #${env.BUILD_NUMBER} aborted - no changes"
    }
    always { 
      cleanWs() 
    }
  }
}
