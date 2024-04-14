# Use an official Maven image from the Docker Hub as a parent image
FROM maven:3.6.3-jdk-11-slim AS build

# Set the working directory in the Docker container
WORKDIR /app

# Copy the Java Source code and other necessary files into the Docker image
COPY src /app/src
COPY pom.xml /app

# Build the application using Maven
RUN mvn clean package

# Use Tomcat official image for running the webapp
FROM tomcat:9.0-jdk11-openjdk-slim

# Remove default web applications deployed with Tomcat
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the WAR file from the Maven image
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

# Expose port 8080 to the outside world
EXPOSE 8080

# Set the default command to run on container startup
CMD ["catalina.sh", "run"]

