#!/bin/bash
set -e
BACKEND_IP="192.168.70.132"
PEM_FILE="/etc/haproxy/selfsigned.pem"
CONFIG_FILE="/etc/haproxy/haproxy.cfg"

echo "--- 1. Deteniendo otros proxies ---"
systemctl stop nginx 2>/dev/null || true
/usr/local/nginx/sbin/nginx -s stop 2>/dev/null || true
systemctl stop trafficserver 2>/dev/null || true

echo "--- 2. INSTALANDO E INICIANDO HAPROXY ---"
sudo apt install -y haproxy


echo "--- 2. Creando el archivo .pem para HAProxy ---"
# Junta la clave y el certificado en un solo archivo
sudo cat /etc/ssl/private/selfsigned.key /etc/ssl/certs/selfsigned.crt | sudo tee $PEM_FILE > /dev/null

echo "--- 3. Creando configuración LIMPIA de HAProxy ---"
# Usamos '>' (sobrescribir) para evitar duplicados
sudo cat <<EOF > $CONFIG_FILE
global
    log /dev/log    local0
    daemon
defaults
    log     global
    mode    http
    timeout connect 5000
    timeout client  50000
    timeout server  50000

# --- Frontend con TLS ---
frontend https_frontal
    bind *:443 ssl crt $PEM_FILE
    mode http
    default_backend servidores_web

# --- Backend a la VM 2 ---
backend servidores_web
    mode http
    balance roundrobin
    server srv1 ${BACKEND_IP}:8001 check
    server srv2 ${BACKEND_IP}:8002 check
EOF

echo "--- 4. Comprobando y Reiniciando HAProxy ---"
sudo haproxy -c -f $CONFIG_FILE
sudo systemctl restart haproxy

echo "--- ¡HAProxy con TLS configurado! ---"
echo "Prueba con: curl -k https://127.0.0.1"
