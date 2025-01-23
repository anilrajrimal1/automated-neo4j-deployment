#!/bin/bash
set -ex

# Create a 4GB swap file
fallocate -l 4G /swapfile # Manual entry for now
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo "/swapfile none swap sw 0 0" >> /etc/fstab

echo "Waiting for /srv/Projects to be mounted..."
# Wait for the EBS volume to be mounted
count=0
while [ ! -d "/srv/Projects" ] && [ $count -lt 30 ]; do
    sleep 2
    count=$((count + 1))
done

if [ ! -d "/srv/Projects" ]; then
    echo "Error: /srv/Projects not mounted after 60 seconds"
    exit 1
fi

#DockerData Default Directory Setup
sudo mkdir -p /srv/Projects/DockerData
sudo systemctl stop docker
echo '{"data-root": "/srv/Projects/DockerData"}' > /etc/docker/daemon.json
sudo systemctl start docker