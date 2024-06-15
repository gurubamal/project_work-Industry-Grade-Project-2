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
                    kubectl label nodes node5 kubernetes.io/hostname=node5 --overwrite

                    # Create the namespace if it doesn't exist
                    kubectl get namespace iynet || kubectl create namespace iynet

                    # Check if deploy_app.yaml exists
                    if [ ! -f "${WORKSPACE}/deploy_app.yaml" ]; then
                        echo "Error: deploy_app.yaml not found!"
                        exit 1
                    fi

                    # Apply the deployment
                    kubectl apply -f ${WORKSPACE}/deploy_app.yaml

                    # Check if the service is up and running
                    NODE_PORT=$(kubectl get svc xyztechnologies-service -n iynet -o=jsonpath='{.spec.ports[0].nodePort}')
                    NODE_IP=$(kubectl get nodes -o wide | grep node5 | awk '{print $6}')

                    if [ -z "$NODE_PORT" ]; then
                        echo "Failed to get the NodePort for the service"
                        exit 1
                    fi

                    echo "Application is available at http://$NODE_IP:$NODE_PORT"
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
