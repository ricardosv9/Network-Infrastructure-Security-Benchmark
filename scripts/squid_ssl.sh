#!/bin/bash
# ==========================================
#  INSTALADOR COMPLETO SQUID + SSL BUMP
#      Ubuntu 24.04 + SQUID-OPENSSL
#      Compatible PC / Laboratorio
# ==========================================

clear
echo "=========================================="
echo " INSTALADOR COMPLETO SQUID + SSL BUMP"
echo "   Ubuntu 24.04 + SQUID-OPENSSL"
echo "=========================================="

echo "=== INSTALANDO SQUID-OPENSSL ==="
apt update -y
apt install -y squid-openssl openssl ca-certificates

# DETECTAR security_file_certgen
echo "=== DETECTANDO security_file_certgen ==="
if [[ -f /usr/lib/squid/security_file_certgen ]]; then
    CERTGEN="/usr/lib/squid/security_file_certgen"
elif [[ -f /usr/libexec/squid/security_file_certgen ]]; then
    CERTGEN="/usr/libexec/squid/security_file_certgen"
else
    echo " ERROR: security_file_certgen no encontrado."
    exit 1
fi
echo "Detectado: $CERTGEN"

echo "=== CREANDO DIRECTORIOS SSL ==="
mkdir -p /etc/squid/ssl
chmod 700 /etc/squid/ssl

echo "=== GENERANDO CERTIFICADO CA ==="
openssl req -new -newkey rsa:4096 -sha256 -days 3650 -nodes \
  -x509 -keyout /etc/squid/ssl/CA.key \
  -out /etc/squid/ssl/CA.crt \
  -subj "/C=ES/ST=Sevilla/L=Sevilla/O=Proxy/OU=IT/CN=Squid-CA"

chmod 600 /etc/squid/ssl/CA.key
chmod 644 /etc/squid/ssl/CA.crt

echo "=== CREANDO BASE SSL DINÁMICA ==="
rm -rf /var/lib/ssl_db
$CERTGEN -c -s /var/lib/ssl_db -M 4MB
chown -R proxy:proxy /var/lib/ssl_db
chmod -R 700 /var/lib/ssl_db

echo "=== CREANDO ARCHIVO DE BLOQUEO (include) ==="
mkdir -p /etc/squid
touch /etc/squid/squid_blocking_clients.conf
chown proxy:proxy /etc/squid/squid_blocking_clients.conf
chmod 640 /etc/squid/squid_blocking_clients.conf


echo "=== GENERANDO squid.conf ==="
cat > /etc/squid/squid.conf << EOF
# PUERTO ÚNICO CON SSL-BUMP (proxy explícito)
http_port 3128 ssl-bump cert=/etc/squid/ssl/CA.crt key=/etc/squid/ssl/CA.key

# SSL BUMP
acl step1 at_step SslBump1
ssl_bump peek step1
ssl_bump bump all

# BASE DE CERTIFICADOS
sslcrtd_program $CERTGEN -s /var/lib/ssl_db -M 4MB
sslcrtd_children 10 startup=5 idle=3

# LOGS
access_log /var/log/squid/access.log
cache_log /var/log/squid/cache.log

# PERMITIR SOLO LOCALHOST Y RED LOCAL
acl localhost src 127.0.0.1/32
# ACL red del laboratorio (172.16.17.0/24)
acl localnet src 172.16.17.0/24
acl localnet src 192.168.0.0/16
acl localnet src 10.0.0.0/8

# REGLAS DE BLOQUEO 
include "/etc/squid/squid_blocking_clients.conf"

http_access allow localhost
http_access allow localnet

# DENEGAR LO DEMÁS
http_access deny all
EOF

echo "=== INSTALANDO LA CA DE SQUID EN EL SISTEMA ==="
cp /etc/squid/ssl/CA.crt /usr/local/share/ca-certificates/squid-ca.crt
update-ca-certificates

echo "=== REINICIANDO SQUID ==="
systemctl stop squid
sleep 1
systemctl start squid

echo ""
echo "=========================================="
echo " INSTALACIÓN COMPLETA"
echo " CA instalada en el sistema:"
echo "     /usr/local/share/ca-certificates/squid-ca.crt"
echo ""
echo " Puedes usar SSL-Bump en:"
echo "     http://127.0.0.1:3128"
echo ""
echo " En Firefox solo activa:"
echo "     security.enterprise_roots.enabled = true"
echo ""
echo " Comprueba con:"
echo "   curl -x http://127.0.0.1:3128 https://google.com -v"
echo "=========================================="
