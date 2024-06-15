#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Set environment variables from Jenkins
DOCKER_REPO='gurubamal'
IMAGE_NAME='iyztechnologies'
IMAGE_TAG='latest'
WORKSPACE_DIR='/var/lib/jenkins/workspace'
PROJECT_DIR="$WORKSPACE_DIR/project2/XYZ_Technologies"
DOCKER_WORKDIR="$WORKSPACE_DIR/project2/docker_project"

# Fix broken or missing repositories
sudo rm -f /etc/apt/sources.list.d/kubernetes.list

# Install necessary tools
echo "Installing tools..."
sudo apt-get update
sudo apt-get install -y maven

# Print versions for verification
mvn -v

# Build Maven project
cd $PROJECT_DIR
echo "Building the Maven project..."
mvn clean package

# Prepare Docker build context
echo "Creating Docker build context..."
mkdir -p $DOCKER_WORKDIR
cp -r $PROJECT_DIR/* $DOCKER_WORKDIR/
cp $WORKSPACE_DIR/project2/Dockerfile $DOCKER_WORKDIR/

# Verify Dockerfile exists in the working directory
if [ ! -f "$DOCKER_WORKDIR/Dockerfile" ]; then
    echo "Error: Dockerfile was not copied correctly to $DOCKER_WORKDIR"
    exit 1
fi

# Create a .dockerignore file
echo "Creating .dockerignore file"
echo "target" > $DOCKER_WORKDIR/.dockerignore

# Build Docker image
cd $DOCKER_WORKDIR
echo "Building Docker image..."
docker build -t ${DOCKER_REPO}/${IMAGE_NAME}:${IMAGE_TAG} .

echo "Docker image build completed successfully."
