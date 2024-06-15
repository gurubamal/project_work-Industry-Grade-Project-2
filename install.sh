#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -e

# Set environment variables
DOCKER_REPO='gurubamal'
IMAGE_NAME='iyztechnologies'
IMAGE_TAG='latest'

# Fix broken or missing repositories
sudo rm -f /etc/apt/sources.list.d/kubernetes.list

# Install Maven
echo "Installing Maven..."
sudo apt-get update
sudo apt-get install -y maven

# Print Maven version
mvn -v

# Print the status message
echo "Starting build process..."

# Navigate to the directory containing the pom.xml file
cd /var/lib/jenkins/workspace/project2/XYZ_Technologies

# Build the application using Maven
echo "Building the Maven project..."
mvn clean package

# Create a directory within the Jenkins workspace for Docker operations
DOCKER_WORKDIR="/var/lib/jenkins/workspace/docker_project"
mkdir -p $DOCKER_WORKDIR
cp -r /var/lib/jenkins/workspace/project2/XYZ_Technologies $DOCKER_WORKDIR

# Check if the Docker config file exists and is readable
DOCKER_CONFIG_SRC="/home/vagrant/.docker/auth.json"
DOCKER_CONFIG_DEST="$DOCKER_WORKDIR/.docker/auth.json"
if [ -r $DOCKER_CONFIG_SRC ]; then
    echo "Copying Docker credentials to $DOCKER_CONFIG_DEST"
    mkdir -p $(dirname $DOCKER_CONFIG_DEST)
    sudo cp $DOCKER_CONFIG_SRC $DOCKER_CONFIG_DEST
    export DOCKER_CONFIG=$(dirname $DOCKER_CONFIG_DEST)
else
    echo "Error: Docker credentials file $DOCKER_CONFIG_SRC not found or not readable."
    exit 1
fi

# Navigate to the new directory
cd $DOCKER_WORKDIR/XYZ_Technologies

# Build Docker image
echo "Building Docker image..."
docker build -t ${DOCKER_REPO}/${IMAGE_NAME}:${IMAGE_TAG} .

# Push Docker image to the repository
echo "Pushing Docker image to repository..."
docker push ${DOCKER_REPO}/${IMAGE_NAME}:${IMAGE_TAG}

# Print the status message
echo "Build and push process completed successfully."
