#!/bin/bash
set -e
NGINX_PATH="/usr/local/nginx"
BACKEND_IP="192.168.70.132"  
CONFIG_FILE="${NGINX_PATH}/conf/nginx.conf"

echo "--- 1. Deteniendo otros proxies ---"
sudo systemctl stop haproxy 2>/dev/null || true
sudo systemctl stop nginx 2>/dev/null || true
sudo systemctl stop trafficserver 2>/dev/null || true
sudo "${NGINX_PATH}/sbin/nginx" -s stop 2>/dev/null || true

echo "--- 2. Configurando Nginx (desde Fuente) con TLS ---"
sudo cat <<EOF > "${CONFIG_FILE}"
user  www-data;
worker_processes  1;
events {
    worker_connections  1024;
}
http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;

    # --- Backends a la VM 2 ---
    upstream mis_backends {
        server ${BACKEND_IP}:8001;
        server ${BACKEND_IP}:8002;
    }

    # --- Frontend con TLS ---
    server {
        listen       443 ssl;
        server_name  localhost;

        ssl_certificate      /etc/ssl/certs/selfsigned.crt;
        ssl_certificate_key  /etc/ssl/private/selfsigned.key;

        location / {
            proxy_pass http://mis_backends;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }
    }
}
EOF

echo "--- 3. Comprobando sintaxis e iniciando Nginx ---"
sudo "${NGINX_PATH}/sbin/nginx" -t -c "${CONFIG_FILE}"
sudo "${NGINX_PATH}/sbin/nginx" -c "${CONFIG_FILE}"

echo "--- ¡Nginx (desde Fuente) con TLS configurado! ---"
echo "Prueba con: curl -k https://127.0.0.1"
