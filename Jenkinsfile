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

  options {
    buildDiscarder(logRotator(numToKeepStr: '10'))
    timeout(time: 30, unit: 'MINUTES')
  }

  stages {
    stage('Initialize') {
      steps {
        script {
          sh 'git config --global --add safe.directory "*"'
          def branch = env.BRANCH_NAME ?: sh(script: "git rev-parse --abbrev-ref HEAD", returnStdout: true).trim()
          env.CURRENT_BRANCH = branch
          echo "=== BUILD INFO ==="
          echo "Branch: ${branch}"
          echo "Build: #${env.BUILD_NUMBER}"
          echo "=================="
        }
      }
    }

    stage('Detect Environment') {
      steps {
        script {
          def branch = env.CURRENT_BRANCH
          def environment = 'dev'
          if (branch == 'main') environment = 'prod'
          else if (branch == 'develop') environment = 'dev'
          else if (branch.startsWith('release/')) environment = 'qa'
          env.DEPLOY_ENV = environment
          echo "Environment: ${environment}"
        }
      }
    }

    stage('Detect Changed Projects') {
      steps {
        script {
          def changedFiles = sh(
            script: "git diff --name-only HEAD~1 HEAD 2>/dev/null || echo 'ALL'",
            returnStdout: true
          ).trim()
          
          def projects = []
          if (changedFiles == 'ALL' || changedFiles == '') {
            projects = ['project-a', 'project-b', 'project-c']
            echo "First build or no changes detected - building all projects"
          } else {
            if (changedFiles.contains('project-a/')) projects << 'project-a'
            if (changedFiles.contains('project-b/')) projects << 'project-b'
            if (changedFiles.contains('project-c/')) projects << 'project-c'
            if (changedFiles.contains('Jenkinsfile')) {
              projects = ['project-a', 'project-b', 'project-c']
              echo "Jenkinsfile changed - building all projects"
            }
          }
          
          if (projects.isEmpty()) {
            echo "No project changes detected - skipping build"
            env.SKIP_BUILD = 'true'
            env.BUILD_PROJECTS = ''
          } else {
            env.SKIP_BUILD = 'false'
            env.BUILD_PROJECTS = projects.join(',')
            echo "Projects to build: ${env.BUILD_PROJECTS}"
          }
        }
      }
    }

    stage('Maven Build') {
      when {
        expression { env.SKIP_BUILD == 'false' }
      }
      steps {
        script {
          def projects = env.BUILD_PROJECTS.split(',')
          
          for (proj in projects) {
            echo "=== Building ${proj} for ${env.DEPLOY_ENV} ==="
            sh """
              mvn -B -f ${proj}/pom.xml clean package assembly:single \
                -DskipTests \
                -Dbuild.env=${env.DEPLOY_ENV} \
                -Dbuild.branch=${env.CURRENT_BRANCH} \
                -Dbuild.number=${env.BUILD_NUMBER}
            """
            echo "✓ ${proj} completed successfully"
          }
        }
      }
    }

    stage('Archive Artifacts') {
      when {
        expression { env.SKIP_BUILD == 'false' }
      }
      steps {
        archiveArtifacts artifacts: '*/target/*.jar', fingerprint: true, allowEmptyArchive: true
        echo "✓ Artifacts archived"
      }
    }
  }

  post {
    success { 
      script {
        if (env.SKIP_BUILD == 'true') {
          echo "✓ Build #${env.BUILD_NUMBER} - No changes to build"
        } else {
          echo "✓ Build #${env.BUILD_NUMBER} succeeded for ${env.DEPLOY_ENV}"
          echo "✓ Built projects: ${env.BUILD_PROJECTS}"
        }
      }
    }
    failure { echo "✗ Build #${env.BUILD_NUMBER} failed" }
    always { deleteDir() }
  }
}
