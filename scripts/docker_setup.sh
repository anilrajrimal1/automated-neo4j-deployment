#!/bin/bash
set -ex

# Install required packages
apt-get update
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Create docker group and add ubuntu user
groupadd -f docker
usermod -aG docker ubuntu

# Create docker config directory
mkdir -p /home/ubuntu/.docker
chown ubuntu:ubuntu /home/ubuntu/.docker
chmod 700 /home/ubuntu/.docker

# Start and enable Docker service
systemctl enable docker
systemctl start docker

# Set socket permissions
chmod 666 /var/run/docker.sock