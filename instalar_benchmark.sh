#!/bin/bash
set -e

echo "--- Actualizando la lista de paquetes ---"
apt update

echo "--- Instalando apache2-utils (que incluye la herramienta 'ab') ---"
apt install -y apache2-utils

echo "--- ¡'ab' (Apache Bench) instalado con éxito! ---"
echo "Verificando la versión (deberías ver 'This is ApacheBench...'):"
ab -V
