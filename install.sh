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

# Navigate to Jenkins home directory
cd /var/lib/jenkins

# Copy Docker credentials
echo "Copying Docker credentials to /var/lib/jenkins/.docker/config.json"
mkdir -p /var/lib/jenkins/.docker
cp /home/vagrant/.docker/config.json /var/lib/jenkins/.docker/config.json

# Build Docker image
echo "Building Docker image..."
docker build -t ${DOCKER_REPO}/${IMAGE_NAME}:${IMAGE_TAG} /var/lib/jenkins/workspace/project2/XYZ_Technologies

# Use Docker configuration
export DOCKER_CONFIG=/var/lib/jenkins/.docker

# Push Docker image to the repository
echo "Pushing Docker image to repository..."
docker push ${DOCKER_REPO}/${IMAGE_NAME}:${IMAGE_TAG}

# Print the status message
echo "Build and push process completed successfully."
