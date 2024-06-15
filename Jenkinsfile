pipeline {
    agent { label 'master' }

    environment {
        DOCKER_REPO = 'your-docker-repo'
        IMAGE_NAME = 'xyztechnologies'
        IMAGE_TAG = 'latest'
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
                    docker.withRegistry('', '') {
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
