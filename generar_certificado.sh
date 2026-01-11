#!/bin/bash
set -e

echo "--- 1. Creando directorios SSL (si no existen) ---"
sudo mkdir -p /etc/ssl/private
sudo mkdir -p /etc/ssl/certs

echo "--- 2. Generando certificado autofirmado (válido por 1 año) ---"
# '-subj' rellena los campos automáticamente para que no pregunte nada
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-keyout /etc/ssl/private/selfsigned.key \
-out /etc/ssl/certs/selfsigned.crt \
-subj "/C=ES/ST=Madrid/L=Madrid/O=Prueba/CN=localhost"

echo "--- ¡Certificado y clave generados! ---"
