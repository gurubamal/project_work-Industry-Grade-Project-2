pipeline {
    agent { label 'master' }

    environment {
        DOCKER_REPO = 'your-docker-repo' // Replace with your Docker repository
        IMAGE_NAME = 'xyztechnologies'   // Replace with your image name
        IMAGE_TAG = 'latest'             // Replace with your image tag if needed
        DOCKER_CREDENTIALS_ID = 'your-docker-credentials-id' // Replace with your Jenkins Docker credentials ID
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'master', url: 'https://github.com/gurubamal/project_work-Industry-Grade-Project-2.git'
            }
        }

        stage('Setup') {
            steps {
                sh 'chmod +x install.sh'
                sh './install.sh'
            }
        }

        stage('Test') {
            steps {
                sh '''#!/bin/bash
                source myprojectenv/bin/activate
                python -m unittest
                '''
            }
        }

        stage('Build Maven Project') {
            steps {
                script {
                    docker.image('maven:3.6.3-jdk-11-slim').inside {
                        sh 'mvn clean package'
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    customImage = docker.build("${DOCKER_REPO}/${IMAGE_NAME}:${IMAGE_TAG}")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('', "${DOCKER_CREDENTIALS_ID}") {
                        customImage.push()
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
