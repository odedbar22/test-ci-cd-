pipeline {
    agent any

    options {
        skipDefaultCheckout(true)
        disableConcurrentBuilds()
        timeout(time: 5, unit: 'MINUTES')
        timestamps()
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Check project files') {
            steps {
                sh '''
                    set -eu

                    echo "Commit:"
                    git rev-parse --short HEAD

                    echo "Application version:"
                    cat VERSION

                    test -s app/server.py
                    test -s Dockerfile
                    test -s helm/cicd-web/Chart.yaml

                    for script in scripts/build.sh scripts/start.sh scripts/smoke-test.sh; do
                        bash -n "$script"
                    done
                '''
            }
        }
    }

    post {
        success {
            echo 'Source checks passed.'
        }
        failure {
            echo 'Pipeline failed. Inspect the failed stage.'
        }
    }
}
