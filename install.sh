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

# Copy Docker credentials
echo "Copying Docker credentials to $DOCKER_WORKDIR/.docker/config.json"
mkdir -p $DOCKER_WORKDIR/.docker
cp /home/vagrant/.docker/config.json $DOCKER_WORKDIR/.docker/config.json

# Set the DOCKER_CONFIG environment variable
export DOCKER_CONFIG=$DOCKER_WORKDIR/.docker

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
