#!/bin/bash
# Unit X: SSL/TLS Certificates — test.sh
# Automated validation of 10 challenges

set -e
source /shared/common.sh

UNIT_NAME="unit-X"
TOTAL_RETOS=10

reto1() {
    openssl version 2>/dev/null | grep -q "OpenSSL"
}

reto2() {
    cd /root/laboratorio/ssl 2>/dev/null || cd ~
    openssl genrsa -out clave_privada.pem 2048 2>/dev/null
    [ -f clave_privada.pem ]
}

reto3() {
    cd /root/laboratorio/ssl 2>/dev/null || cd ~
    openssl genrsa -out clave_privada.pem 2048 2>/dev/null
    output=$(openssl rsa -in clave_privada.pem -check -noout 2>&1)
    echo "$output" | grep -qi "ok\|valid"
}

reto4() {
    cd /root/laboratorio/ssl 2>/dev/null || cd ~
    openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -days 365 -nodes \
        -subj "/C=EC/ST=Quito/O=Test/CN=localhost" 2>/dev/null
    [ -f cert.pem ] && [ -f key.pem ]
}

reto5() {
    cd /root/laboratorio/ssl 2>/dev/null || cd ~
    openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -days 365 -nodes \
        -subj "/C=EC/ST=Quito/O=Test/CN=localhost" 2>/dev/null
    output=$(openssl x509 -in cert.pem -text -noout 2>/dev/null | head -5)
    echo "$output" | grep -qi "certificate\|subject\|issuer"
}

reto6() {
    cd /root/laboratorio/ssl 2>/dev/null || cd ~
    openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -days 365 -nodes \
        -subj "/C=EC/ST=Quito/O=Test/CN=localhost" 2>/dev/null
    output=$(openssl x509 -in cert.pem -checkend 0 -noout 2>&1)
    echo "$output" | grep -qi "will not expire\|ok"
}

reto7() {
    cd /root/laboratorio/ssl 2>/dev/null || cd ~
    openssl req -new -newkey rsa:2048 -nodes -out request.csr -keyout key_csr.pem \
        -subj "/C=EC/ST=Quito/O=Test/CN=test.com" 2>/dev/null
    [ -f request.csr ] && [ -f key_csr.pem ]
}

reto8() {
    cd /root/laboratorio/ssl 2>/dev/null || cd ~
    openssl req -new -newkey rsa:2048 -nodes -out request.csr -keyout key_csr.pem \
        -subj "/C=EC/ST=Quito/O=Test/CN=test.com" 2>/dev/null
    output=$(openssl req -in request.csr -text -noout 2>/dev/null | head -5)
    echo "$output" | grep -qi "certificate request\|subject"
}

reto9() {
    cd /root/laboratorio/ssl 2>/dev/null || cd ~
    mkdir -p ca
    openssl genrsa -out ca/ca.key 2048 2>/dev/null
    openssl req -x509 -new -nodes -key ca/ca.key -sha256 -days 365 \
        -out ca/ca.crt -subj "/C=EC/O=TestCA/CN=TestCA" 2>/dev/null
    [ -f ca/ca.key ] && [ -f ca/ca.crt ]
}

reto10() {
    cd /root/laboratorio/ssl 2>/dev/null || cd ~
    mkdir -p ca
    openssl genrsa -out ca/ca.key 2048 2>/dev/null
    openssl req -x509 -new -nodes -key ca/ca.key -sha256 -days 365 \
        -out ca/ca.crt -subj "/C=EC/O=TestCA/CN=TestCA" 2>/dev/null
    openssl req -new -newkey rsa:2048 -nodes -out servidor.csr -keyout servidor.key \
        -subj "/C=EC/O=Test/CN=servidor.local" 2>/dev/null
    openssl x509 -req -in servidor.csr -CA ca/ca.crt -CAkey ca/ca.key -CAcreateserial \
        -out servidor.crt -days 365 -sha256 2>/dev/null
    [ -f servidor.crt ] && [ -f servidor.key ]
}

