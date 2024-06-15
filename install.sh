#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Set environment variables
DOCKER_REPO='gurubamal'
IMAGE_NAME='iyztechnologies'
IMAGE_TAG='latest'
WORKSPACE_DIR='/var/lib/jenkins/workspace'
PROJECT_DIR="$WORKSPACE_DIR/project2/XYZ_Technologies"
DOCKERFILE_DIR="$WORKSPACE_DIR/project2"
DOCKER_WORKDIR="$WORKSPACE_DIR/docker_project"

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

# Ensure the workspace and project directories exist
if [ ! -d "$PROJECT_DIR" ]; then
    echo "Error: Directory $PROJECT_DIR does not exist."
    exit 1
fi

# Ensure the Dockerfile exists
if [ ! -f "$DOCKERFILE_DIR/Dockerfile" ]; then
    echo "Error: Dockerfile not found in $DOCKERFILE_DIR"
    exit 1
fi

# Navigate to the directory containing the pom.xml file
cd $PROJECT_DIR

# Build the application using Maven
echo "Building the Maven project..."
mvn clean package

# Create a working directory within the Jenkins workspace
mkdir -p $DOCKER_WORKDIR

# Copy project files and Dockerfile to the new working directory
cp -r $PROJECT_DIR/* $DOCKER_WORKDIR/
cp $DOCKERFILE_DIR/Dockerfile $DOCKER_WORKDIR/

# Verify Dockerfile exists in the working directory
if [ ! -f "$DOCKER_WORKDIR/Dockerfile" ]; then
    echo "Error: Dockerfile was not copied correctly to $DOCKER_WORKDIR"
    exit 1
fi

# Navigate to the new working directory
cd $DOCKER_WORKDIR

# Login to Docker registry using credentials from Jenkins
echo "Logging into Docker registry..."
echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin

# Build Docker image
echo "Building Docker image..."
docker build -f Dockerfile -t ${DOCKER_REPO}/${IMAGE_NAME}:${IMAGE_TAG} .

# Push Docker image to the repository
echo "Pushing Docker image to repository..."
docker push ${DOCKER_REPO}/${IMAGE_NAME}:${IMAGE_TAG}

# Print the status message
echo "Build and push process completed successfully."
