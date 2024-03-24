#!/bin/bash

# Update apt
sudo apt update

# Install prerequisites for Docker
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Add Docker repository
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Update apt again
sudo apt update

# Install Docker
sudo apt install -y docker-ce

# Enable and start Docker
sudo systemctl enable docker
sudo systemctl start docker

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Add execute permissions to Docker Compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify Docker Compose installation
docker-compose version
