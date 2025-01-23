#!/bin/bash
set -ex

# Wait for Docker to be ready
count=0
while ! docker info >/dev/null 2>&1; do
    if [ $count -gt 30 ]; then
        echo "Error: Docker not ready after 60 seconds"
        exit 1
    fi
    echo "Waiting for Docker to be ready..."
    sleep 2
    count=$((count + 1))
done

# Create Neo4j directory (Project Dir)
mkdir -p /srv/Projects/neo4j/

# Create docker-compose file
cat <<EOF > /srv/Projects/neo4j/docker-compose.yml
services:
  neo4j:
    image: neo4j:latest
    restart: always
    volumes:
      - ./logs:/logs
      - ./config:/config
      - ./data:/data
      - ./plugins:/plugins
    ports:
      - "7474:7474"
      - "7687:7687"
    environment:
      - NEO4J_AUTH=neo4j/KybyEY8c3ab3zoj # User/Password
EOF

cd /srv/Projects/neo4j/
docker compose up -d