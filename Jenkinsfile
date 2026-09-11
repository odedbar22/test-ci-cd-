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

    triggers {
        pollSCM('H/2 * * * *')
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
        stage('Publish image to GHCR') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'ghcr',
                    usernameVariable: 'GHCR_USER',
                    passwordVariable: 'GHCR_TOKEN'
                )]) {
                    sh '''
                        set +x
                        set -eu

                        export DOCKER_CONFIG="$(mktemp -d)"
                        trap 'rm -rf "$DOCKER_CONFIG"' EXIT

                        printf '%s' "$GHCR_TOKEN" |
                            docker login ghcr.io \
                                --username "$GHCR_USER" \
                                --password-stdin

                        TAG="${IMAGE_TAG#cicd-lab:}"
                        REMOTE_IMAGE="ghcr.io/odedbar22/cicd-lab:${TAG}"

                        docker tag "$IMAGE_TAG" "$REMOTE_IMAGE"
                        docker push "$REMOTE_IMAGE"

                        echo "Published: $REMOTE_IMAGE"
                    '''
                }
            }
	}
	stage('Deploy to Minikube') {
            steps {
                sh 'bash scripts/deploy-local.sh "$IMAGE_TAG"'
            }
        }
        stage('Verify deployment') {
            steps {
                sh 'bash scripts/test-deployment.sh "$IMAGE_TAG"'
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
