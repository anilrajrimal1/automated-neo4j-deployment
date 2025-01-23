#!/bin/bash
set -ex

# Install NGINX
apt-get update
apt-get install -y nginx

# Remove default nginx site
sudo rm -rf /etc/nginx/sites-enabled/default
sudo rm -rf /etc/nginx/sites-available/default

# Configure NGINX for Neo4j
cat <<'EOF' > /etc/nginx/conf.d/neo4j.conf
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name neo4j.anilrajrimal.com.np;

    location / {
        proxy_pass http://localhost:7474;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_cache_bypass $http_upgrade;

        proxy_connect_timeout 60s;
        proxy_read_timeout 60s;
        proxy_send_timeout 60s;
        proxy_buffer_size 128k;
        proxy_buffers 4 256k;
        proxy_busy_buffers_size 256k;
        proxy_temp_file_write_size 256k;
    }
}
EOF

# Test and reload NGINX
sudo nginx -t && sudo nginx -s reload
