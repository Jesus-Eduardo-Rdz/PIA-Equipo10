#!/bin/bash

# Verificar si se proporciona un argumento
if [ -z "$1" ]; then
    echo "Por favor, proporciona una dirección IP o dominio para escanear."
    echo "Uso: $0 <dirección IP o dominio>"
    exit 1
fi

# Guardar el arguemento en una variable
IP=$1

# Comprobar si Nmap está instalado para ver los puertos
if ! command -v nmap &> /dev/null; then
    echo "Error, Nmap no esta instalado."
    exit 1
fi

# Comprobar si Nikto está instalado para ver las vulnerabilidades en webs de codigo abiero
if ! command -v nikto &> /dev/null; then
    echo "Error, Nikto no esta instalado."
    exit 1
fi

# Menu principal
while true; do
    echo "		Menu
		1. Escaneo de puertos
		2. Encontrar vulnerabilidades
		3. Probar conexiones
		4. Salir"
    read -p "Elija una opcion: " op

    case $op in
        1)
            # Escaneamos puertos abiertos usando Nmap
            echo "Iniciando escaneo de puertos abiertos en $IP..."
            nmap -p- --open $IP
            echo "Escaneo de puertos completado."
            ;;

        2)
            # Buscamos vulnerabilidades web en el objetivo usando Nikto
            echo "Realizando un escaneo basico de seguridad web con Nikto en $IP..."
            nikto -h "[$IP]"
            echo "Escaneo de vulnerabilidades web completado."
            ;;

        3)
            # Probamos la conexion al puerto 80
            echo "Verificando si el puerto 80 está abierto en $IP..."
            nc -zv $IP 80
            echo "Conexion al puerto 80 completada."
            ;;

        4)
            echo "Saliendo..."
            exit 0
            ;;

        *)
            echo "Opcion no valida. Por favor, seleccione una opcion del 1 al 4."
            ;;
    esac
done
