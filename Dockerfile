# =============================================================================
# Dockerfile - Laboratorio: Fundamentos de Sistemas de Archivos y Terminal Linux
# =============================================================================
# Imagen basada en Ubuntu 24.04 con herramientas básicas para aprendizaje
# de administración de sistemas de archivos y comandos de terminal.
# =============================================================================

FROM ubuntu:24.04

# Etiquetas del contenedor
LABEL maintainer="DevSecOps Lab"
LABEL description="Laboratorio interactivo de Linux - Sistemas de Archivos y Terminal"
LABEL version="1.0"

# Evitar interacción durante la instalación de paquetes
ENV DEBIAN_FRONTEND=noninteractive

# Actualizar repositorios e instalar herramientas necesarias
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    coreutils \
    tree \
    nano \
    vim \
    curl \
    git \
    sudo \
    openssl \
    nginx \
    rsync \
    ufw \
    openssh-client \
    cron \
    procps \
    net-tools \
    iproute2 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Crear usuario 'estudiante' con permisos sudo sin contraseña
RUN useradd -m -s /bin/bash estudiante && \
    echo "estudiante ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Copiar scripts al contenedor
COPY entrypoint.sh /entrypoint.sh
COPY test.sh /test.sh
COPY manual.sh /manual.sh
COPY revelar-frase.sh /revelar-frase.sh
COPY generar-respuestas.sh /generar-respuestas.sh

# Copiar biblioteca compartida
COPY shared/ /shared/

# Copiar unidades del curso a /opt (fuera del volume mount)
COPY units/ /opt/lab-units/

# Copiar plantilla de respuestas
COPY plantilla.md /home/estudiante/laboratorio/plantilla.md

# Establecer permisos de ejecución
RUN chmod +x /entrypoint.sh /test.sh /manual.sh /revelar-frase.sh /generar-respuestas.sh && \
    chmod +x /shared/*.sh && \
    find /opt/lab-units -name "*.sh" -exec chmod +x {} \;

# Cambiar al usuario 'estudiante'
USER estudiante

# Directorio de trabajo predeterminado
WORKDIR /home/estudiante/laboratorio

# Comando de inicio del contenedor
ENTRYPOINT ["/entrypoint.sh"]