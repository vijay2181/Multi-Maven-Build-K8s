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
           description: 'Projects to build')
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
          sh 'git config --global --add safe.directory "*"'
          def branch = env.BRANCH_NAME ?: sh(script: "git rev-parse --abbrev-ref HEAD", returnStdout: true).trim()
          env.CURRENT_BRANCH = branch
          echo "Time: ${timestamp}"
          echo "Branch: ${branch}"
          echo "Build: #${env.BUILD_NUMBER}"
        }
      }
    }

    stage('Determine Environment') {
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

    stage('Detect Projects') {
      steps {
        script {
          if (params.PROJECTS == 'all') {
            env.PROJECT_LIST = 'project-a project-b project-c'
          } else {
            env.PROJECT_LIST = params.PROJECTS
          }
          echo "Projects: ${env.PROJECT_LIST}"
        }
      }
    }

    stage('Maven Build') {
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
                -Dbuild.branch=${env.CURRENT_BRANCH} \
                -Dbuild.number=${env.BUILD_NUMBER}
            """
          }
        }
      }
    }

    stage('Archive') {
      steps {
        archiveArtifacts artifacts: '*/target/*.jar', fingerprint: true, allowEmptyArchive: true
      }
    }
  }

  post {
    success { echo "✓ Build succeeded" }
    failure { echo "✗ Build failed" }
    always { deleteDir() }
  }
}
