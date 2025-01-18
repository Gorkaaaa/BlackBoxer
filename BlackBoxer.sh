#!/bin/bash

NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'

if [ "$#" -ne 1 ]; then
    echo -e "${RED}Uso: ./BlackBoxer.sh [NOMBRE DEL PROGRAMA DE BUG BOUNTY]${NC}"
    exit 1
fi

PROGRAMA="$1"
DIRECTORIO="${PROGRAMA}_results"
ARCHIVO_DOMINIOS="valid_domains.txt"

if [ ! -f "$ARCHIVO_DOMINIOS" ]; then
    echo -e "${RED}Archivo 'valid_domains.txt' no encontrado.${NC}"
    exit 1
fi

mkdir -p "$DIRECTORIO"

function estado {
    echo -e "${BOLD}${CYAN}$1${NC}"
}

function escaneo_tcp {
    ip=$1
    estado "Escaneando TCP en $ip..."
    resultado_tcp=$(nmap -p- -Pn -n -sS --min-rate 500 "$ip" | grep "open" | awk '{print $1, $2, $3}')
    
    if [ -z "$resultado_tcp" ]; then
        echo -e "${GREEN}No se encontraron puertos TCP abiertos en $ip.${NC}"
        echo "No se encontraron puertos TCP abiertos." > "$DIRECTORIO/$ip/tcp_scan.txt"
    else
        echo -e "${YELLOW}Puertos TCP abiertos encontrados en $ip:${NC}"
        echo -e "${BOLD}${resultado_tcp}${NC}" | tee "$DIRECTORIO/$ip/tcp_scan.txt"
    fi
}

function escaneo_udp {
    ip=$1
    estado "Escaneando UDP en $ip..."
    resultado_udp=$(nmap -sU -Pn --top-ports 150 "$ip" | grep "open" | awk '{print $1, $2, $3}')
    
    if [ -z "$resultado_udp" ]; then
        echo -e "${GREEN}No se encontraron puertos UDP abiertos en $ip.${NC}"
        echo "No se encontraron puertos UDP abiertos." > "$DIRECTORIO/$ip/udp_scan.txt"
    else
        echo -e "${YELLOW}Puertos UDP abiertos encontrados en $ip:${NC}"
        echo -e "${BOLD}${resultado_udp}${NC}" | tee "$DIRECTORIO/$ip/udp_scan.txt"
    fi
}

function obtener_ip {
    dominio=$1
    ip=$(dig +short "$dominio" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' | head -n 1)
    echo "$ip"
}

estado "Procesando dominios desde 'valid_domains.txt'..."

declare -A IPS_PROCESADAS

while read dominio; do
    estado "Resolviendo dominio: $dominio"
    ip=$(obtener_ip "$dominio")
    if [ -z "$ip" ]; then
        echo -e "${YELLOW}No se pudo resolver $dominio${NC}"
        continue
    fi

    if [ "${IPS_PROCESADAS[$ip]}" ]; then
        echo -e "${YELLOW}IP $ip ya procesada, omitiendo.${NC}"
        continue
    fi

    IPS_PROCESADAS["$ip"]=1
    mkdir -p "$DIRECTORIO/$ip"
    escaneo_tcp "$ip"
    escaneo_udp "$ip"
done < "$ARCHIVO_DOMINIOS"

estado "El escaneo ha finalizado. Los resultados se encuentran en el directorio '$DIRECTORIO'."
