#!/bin/bash

SQUID_DIR="/etc/squid"
LISTS_DIR="$SQUID_DIR/lists/clients"
CONF_FILE="$SQUID_DIR/squid_blocking_clients.conf"

mkdir -p "$LISTS_DIR"
touch "$CONF_FILE"

echo "=============================="
echo "   SISTEMA DE BLOQUEO SQUID"
echo "=============================="
echo ""
echo -n "Introduce la IP del cliente (o 'localhost'): "
read CLIENT

if [[ "$CLIENT" == "localhost" ]]; then
    SRC_IP="127.0.0.1"
elif [[ "$CLIENT" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    SRC_IP="$CLIENT"
else
    echo "IP inválida."
    exit 1
fi

CLIENT_DIR="$LISTS_DIR/$CLIENT"
mkdir -p "$CLIENT_DIR"

# Crear todos los .txt
for file in urls domains categories extensions time; do
    touch "$CLIENT_DIR/$file.txt"
done

ACL="pc_${CLIENT//./_}"

# ============================
# COMPROBAR SI YA EXISTE EN CONF
# ============================

if ! grep -q "$ACL" "$CONF_FILE"; then
    cat >> "$CONF_FILE" <<EOF

# ---- $CLIENT ----
acl $ACL src $SRC_IP

acl url_$ACL url_regex "$CLIENT_DIR/urls.txt"
acl dom_$ACL dstdomain "$CLIENT_DIR/domains.txt"
acl cat_$ACL url_regex "$CLIENT_DIR/categories.txt"
acl ext_$ACL urlpath_regex "$CLIENT_DIR/extensions.txt"
acl time_$ACL time "/etc/squid/lists/clients/$CLIENT/time.txt"

http_access deny $ACL url_$ACL
http_access deny $ACL dom_$ACL
http_access deny $ACL cat_$ACL
http_access deny $ACL ext_$ACL
http_access deny $ACL time_$ACL
EOF
fi

# ============================
# MENÚ
# ============================

while true; do
    echo ""
    echo "========= MENÚ ========="
    echo "1) Bloquear por URL"
    echo "2) Bloquear por dominio"
    echo "3) Bloquear por categoría (en desarrollo)"
    echo "4) Bloquear descargas por extensión"
    echo "5) Ver reglas"
    echo "6) Borrar UNA regla"
    echo "7) Borrar TODAS las reglas"
    echo "8) PRUEBA SSL-BUMP"
    echo "9) Salir"
    echo "=========================="
    echo -n "Opción: "
    read op

    case "$op" in
        
        1)
            echo -n "URL o patrón a bloquear: "
            read P
            echo "$P" >> "$CLIENT_DIR/urls.txt"
        ;;

        2)
            echo -n "Dominio (ej: .facebook.com): "
            read D
            echo "$D" >> "$CLIENT_DIR/domains.txt"
        ;;

        3)
            echo -n "Categoría (ej: casino): "
            read C
            
            echo ".*$C.*" >> "$CLIENT_DIR/categories.txt"
        ;;

        4)
            echo -n "Extensión sin punto (ej: exe): "
            read E
            echo "\.${E}$" >> "$CLIENT_DIR/extensions.txt"
        ;;

        5)
            echo "---- Reglas de $CLIENT ----"
            for f in urls domains categories extensions time; do
                echo "[$f]"
                cat "$CLIENT_DIR/$f.txt"
                echo ""
            done
        ;;

        6)
            echo "¿En qué lista quieres borrar?"
            echo "1) URLs"
            echo "2) Dominios"
            echo "3) Categorías"
            echo "4) Extensiones"
            read sub

            case "$sub" in
                1) FILE="$CLIENT_DIR/urls.txt" ;;
                2) FILE="$CLIENT_DIR/domains.txt" ;;
                3) FILE="$CLIENT_DIR/categories.txt" ;;
                4) FILE="$CLIENT_DIR/extensions.txt" ;;
                *) echo "Opción inválida."; continue ;;
            esac

            echo "Contenido:"
            nl -ba "$FILE"

            echo -n "Número a borrar: "
            read NUM
            sed -i "${NUM}d" "$FILE"
            echo "Línea borrada."
        ;;

        7)
            echo "Limpiando todas las reglas..."
            > "$CLIENT_DIR/urls.txt"
            > "$CLIENT_DIR/domains.txt"
            > "$CLIENT_DIR/categories.txt"
            > "$CLIENT_DIR/extensions.txt"
            > "$CLIENT_DIR/time.txt"
        ;;

        8)
            echo -n "Introduce URL HTTPS: "
            read URL
            echo
            echo "========== CONTENIDO INTERCEPTADO =========="
            curl -x http://127.0.0.1:3128 "$URL"
            echo "---------------------------------------------"
            
        ;;

        9)
            echo "Saliendo..."
            break
        ;;

        *)
            echo "Opción inválida."
        ;;
    esac

    systemctl reload squid
done