validators=(reto1 reto2 reto3 reto4 reto5 reto6 reto7 reto8 reto9 reto10)
challenge_names=(
    "Verificar openssl"
    "Generar clave privada"
    "Verificar clave privada"
    "Generar certificado autofirmado"
    "Ver detalles del certificado"
    "Verificar validez del certificado"
    "Generar CSR"
    "Ver detalles del CSR"
    "Crear CA local"
    "Firmar certificado con CA"
)

reto1_info() {
    separador
    echo -e "${CYAN}Reto 1: Verificar openssl${NC}"
    echo ""
    echo "Verifica que OpenSSL está instalado en tu sistema."
    echo "Comando útil: openssl version"
    separador
}

reto2_info() {
    separador
    echo -e "${CYAN}Reto 2: Generar clave privada${NC}"
    echo ""
    echo "Genera una clave privada RSA de 2048 bits."
    echo "Guarda el archivo como clave_privada.pem en /root/laboratorio/ssl/"
    echo "Comando útil: openssl genrsa -out clave_privada.pem 2048"
    separador
}

reto3_info() {
    separador
    echo -e "${CYAN}Reto 3: Verificar clave privada${NC}"
    echo ""
    echo "Verifica que tu clave privada es válida y consistente."
    echo "Comando útil: openssl rsa -in clave_privada.pem -check -noout"
    separador
}

reto4_info() {
    separador
    echo -e "${CYAN}Reto 4: Generar certificado autofirmado${NC}"
    echo ""
    echo "Genera un certificado autofirmado válido por 365 días."
    echo "Guarda los archivos como cert.pem y key.pem en /root/laboratorio/ssl/"
    echo "Comando útil: openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -days 365 -nodes"
    separador
}

reto5_info() {
    separador
    echo -e "${CYAN}Reto 5: Ver detalles del certificado${NC}"
    echo ""
    echo "Inspecciona los detalles de tu certificado autofirmado."
    echo "Debes ver información como el subject, issuer y fechas."
    echo "Comando útil: openssl x509 -in cert.pem -text -noout"
    separador
}

reto6_info() {
    separador
    echo -e "${CYAN}Reto 6: Verificar validez del certificado${NC}"
    echo ""
    echo "Verifica que tu certificado no está expirado."
    echo "Comando útil: openssl x509 -in cert.pem -checkend 0 -noout"
    separador
}

reto7_info() {
    separador
    echo -e "${CYAN}Reto 7: Generar CSR${NC}"
    echo ""
    echo "Genera una solicitud de firma de certificado (CSR)."
    echo "Guarda los archivos como request.csr y key_csr.pem en /root/laboratorio/ssl/"
    echo "Comando útil: openssl req -new -newkey rsa:2048 -nodes -out request.csr -keyout key_csr.pem"
    separador
}

reto8_info() {
    separador
    echo -e "${CYAN}Reto 8: Ver detalles del CSR${NC}"
    echo ""
    echo "Inspecciona los detalles de tu solicitud de firma de certificado."
    echo "Debes ver información como el subject y la clave pública."
    echo "Comando útil: openssl req -in request.csr -text -noout"
    separador
}

reto9_info() {
    separador
    echo -e "${CYAN}Reto 9: Crear CA local${NC}"
    echo ""
    echo "Crea una Autoridad de Certificación (CA) local."
    echo "Genera la clave privada (ca.key) y el certificado raíz (ca.crt) en /root/laboratorio/ssl/ca/"
    echo "Comandos útiles:"
    echo "  openssl genrsa -out ca/ca.key 2048"
    echo "  openssl req -x509 -new -nodes -key ca/ca.key -sha256 -days 365 -out ca/ca.crt"
    separador
}

reto10_info() {
    separador
    echo -e "${CYAN}Reto 10: Firmar certificado con CA${NC}"
    echo ""
    echo "Firma un certificado de servidor usando tu CA local."
    echo "Primero genera un CSR para el servidor, luego fírmalo con tu CA."
    echo "Archivos esperados: servidor.crt y servidor.key en /root/laboratorio/ssl/"
    echo "Comandos útiles:"
    echo "  openssl req -new -newkey rsa:2048 -nodes -out servidor.csr -keyout servidor.key"
    echo "  openssl x509 -req -in servidor.csr -CA ca/ca.crt -CAkey ca/ca.key -CAcreateserial -out servidor.crt -days 365"
    separador
}


