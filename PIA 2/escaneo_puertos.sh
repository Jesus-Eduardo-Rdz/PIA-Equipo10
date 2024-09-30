#!/bin/bash

# Función para validar la dirección IP
validar_ip() {
    if [[ ! "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "Formato de dirección IP no válido."
        exit 1
    fi
}

# Función para escanear puertos
escanear_puertos() {
    local IP_OBJETIVO=$1
    local PUERTO_INICIO=$2
    local PUERTO_FIN=$3

    echo "Escaneando puertos abiertos en $IP_OBJETIVO desde el puerto $PUERTO_INICIO hasta el puerto $PUERTO_FIN..."

    for ((puerto=$PUERTO_INICIO; puerto<=$PUERTO_FIN; puerto++)); do
        nc -zv -w 1 $IP_OBJETIVO $puerto 2>&1 | grep succeeded
    done

    echo "Escaneo de puertos completado."
}

# Menú principal
while true; do
    echo "           Menu    
    	  1. Iniciar escaneo de puertos
    	  2. Generar informe de escaneo
          3. Salir"
    echo "Elige una opción:"
    read -r OP

    case $OP in
        1)
            # Entrada de la dirección IP
            echo "Introduce la dirección IP objetivo:"
            read -r IP_OBJETIVO
            validar_ip "$IP_OBJETIVO"

            # Entrada del rango de puertos
            echo "Introduce el puerto de inicio (por defecto 1):"
            read -r PUERTO_INICIO
            PUERTO_INICIO=${PUERTO_INICIO:-1}

            echo "Introduce el puerto final (por defecto 1000):"
            read -r PUERTO_FIN
            PUERTO_FIN=${PUERTO_FIN:-1000}

            # Manejo de errores para el rango de puertos
            if [[ "$PUERTO_INICIO" -lt 1 || "$PUERTO_FIN" -gt 65535 || "$PUERTO_INICIO" -gt "$PUERTO_FIN" ]]; then
                echo "Rango de puertos no válido. Por favor, introduce un rango válido (1-65535)."
                continue
            fi

            # Realizar el escaneo de puertos
            escanear_puertos "$IP_OBJETIVO" "$PUERTO_INICIO" "$PUERTO_FIN"
            ;;

        2)
            # Generar informe de escaneo
            ARCHIVO_INFORME="informe_escaneo_puertos_$(date +%Y%m%d%H%M%S).txt"
            echo "Introduce la dirección IP objetivo para el informe:"
            read -r IP_OBJETIVO
            validar_ip "$IP_OBJETIVO"

            echo "Introduce el puerto de inicio (por defecto 1):"
            read -r PUERTO_INICIO
            PUERTO_INICIO=${PUERTO_INICIO:-1}

            echo "Introduce el puerto final (por defecto 1000):"
            read -r PUERTO_FIN
            PUERTO_FIN=${PUERTO_FIN:-1000}

            echo "Generando informe..."
            echo "Informe de escaneo de puertos para $IP_OBJETIVO" > "$ARCHIVO_INFORME"
            echo "Escaneo de puertos desde $PUERTO_INICIO hasta $PUERTO_FIN" >> "$ARCHIVO_INFORME"
            
            for ((puerto=$PUERTO_INICIO; puerto<=$PUERTO_FIN; puerto++)); do
                nc -zv -w 1 $IP_OBJETIVO $puerto 2>&1 | grep succeeded >> "$ARCHIVO_INFORME"
            done

            echo "Informe guardado en $ARCHIVO_INFORME"
            ;;

        3)
            echo "Saliendo..."
            exit 0
            ;;

        *)
            echo "Opción no válida. Elige 1, 2 o 3."
            ;;
    esac
done
