#!/bin/bash

# Update yum
sudo yum update -y

# Install Docker
sudo yum install -y docker

# Enable and start Docker
sudo systemctl enable docker
sudo systemctl start docker

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Add execute permissions to Docker Compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify Docker Compose installation
docker-compose version
