#!/bin/bash
set -e

VERSION="1.28.0"
DOWNLOAD_URL="http://nginx.org/download/nginx-${VERSION}.tar.gz"

echo "--- 1. Preparando el sistema ---"
# Detenemos y eliminamos la versión de apt por si existe
systemctl stop nginx 2>/dev/null || true
apt remove nginx nginx-common -y

# Instalamos las herramientas de compilación y dependencias
echo "--- 2. Instalando dependencias ---"
apt update
apt install -y build-essential libpcre3-dev zlib1g-dev libssl-dev

# Nos movemos al directorio /usr/src, un buen lugar para compilar
cd /usr/src

echo "--- 3. Descargando Nginx ${VERSION} ---"
wget -O nginx.tar.gz ${DOWNLOAD_URL}

echo "--- 4. Descomprimiendo ---"
tar -zxvf nginx.tar.gz
cd nginx-${VERSION}

echo "--- 5. Configurando la compilación (con TLS) ---"
./configure --with-http_ssl_module --with-http_v2_module

echo "--- 6. Compilando Nginx ---"
make

echo "--- 7. Instalando Nginx ---"
make install

echo "--- ¡Nginx ${VERSION} compilado e instalado! ---"
echo " "
echo "Configuración: /usr/local/nginx/conf/nginx.conf"
echo "Para iniciarlo: sudo /usr/local/nginx/sbin/nginx"
echo "Para detenerlo: sudo /usr/local/nginx/sbin/nginx -s stop"
