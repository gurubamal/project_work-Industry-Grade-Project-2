#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Set environment variables
DOCKER_REPO='your-docker-repo'
IMAGE_NAME='xyztechnologies'
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

# Login to Docker registry using credentials from Jenkins
echo "Logging into Docker registry..."
echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin

# Build Docker image
echo "Building Docker image..."
docker build -t ${DOCKER_REPO}/${IMAGE_NAME}:${IMAGE_TAG} $DOCKER_WORKDIR/XYZ_Technologies

# Push Docker image to the repository
echo "Pushing Docker image to repository..."
docker push ${DOCKER_REPO}/${IMAGE_NAME}:${IMAGE_TAG}

# Print the status message
echo "Build and push process completed successfully."
