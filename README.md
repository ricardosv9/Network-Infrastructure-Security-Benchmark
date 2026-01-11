# Network-Infrastructure-Security-Benchmark
Estudio comparativo de rendimiento de Proxies Inversos (Nginx, HAProxy, ATS) e implementación de Inspección TLS (SSL-Bump) mediante Squid. Incluye automatización de despliegue en Bash, microservicios en Python Flask y benchmarking de RPS.

Este repositorio contiene el desarrollo y análisis de una infraestructura de red avanzada, centrada en la implementación de Proxies Inversos con terminación SSL, balanceo de carga, caché y seguridad perimetral mediante inspección TLS.

## 🚀 Descripción del Proyecto
El objetivo es evaluar y comparar el rendimiento de diferentes soluciones de proxying (**Nginx, HAProxy, Apache Traffic Server**) y asegurar el tráfico mediante **Squid (SSL-Bump)** El proyecto incluye la automatización completa del despliegue y un set de pruebas de benchmarking para medir Peticiones por Segundo (RPS).

## 📂 Estructura del Repositorio
**`/scripts`**: Contiene los scripts de automatización en Bash para instalación, configuración y ejecución del benchmark.
**`/backend`**: Servidores Flask en Python que actúan como origen y validan la gestión de caché.
* **`/docs`**: Documentación técnica detallada y memoria del proyecto .

## 🛠️ Requisitos e Instalación
Se requiere un entorno Linux con **Python3** y **pip** instalados.

bash
# 1. Instalar la dependencia para los servidores backend
sudo pip install Flask

# 2. Dar permisos de ejecución a todos los scripts
sudo chmod +x ./scripts/*.sh

🚦 Guía de Ejecución
0. Preparación de Servidores Backend
El escenario utiliza dos servidores backend en Python (Flask) que responden en HTTP e incluyen cabeceras 'Cache-Control'. Deben ejecutarse en terminales separadas para monitorizar sus logs:
Servidor 1 (Puerto 8001): python3 ./backend/server1.py 
Servidor 2 (Puerto 8002): python3 ./backend/server2.py 

1. Configuración de Seguridad e Infraestructura
Ejecute los scripts en el siguiente orden según su escenario de prueba:
Generar Certificados Proxies: sudo ./scripts/generar_certificado.sh 
Instalación Nginx (Código Fuente): sudo ./scripts/compilar_nginx.sh y sudo ./scripts/configurar_nginx_TLS.sh 
Configurar HAProxy: sudo ./scripts/configurar_haproxy_TLS.sh 
Configurar ATS: sudo ./scripts/configurar_atsTLS.sh 
Seguridad SSL-Bump (Squid): sudo ./scripts/squid_ssl.sh 

2. Ejecución de Benchmarks (Escenario de Rendimiento)
Para iniciar la comparativa de eficiencia y métricas de RPS:

Bash

sudo ./scripts/parte2.sh
3. Gestión de Bloqueos y Auditoría

Filtrado de Clientes (Escenario 1): sudo ./scripts/bloqueo3.sh 


Reportes de Tráfico (SARG): sudo ./scripts/instalar_sarg.sh 

🧹 Desinstalación
Para limpiar el entorno y eliminar todas las configuraciones aplicadas:

Bash
sudo ./scripts/desinstalar_todo.sh

Autor: Ricardo Sanabria Vega
Fecha: Diciembre 2025
