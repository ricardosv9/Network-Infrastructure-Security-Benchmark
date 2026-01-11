#!/bin/bash
set -e

echo "================================================="
echo "== INICIANDO DESINSTALACIÓN COMPLETA DEL SISTEMA =="
echo "================================================="

# --- 1. DESINSTALACIÓN DE SERVICIOS INSTALADOS POR PAQUETES (apt) ---

echo "--- 1.1 Deteniendo y desinstalando servicios APT (Squid, HAProxy, ATS) ---"

# Detener todos los servicios que usan systemctl
systemctl stop squid 2>/dev/null || true
systemctl stop haproxy 2>/dev/null || true
systemctl stop trafficserver 2>/dev/null || true

# Eliminar paquetes principales y auxiliares con limpieza de configuración (--purge)
apt remove --purge -y squid-openssl haproxy trafficserver python3-flask

# --- 2. LIMPIEZA DE CONFIGURACIÓN Y BASES DE DATOS DE SQUID ---

echo "--- 2.1 Limpiando certificados y bases de datos de Squid ---"

# 1. Eliminar archivos de configuración clave de Squid
sudo rm -f /etc/squid/squid.conf
sudo rm -rf /etc/squid/ssl

# 2. Eliminar la base de datos de certificados generados dinámicamente
sudo rm -rf /var/lib/ssl_db

# 3. Eliminar la Autoridad Certificadora (CA) raíz del sistema
sudo rm -f /usr/local/share/ca-certificates/squid-ca.crt
sudo update-ca-certificates

# --- 3. DESINSTALACIÓN DE SERVICIO INSTALADO POR CÓDIGO FUENTE (Nginx) ---

echo "--- 3.1 Desinstalando Nginx (Compilado) ---"

# 1. Detener el binario compilado de Nginx
/usr/local/nginx/sbin/nginx -s stop 2>/dev/null || true

# 2. Eliminar el directorio de instalación por defecto
sudo rm -rf /usr/local/nginx

# 3. Limpiar archivos de compilación temporal en /usr/src
VERSION="1.28.0"
sudo rm -f /usr/src/nginx.tar.gz
sudo rm -rf /usr/src/nginx-${VERSION}

# --- 4. DESINSTALACIÓN DE HERRAMIENTAS DE BENCHMARKING Y DEPENDENCIAS ---

echo "--- 4.1 Eliminando herramientas de benchmarking (si se instalaron por APT) ---"

# Se asume que 'curl' y 'apache2-utils' (que incluye 'ab') fueron instalados vía APT para los tests.
apt remove -y curl apache2-utils sarg 2>/dev/null || true

# --- 5. LIMPIEZA FINAL DE DEPENDENCIAS ---

echo "--- 5.1 Limpieza final de dependencias innecesarias ---"

# Eliminar las dependencias que ya no son requeridas por ningún paquete
sudo apt autoremove -y

echo "=========================================="
echo "== DESINSTALACIÓN COMPLETA FINALIZADA =="
echo "=========================================="
