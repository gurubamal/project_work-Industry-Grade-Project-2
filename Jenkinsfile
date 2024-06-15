pipeline {
    agent { label 'master' }

    environment {
        DOCKER_REPO = 'gurubamal'
        IMAGE_NAME = 'iyztechnologies'
        IMAGE_TAG = 'latest'
        KUBECONFIG = '/home/jenkins/.kube/config'  // Path to the kubeconfig file
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

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh '''
                    # Ensure kubectl is installed
                    if ! command -v kubectl &> /dev/null; then
                      sudo apt-get update
                      sudo apt-get install -y kubectl
                    fi
                    
                    # Set the KUBECONFIG environment variable
                    export KUBECONFIG=${KUBECONFIG}
                    
                    # Label the node5 if not already labeled
                    kubectl label nodes node5 node=node5 --overwrite

                    # Apply the deployment
                    kubectl apply -f deploy_app.yaml
                    '''
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
