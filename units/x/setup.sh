#!/bin/bash
# Unit X: SSL/TLS Certificates — setup.sh
# Creates the environment and 10 challenges for learning SSL

set -e
source /shared/common.sh

UNIT_NAME="unit-X"
UNIT_NUM=10
export TOTAL_RETOS=10

banner_unidad "$UNIT_NUM" "Certificados SSL/TLS"

echo -e "${CYAN}Esta unidad ensena a gestionar certificados SSL/TLS para seguridad web.${RESET}"
echo -e "${AMARILLO}Usaremos Let's Encrypt (staging) para experimentar.${RESET}"
echo -e "${AMARILLO}Completarás 10 retos progresivos.${RESET}\n"

mkdir -p "$HOME/laboratorio/ssl"
cd "$HOME/laboratorio/ssl"

# Reto 1: Verificar openssl
cat > reto1.sh << 'EOF'
#!/bin/bash
# Reto 1: Verificar que openssl esta instalado
openssl version
which openssl
EOF
chmod +x reto1.sh

# Reto 2: Generar clave privada
cat > reto2.sh << 'EOF'
#!/bin/bash
# Reto 2: Generar una clave privada RSA
openssl genrsa -out clave_privada.pem 2048 2>/dev/null
ls -la clave_privada.pem
EOF
chmod +x reto2.sh

# Reto 3: Verificar clave privada
cat > reto3.sh << 'EOF'
#!/bin/bash
# Reto 3: Verificar los detalles de la clave privada
openssl rsa -in clave_privada.pem -check -noout 2>/dev/null
echo "Clave privada valida"
EOF
chmod +x reto3.sh

# Reto 4: Generar certificado autofirmado
cat > reto4.sh << 'EOF'
#!/bin/bash
# Reto 4: Crear un certificado SSL autofirmado
openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -days 365 -nodes \
    -subj "/C=EC/ST=Quito/L=Quito/O=MiOrg/CN=localhost" 2>/dev/null
ls -la cert.pem key.pem
EOF
chmod +x reto4.sh

# Reto 5: Ver detalles del certificado
cat > reto5.sh << 'EOF'
#!/bin/bash
# Reto 5: Ver informacion del certificado
openssl x509 -in cert.pem -text -noout | head -20
EOF
chmod +x reto5.sh

# Reto 6: Verificar validez del certificado
cat > reto6.sh << 'EOF'
#!/bin/bash
# Verificar que el certificado es valido
openssl x509 -in cert.pem -checkend 0 -noout && echo "Certificado valido" || echo "Certificado expirado"
EOF
chmod +x reto6.sh

# Reto 7: Generar CSR (Certificate Signing Request)
cat > reto7.sh << 'EOF'
#!/bin/bash
# Reto 7: Generar una solicitud de certificado
openssl req -new -newkey rsa:2048 -nodes -out request.csr -keyout key_csr.pem \
    -subj "/C=EC/ST=Quito/L=Quito/O=MiOrg/CN=midominio.com" 2>/dev/null
ls -la request.csr key_csr.pem
EOF
chmod +x reto7.sh

# Reto 8: Ver detalles del CSR
cat > reto8.sh << 'EOF'
#!/bin/bash
# Reto 8: Ver informacion del CSR
openssl req -in request.csr -text -noout -verify 2>/dev/null | head -15
EOF
chmod +x reto8.sh

# Reto 9: Crear CA local
cat > reto9.sh << 'EOF'
#!/bin/bash
# Reto 9: Crear una Autoridad Certificadora local
mkdir -p ca
openssl genrsa -out ca/ca.key 2048 2>/dev/null
openssl req -x509 -new -nodes -key ca/ca.key -sha256 -days 365 \
    -out ca/ca.crt -subj "/C=EC/ST=Quito/L=Quito/O=MiCA/CN=Mi CA Local" 2>/dev/null
ls -la ca/
echo "CA local creada"
EOF
chmod +x reto9.sh

# Reto 10: Firmar certificado con CA
cat > reto10.sh << 'EOF'
#!/bin/bash
# Reto 10: Firmar un certificado con nuestra CA local
mkdir -p ca
# Crear CA si no existe
if [ ! -f ca/ca.key ]; then
    openssl genrsa -out ca/ca.key 2048 2>/dev/null
    openssl req -x509 -new -nodes -key ca/ca.key -sha256 -days 365 \
        -out ca/ca.crt -subj "/C=EC/ST=Quito/L=Quito/O=MiCA/CN=Mi CA" 2>/dev/null
fi
# Crear CSR
openssl req -new -newkey rsa:2048 -nodes -out servidor.csr -keyout servidor.key \
    -subj "/C=EC/ST=Quito/L=Quito/O=MiOrg/CN=servidor.local" 2>/dev/null
# Firmar con CA
openssl x509 -req -in servidor.csr -CA ca/ca.crt -CAkey ca/ca.key -CAcreateserial \
    -out servidor.crt -days 365 -sha256 2>/dev/null
ls -la servidor.crt servidor.key ca/
echo "Certificado firmado por CA local"
EOF
chmod +x reto10.sh

exito "Entorno de Unit X preparado con 10 retos"
echo -e "${AMARILLO}Escribe ${CYAN}'manual'${AMARILLO} para ver las instrucciones o ${CYAN}'evaluar'${AMARILLO} para evaluar.${RESET}"
