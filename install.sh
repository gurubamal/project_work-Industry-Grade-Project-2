#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Set environment variables
DOCKER_REPO='gurubamal'
IMAGE_NAME='iyztechnologies'
IMAGE_TAG='latest'
WORKSPACE_DIR='/var/lib/jenkins/workspace'
PROJECT_DIR="$WORKSPACE_DIR/project2/XYZ_Technologies"
DOCKER_WORKDIR="$WORKSPACE_DIR/project2"

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
if [ ! -f "$DOCKER_WORKDIR/Dockerfile" ]; then
    echo "Error: Dockerfile not found in $DOCKER_WORKDIR"
    exit 1
fi

# Navigate to the directory containing the pom.xml file
cd $PROJECT_DIR

# Build the application using Maven
echo "Building the Maven project..."
mvn clean package

# Create a working directory within the project directory
echo "Creating working directory $DOCKER_WORKDIR/docker_project"
mkdir -p $DOCKER_WORKDIR/docker_project

# Verify working directory creation
if [ ! -d "$DOCKER_WORKDIR/docker_project" ]; then
    echo "Error: Failed to create directory $DOCKER_WORKDIR/docker_project"
    exit 1
fi

# List the directory to check creation
echo "Directory listing of $DOCKER_WORKDIR/docker_project:"
ls -l $DOCKER_WORKDIR/docker_project

# Copy project files and Dockerfile to the new working directory
echo "Copying project files to $DOCKER_WORKDIR/docker_project"
cp -r $PROJECT_DIR/* $DOCKER_WORKDIR/docker_project/
cp $DOCKER_WORKDIR/Dockerfile $DOCKER_WORKDIR/docker_project/

# Verify Dockerfile exists in the working directory
if [ ! -f "$DOCKER_WORKDIR/docker_project/Dockerfile" ]; then
    echo "Error: Dockerfile was not copied correctly to $DOCKER_WORKDIR/docker_project"
    echo "Directory listing of $DOCKER_WORKDIR/docker_project:"
    ls -l $DOCKER_WORKDIR/docker_project
    exit 1
fi

# Verify copied files in working directory
echo "Directory listing of $DOCKER_WORKDIR/docker_project:"
ls -l $DOCKER_WORKDIR/docker_project

# Create a .dockerignore file to ignore unnecessary files
echo "Creating .dockerignore file"
echo "target" > $DOCKER_WORKDIR/docker_project/.dockerignore

# Verify .dockerignore exists in the working directory
if [ ! -f "$DOCKER_WORKDIR/docker_project/.dockerignore" ]; then
    echo "Error: .dockerignore was not created correctly in $DOCKER_WORKDIR/docker_project"
    echo "Directory listing of $DOCKER_WORKDIR/docker_project:"
    ls -l $DOCKER_WORKDIR/docker_project
    exit 1
fi

# Navigate to the new working directory
cd $DOCKER_WORKDIR/docker_project

# Login to Docker registry using credentials from Jenkins
echo "Logging into Docker registry..."
echo $DOCKER_PASSWORD | sudo docker login -u $DOCKER_USERNAME --password-stdin

# Build Docker image with elevated permissions
echo "Building Docker image..."
sudo docker build -t ${DOCKER_REPO}/${IMAGE_NAME}:${IMAGE_TAG} .

# Push Docker image to the repository with elevated permissions
echo "Pushing Docker image to repository..."
sudo docker push ${DOCKER_REPO}/${IMAGE_NAME}:${IMAGE_TAG}

# Print the status message
echo "Build and push process completed successfully."
