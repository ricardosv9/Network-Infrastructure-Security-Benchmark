#!/bin/bash
set -e

# --- VARIABLE DE CONFIGURACIÓN DEL LABORATORIO ---
BACKEND_IP="192.168.70.132"
RECORDS_CONF="/etc/trafficserver/records.config"
REMAP_CONF="/etc/trafficserver/remap.config"
CERT_PATH="/etc/ssl/certs/"   # Directorio donde está selfsigned.crt
KEY_PATH="/etc/ssl/private/"  # Directorio donde está selfsigned.key
KEY_FILE="${KEY_PATH}selfsigned.key" # Ruta completa de la clave

echo "--- 1. Deteniendo otros proxies ---"
sudo systemctl stop haproxy 2>/dev/null || true
sudo systemctl stop nginx 2>/dev/null || true
/usr/local/nginx/sbin/nginx -s stop 2>/dev/null || true
sudo systemctl stop trafficserver 2>/dev/null || true

echo "--- 2. Instalando Traffic Server (Si no está) ---"
sudo apt install trafficserver -y

echo "--- 3. Configurando TLS en records.config (Puerto y ACTIVACIÓN) ---"
# Establecer el puerto 443 para HTTPS.
sudo sed -i.bak 's/CONFIG proxy.config.http.server_ports STRING .*/CONFIG proxy.config.http.server_ports STRING 443:ssl/' $RECORDS_CONF

# 3a. ACTIVACIÓN GLOBAL DE SSL (CRÍTICO)
sudo sed -i '/CONFIG proxy.config.ssl.enabled/d' $RECORDS_CONF
echo "CONFIG proxy.config.ssl.enabled INT 1" | sudo tee -a $RECORDS_CONF

# 3b. CONFIGURACIÓN DE PROTOCOLOS (Para evitar errores de handshake)
sudo sed -i '/CONFIG proxy.config.ssl.server.protocols/d' $RECORDS_CONF
echo "CONFIG proxy.config.ssl.server.protocols STRING TLSv1_2,TLSv1_3" | sudo tee -a $RECORDS_CONF

# Configurar la ruta base a los certificados y claves 
sudo sed -i '/CONFIG proxy.config.ssl.server.cert.path/d' $RECORDS_CONF
echo "CONFIG proxy.config.ssl.server.cert.path STRING $CERT_PATH" | sudo tee -a $RECORDS_CONF
sudo sed -i '/CONFIG proxy.config.ssl.server.private_key.path/d' $RECORDS_CONF
echo "CONFIG proxy.config.ssl.server.private_key.path STRING $KEY_PATH" | sudo tee -a $RECORDS_CONF


echo "--- 4. Configurando certificado en ssl_multicert.config ---"
# crucial para que ATS sepa qué certificado usar para la terminación SSL.
SSL_MULTICERT="/etc/trafficserver/ssl_multicert.config"
sudo cat <<EOF > $SSL_MULTICERT
dest_ip=* ssl_cert_name=selfsigned.crt ssl_key_name=selfsigned.key
EOF


echo "--- 5. Configurando el mapeo en remap.config (HTTPS -> HTTP) ---"
echo "map https://127.0.0.1/ http://${BACKEND_IP}:8001/" | sudo tee $REMAP_CONF


echo "--- 6. Aplicando Permisos de Clave y Directorio (Correcciones de Acceso) ---"
# 6a. Permiso de lectura para el grupo 'trafficserver' en el archivo de la clave
sudo chown :trafficserver "$KEY_FILE" 2>/dev/null || true
sudo chmod g+r "$KEY_FILE" 2>/dev/null || true
# 6b. Permiso de acceso (ejecución) para 'otros' en el directorio privado
sudo chmod o+x "$KEY_PATH" 2>/dev/null || true


echo "--- 7. Reiniciando Traffic Server para aplicar cambios ---"
sudo systemctl restart trafficserver

echo "--- ✅ ¡ATS con TLS configurado! ---"
echo "Prueba con: curl -k https://127.0.0.1"
