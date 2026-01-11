#!/bin/bash

echo "==== INSTALANDO SARG Y APACHE2 ===="
sudo apt update -y
sudo apt install -y sarg apache2

echo "==== CONFIGURANDO SARG ===="

# Rutas de log y salida (solo si existen)
sudo sed -i 's|access_log .*|access_log /var/log/squid/access.log|' /etc/sarg/sarg.conf
sudo sed -i 's|output_dir .*|output_dir /var/www/html/sarg|' /etc/sarg/sarg.conf

# Eliminar opciones incompatibles (como resolve_ip)
sudo sed -i '/resolve_ip/d' /etc/sarg/sarg.conf

echo "==== CREANDO DIRECTORIO DE SARG ===="
sudo mkdir -p /var/www/html/sarg
sudo chown -R $USER:$USER /var/www/html/sarg

echo "==== GENERANDO PRIMER INFORME (si hay logs) ===="
sudo sarg || true

echo "==== REINICIANDO APACHE ===="
sudo systemctl restart apache2 || true

echo ""
echo "============================================================"
echo "  SARG instalado sin tocar Squid."
echo "  Cuando navegues con tu Squid, ejecuta:"
echo "      sudo sarg"
echo "  Y abre:"
echo "      http://localhost/sarg"
echo "============================================================"
echo ""
