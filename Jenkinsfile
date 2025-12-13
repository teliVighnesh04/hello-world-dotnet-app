pipeline {
    agent { label 'dotnet' }
    
    parameters {
        choice(name: 'ENV', choices: ['UAT', 'PROD'], description: 'Choose environment to build for')
    }

    stages {
        stage('Determine branch') {
            steps {
                script {
                    env.GIT_BRANCH = (params.ENV == 'UAT') ? 'uat' : 'prod'
                    env.IMAGE_TAG = (params.ENV == 'UAT') ? 'uat-latest' : 'prod-latest'
                    echo "Selected ENV = ${params.ENV} -> using branch: ${env.GIT_BRANCH}"
                }
            }
        }
        stage('Git Checkout') {
            steps {
                git branch: "${env.GIT_BRANCH}", url: 'https://github.com/teliVighnesh04/hello-world-dotnet-app.git'
            }
        }
        stage('Docker Build & tag') {
            steps {
                script{
                    withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker') {
                        sh "docker build -t vighneshteli/hello-world-dotnet:${env.IMAGE_TAG} ."
                    }
                }
            }
        }
        stage('Docker Push') {
            steps {
                script{
                    withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker') {
                        sh "docker push vighneshteli/hello-world-dotnet:${env.IMAGE_TAG}"
                    }
                }
            }
        }
        stage('Check & Kill Existing Container on Port 5000') {
            steps {
                script {
                    echo "Checking if port 5000 is already in use..."
                    // Check if any container is using port 5000
                    def containerId = sh(
                        script: "docker ps --filter 'publish=5000' --format '{{.ID}}'",
                        returnStdout: true
                    ).trim()

                    if (containerId) {
                        echo "Port 5000 is in use by container: ${containerId}"
                        echo "Stopping and removing container..."
                        sh "docker stop ${containerId}"
                        sh "docker rm ${containerId}"
                    } else {
                        echo "Port 5000 is free. Continuing..."
                    }
                }
            }
        }
        stage('Run Dotnet Project') {
            steps {
                script{
                    withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker') {
                        sh "docker run -d -p 5000:5000 vighneshteli/hello-world-dotnet:${env.IMAGE_TAG}"
                        sh "sleep 5"   // wait for app to start
                        sh "curl -f http://localhost:5000/api/hello"
                    }
                }
            }
        }
    }
}

