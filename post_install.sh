#!/bin/bash

# Atualização de pacotes
apt update && apt upgrade -y

# Instala dependências
apt install -y docker.io docker-compose nginx certbot python3-certbot-nginx ufw curl

# Inicia o Docker
systemctl start docker
systemctl enable docker

# Cria rede Docker
docker network create portainer_network

# Inicia o Portainer
docker volume create portainer_data
docker run -d \
  --name=portainer \
  --restart=always \
  -p 9000:9000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  --network=portainer_network \
  portainer/portainer-ce

# Configura Nginx para redirecionar para Portainer
cat > /etc/nginx/sites-available/portainer <<EOL
server {
    listen 80;
    server_name portainer.elladan.com.br;

    location / {
        proxy_pass http://localhost:9000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOL

ln -s /etc/nginx/sites-available/portainer /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx

# Obtém certificado SSL
certbot --nginx -d portainer.elladan.com.br --non-interactive --agree-tos -m erickmalta100@gmail.com

# Recarrega Nginx com SSL
systemctl reload nginx

# Habilita o firewall
ufw allow OpenSSH
ufw allow 'Nginx Full'
ufw --force enable
