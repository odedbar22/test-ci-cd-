pipeline {
    agent {
        label 'docker-builder'
    }

    options {
        skipDefaultCheckout(true)
        disableConcurrentBuilds()
        timeout(time: 15, unit: 'MINUTES')
        timestamps()
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    def commit = sh(
                        script: 'git rev-parse --short=12 HEAD',
                        returnStdout: true
                    ).trim()
                    env.IMAGE_TAG = "cicd-lab:git-${commit}-build-${env.BUILD_NUMBER}"
                }
            }
        }

        stage('Check source and tools') {
            steps {
                sh '''
                    set -eu
                    docker version
                    python3 --version
                    curl --version
                    test -s app/server.py
                    test -s Dockerfile
                    test -s VERSION
                    for script in scripts/*.sh; do
                        bash -n "$script"
                    done
                '''
            }
        }

        stage('Build image') {
            steps {
                sh 'docker build -t "$IMAGE_TAG" .'
            }
        }

        stage('Test image') {
            steps {
                sh 'bash scripts/test-image.sh "$IMAGE_TAG"'
            }
        }

	stage('Deploy to Minikube') {
            steps {
                sh 'bash scripts/deploy-local.sh "$IMAGE_TAG"'
            }
        }
    }

    post {
        success {
            echo "Image passed the smoke test: ${env.IMAGE_TAG}"
        }
        failure {
            echo 'Pipeline failed. Inspect the failed stage and container logs.'
        }
    }
}
