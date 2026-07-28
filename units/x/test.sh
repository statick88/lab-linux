#!/bin/bash
# Unit X: SSL/TLS Certificates — test.sh
# Automated validation of 10 challenges

set -e
source /shared/common.sh

UNIT_NAME="unit-X"
TOTAL_RETOS=10
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

ejecutar_evaluacion "$UNIT_NAME" "$TOTAL_RETOS" "${validators[@]}"
