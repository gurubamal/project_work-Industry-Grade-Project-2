pipeline {
    agent { label 'master' }

    environment {
        DOCKER_REPO = 'gurubamal'
        IMAGE_NAME = 'iyztechnologies'
        IMAGE_TAG = 'latest'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'master', url: 'https://github.com/gurubamal/project_work-Industry-Grade-Project-2.git'
            }
        }

        stage('Setup and Build') {
            steps {
                script {
                    // Use credentials stored in Jenkins
                    withCredentials([usernamePassword(credentialsId: 'a1e3d5ea-7989-47cf-a739-e39a637d664a', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                        sh 'chmod +x install.sh'
                        sh './install.sh'
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'a1e3d5ea-7989-47cf-a739-e39a637d664a', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                        sh '''
                        echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
                        docker push ${DOCKER_REPO}/${IMAGE_NAME}:${IMAGE_TAG}
                        '''
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
