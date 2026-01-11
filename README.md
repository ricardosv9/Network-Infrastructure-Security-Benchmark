# Network-Infrastructure-Security-Benchmark
Estudio comparativo de rendimiento de Proxies Inversos (Nginx, HAProxy, ATS) e implementación de Inspección TLS (SSL-Bump) mediante Squid. Incluye automatización de despliegue en Bash, microservicios en Python Flask y benchmarking de RPS.

Este repositorio contiene el desarrollo y análisis de una infraestructura de red avanzada, centrada en la implementación de Proxies Inversos con terminación SSL, balanceo de carga, caché y seguridad perimetral mediante inspección TLS.

## 🚀 Descripción del Proyecto
El objetivo es evaluar y comparar el rendimiento de diferentes soluciones de proxying (**Nginx, HAProxy, Apache Traffic Server**) y asegurar el tráfico mediante **Squid (SSL-Bump)** El proyecto incluye la automatización completa del despliegue y un set de pruebas de benchmarking para medir Peticiones por Segundo (RPS).

## 📊 Evidencias y Resultados

Para validar la infraestructura, se han realizado pruebas de rendimiento y seguridad cuyos resultados se detallan a continuación:

### ⚡ Benchmarking de Rendimiento (RPS)
* [cite_start]**Nginx y HAProxy (Modo Pass-through):** Operando como balanceadores de carga y terminadores SSL, ambos mostraron un rendimiento sólido y consistente[cite: 6]. [cite_start]Su velocidad en este escenario está vinculada a la capacidad de respuesta de los servidores backend en Python Flask, ya que actúan como intermediarios directos del tráfico[cite: 2, 5].
* [cite_start]**Apache Traffic Server (ATS) (Modo Caché):** Alcanzó picos superiores a los **10,000 RPS** al operar con **caché caliente (HIT)**[cite: 6]. [cite_start]Este resultado resalta la eficiencia extrema de ATS para servir contenido estático directamente desde memoria RAM, eliminando el cuello de botella que supone la latencia de red hacia el servidor de origen[cite: 6].

![Resultados del Benchmark](img/benchmark_graph.png)
*Comparativa de Peticiones por Segundo (RPS) entre ATS, HAProxy y Nginx.*

### 🛡️ Inspección de Tráfico y Seguridad (SSL-Bump)
Implementación exitosa de interceptación TLS mediante **Squid**, permitiendo la visibilidad del contenido cifrado para auditoría y filtrado.

![Prueba SSL-Bump](img/ssl_intercept_proof.png)
*Captura del contenido interceptado de una URL HTTPS mediante la CA propia.*

### 🚫 Control de Acceso y Filtrado Perimetral
Demostración del sistema de filtrado granular. Se muestra el estado original del sitio y el bloqueo efectivo aplicado por el proxy.

| Estado Original | Acceso Denegado |
| :---: | :---: |
| ![Sitio Original](img/target_site_original.png) | ![Acceso Bloqueado](img/access_denied_evidence.png) |
| *Acceso normal al sitio objetivo.* | *Bloqueo perimetral mediante Squid.* |

### 🛠️ Interfaz de Gestión
Menú interactivo desarrollado en Bash para facilitar la administración de reglas de firewall y monitoreo de logs en tiempo real.

![Menú de Gestión](img/squid_management_menu.png)

*Herramienta interactiva para la administración de la infraestructura.*

## 📂 Estructura del Repositorio
**`/scripts`**: Contiene los scripts de automatización en Bash para instalación, configuración y ejecución del benchmark.

**`/backend`**: Servidores Flask en Python que actúan como origen y validan la gestión de caché.

**`/docs`**: Documentación técnica detallada y memoria del proyecto .

## 🛠️ Requisitos e Instalación
Se requiere un entorno Linux con **Python3** y **pip** instalados.

# 1. Instalar la dependencia para los servidores backend
sudo apt install python3-flask

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

sudo ./scripts/parte2.sh

3. Gestión de Bloqueos y Auditoría
   

Filtrado de Clientes (Escenario 1): sudo ./scripts/bloqueo3.sh 

Reportes de Tráfico (SARG): sudo ./scripts/instalar_sarg.sh 


🧹 Desinstalación

Para limpiar el entorno y eliminar todas las configuraciones aplicadas:

sudo ./scripts/desinstalar_todo.sh

Autor: Ricardo Sanabria Vega

Fecha: Diciembre 2025
