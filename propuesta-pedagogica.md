---
title: "Propuesta Pedagógica — Administración de Servidores Linux"
subtitle: "Curso interactivo con retos prácticos, evaluación automática y modo tutorial"
author: "Lic. Diego Medardo Saavedra García, Mg. Sc."
date: today
format:
  html:
    toc: true
    number-sections: true
    code-fold: false
    theme: cosmo
  pdf:
    toc: true
    number-sections: true
execute:
  eval: false
---

# Visión General del Curso {.unnumbered}

Este documento presenta una propuesta pedagógica completa para el curso **"Administración de Servidores Linux"**, compuesto por **11 unidades** progresivas. Cada unidad incluye:

- **Menú interactivo** con rutas de aprendizaje
- **Laboratorios paso a paso** con instrucciones detalladas
- **Retos prácticos** con pistas progresivas
- **Listas de verificación** para autoevaluación
- **Proyectos integradores** al cierre de cada módulo

El curso sigue una filosofía **"aprender haciendo"**: cada concepto se refuerza con una actividad práctica inmediata.

## Estructura del Curso

```{mermaid}
graph LR
    A[I: Fundamentos] --> B[II: Paquetes]
    B --> C[III: Scripting]
    C --> D[IV: Usuarios]
    D --> E[V: Procesos]
    E --> F[VI: Almacenamiento]
    F --> G[VII: Hardening]
    G --> H[VIII: Docker]
    H --> I[IX: Web/Nginx]
    I --> J[X: SSL/HTTPS]
    J --> K[XI: Compose/DB]
```

::: {.callout-tip}
## Modo de uso
Cada unidad puede completarse en **2-3 horas**. Se recomienda seguir el orden secuencial, ya que los retos construyen sobre habilidades previas.
:::


---

# UNIDAD I — Fundamentos de Linux yWSL2

> *"Sin fundamentos sólidos, no hay administración segura."*

## Objetivos de Aprendizaje

Al finalizar esta unidad, el estudiante será capaz de:

1. Navegar el sistema de archivos Linux con confianza
2. Explicar la jerarquía FHS (Filesystem Hierarchy Standard)
3. Configurar y usar WSL2 como entorno de desarrollo
4. Ejecutar comandos básicos del sistema de archivos

## Menú de Ruta de Aprendizaje

::: {.callout-note}
## Elige tu camino

| Nivel | Descripción | Tiempo |
|-------|-------------|--------|
| 🟢 Básico | Navegación FHS + comandos esenciales | 45 min |
| 🟡 Intermedio | Configuración WSL2 + permisos | 60 min |
| 🔴 Avanzado | Integración Git + scripts de inicio | 90 min |
:::

## Lab 1.1 — Exploración del Sistema de Archivos

### Instrucciones Paso a Paso

```bash
# 1. Ubicarte en tu directorio actual
pwd

# 2. Listar archivos con detalles
ls -la /home

# 3. Explorar la jerarquía FHS
ls -la /etc        # Configuración del sistema
ls -la /var        # Variables (logs, caché)
ls -la /tmp        # Temporales
ls -la /usr        # Programas de usuario

# 4. Crear tu directorio de trabajo
mkdir -p ~/laboratorio/fundamentos
cd ~/laboratorio/fundamentos

# 5. Crear un archivo de prueba
echo "Hola Linux" > saludo.txt
cat saludo.txt
```

### Reto 1.1 — Navegación Avanzada

**Objetivo:** Navegar entre directorios sin usar `cd` explícitamente.

::: {.callout-important}
## Reto
Crea un script que muestre:
1. Tu directorio actual
2. El contenido de `/etc/os-release`
3. La cantidad de archivos en `/usr/bin`
4. El espacio disponible en disco

**Pista 1:** Usa `pwd`, `cat`, `ls | wc -l`, `df -h`
**Pista 2:** Piensa en pipes `|` para encadenar comandos
:::

### Verificación

```bash
# Tu script debe producir salida similar a:
# Directorio: /home/usuario
# SO: Ubuntu 22.04 LTS
# Archivos en /usr/bin: 12345
# Disco: 45G disponibles en /
```

## Checklist Unidad I

- [ ] Puedo navegar la jerarquía FHS sin ayuda
- [ ] Entiendo la diferencia entre `/etc`, `/var`, `/usr`
- [ ] Puedo crear y manipular archivos con comandos básicos
- [ ] Completé el Reto 1.1 exitosamente
- [ ] Mi script produce la salida esperada


---

# UNIDAD II — Gestión de Paquetes y APT

> *"Un sistema desactualizado es un sistema vulnerable."*

## Objetivos de Aprendizaje

1. Administrar paquetes con APT (instalar, actualizar, eliminar)
2. Configurar repositorios y claves GPG
3. Gestionar dependencias y resolver conflictos
4. Usar Git para control de versiones básico

## Menú de Ruta de Aprendizaje

::: {.callout-note}
## Elige tu camino

| Nivel | Descripción | Tiempo |
|-------|-------------|--------|
| 🟢 Básico | Comandos APT esenciales | 45 min |
| 🟡 Intermedio | Repositorios + claves GPG | 75 min |
| 🔴 Avanzado | Script de actualización automática | 90 min |
:::

## Lab 2.1 — Gestión de Paquetes

### Instrucciones Paso a Paso

```bash
# 1. Actualizar índices de paquetes
sudo apt update

# 2. Verificar actualizaciones disponibles
apt list --upgradable

# 3. Instalar paquetes esenciales
sudo apt install -y curl wget git vim htop

# 4. Buscar un paquetes específico
apt search nginx | head -10

# 5. Verificar instalación
which curl && curl --version

# 6. Limpiar caché
sudo apt clean
sudo apt autoremove
```

### Reto 2.1 — Configuración de Repositorio

::: {.callout-important}
## Reto
Configura un repositorio personalizado para Node.js:

1. Importa la clave GPG oficial
2. Agrega el repositorio a tu sistema
3. Instala Node.js LTS
4. Verifica la instalación con `node -v` y `npm -v`

**Pista 1:** Usa `curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -`
**Pista 2:** La clave GPG se almacena en `/usr/share/keyrings/`
:::

## Checklist Unidad II

- [ ] Puedo instalar, actualizar y eliminar paquetes con APT
- [ ] Entiendo cómo funcionan los repositorios
- [ ] Puedo agregar claves GPG y repositorios externos
- [ ] Completé el Reto 2.1 exitosamente
- [ ] Git está configurado y funcionando en mi sistema


---

# UNIDAD III — Scripting Bash

> *"La automatización es la diferencia entre trabajar en Linux y que Linux trabaje para ti."*

## Objetivos de Aprendizaje

1. Escribir scripts Bash con estructura correcta
2. Usar variables, condicionales y bucles
3. Procesar argumentos de línea de comandos
4. Crear scripts de mantenimiento del sistema

## Menú de Ruta de Aprendizaje

::: {.callout-note}
## Elige tu camino

| Nivel | Descripción | Tiempo |
|-------|-------------|--------|
| 🟢 Básico | Estructura de scripts + variables | 60 min |
| 🟡 Intermedio | Condicionales + funciones | 90 min |
| 🔴 Avanzado | Script de backup automatizado | 120 min |
:::

## Lab 3.1 — Tu Primer Script

### Instrucciones Paso a Paso

```bash
# 1. Crear el script
cat > ~/laboratorio/hola.sh << 'EOF'
#!/bin/bash
# Script: hola.sh
# Descripción: Saluda al usuario con la fecha actual

echo "=========================================="
echo "  Hola, $USER!"
echo "  Fecha: $(date '+%d/%m/%Y %H:%M')"
echo "  Directorio: $(pwd)"
echo "  Uptime: $(uptime -p)"
echo "=========================================="
EOF

# 2. Dar permisos de ejecución
chmod +x ~/laboratorio/hola.sh

# 3. Ejecutar el script
~/laboratorio/hola.sh
```

### Reto 3.1 — Script de Monitoreo

::: {.callout-important}
## Reto
Crea un script `monitoreo.sh` que:

1. Muestre el uso de CPU, memoria y disco
2. Liste los 5 procesos que más CPU consumen
3. Muestre las conexiones de red activas
4. Guarde todo en un archivo de log con timestamp

**Pista 1:** Usa `top -bn1 | head -5`, `free -m`, `df -h`
**Pista 2:** Redirige con `>>` para agregar al log
**Pista 3:** Usa `$(date +%Y%m%d_%H%M%S)` para el nombre del log
:::

## Checklist Unidad III

- [ ] Puedo crear scripts con shebang correcto
- [ ] Uso variables del sistema y del usuario
- [ ] Implemento condicionales `if/else` en scripts
- [ ] Creo funciones reutilizables
- [ ] Completé el Reto 3.1 exitosamente


---

# UNIDAD IV — Gestión de Usuarios y SSH

> *"Cada usuario es una puerta de entrada; administralas con cuidado."*

## Objetivos de Aprendizaje

1. Crear, modificar y eliminar usuarios
2. Gestionar grupos y permisos
3. Configurar autenticación SSH con claves
4. Entender el módulo PAM para autenticación

## Menú de Ruta de Aprendizaje

::: {.callout-note}
## Elige tu camino

| Nivel | Descripción | Tiempo |
|-------|-------------|--------|
| 🟢 Básico | CRUD de usuarios + grupos | 45 min |
| 🟡 Intermedio | Configuración SSH + claves | 75 min |
| 🔴 Avanzado | Configuración PAM + hardening SSH | 105 min |
:::

## Lab 4.1 — Gestión de Usuarios

### Instrucciones Paso a Paso

```bash
# 1. Crear un usuario de prueba
sudo useradd -m -s /bin/bash labuser
sudo passwd labuser

# 2. Crear un grupo de laboratorio
sudo groupadd laboratorio
sudo usermod -aG laboratorio labuser

# 3. Verificar membresía
groups labuser

# 4. Cambiar ownership de un directorio
sudo chown -R labuser:laboratorio /home/labuser

# 5. Configurar permisos
sudo chmod 750 /home/labuser
ls -la /home/
```

### Reto 4.1 — Configuración SSH Segura

::: {.callout-important}
## Reto
Configura acceso SSH seguro:

1. Genera un par de claves Ed25519
2. Copia la clave pública al servidor
3. Desactiva el login con contraseña
4. Configura un usuario sin privilegios sudo
5. Verifica la conexión

**Pista 1:** `ssh-keygen -t ed25519 -C "tu@email.com"`
**Pista 2:** Edita `/etc/ssh/sshd_config` con `PasswordAuthentication no`
**Pista 3:** Usa `ssh-copy-id` para copiar la clave
:::

## Checklist Unidad IV

- [ ] Puedo crear y gestionar usuarios con `useradd`/`usermod`
- [ ] Entiendo la estructura de `/etc/passwd` y `/etc/shadow`
- [ ] Configuré SSH con autenticación por claves
- [ ] Desactivé el login por contraseña en SSH
- [ ] Completé el Reto 4.1 exitosamente


---

# UNIDAD V — Gestión de Procesos y systemd

> *"Controla tus procesos o ellos te controlarán a ti."*

## Objetivos de Aprendizaje

1. Monitorear y gestionar procesos en tiempo real
2. Configurar servicios con systemd
3. Crear unidades de servicio personalizadas
4. Programar tareas con cron y systemd timers

## Menú de Ruta de Aprendizaje

::: {.callout-note}
## Elige tu camino

| Nivel | Descripción | Tiempo |
|-------|-------------|--------|
| 🟢 Básico | Monitoreo + señales de procesos | 60 min |
| 🟡 Intermedio | Systemd + timers | 90 min |
| 🔴 Avanzado | Servicio personalizado + logging | 120 min |
:::

## Lab 5.1 — Monitoreo de Procesos

### Instrucciones Paso a Paso

```bash
# 1. Ver procesos en tiempo real
top

# 2. Buscar un proceso específico
ps aux | grep nginx

# 3. Matar un proceso por nombre
pkill -f "proceso_prueba"

# 4. Ver el árbol de procesos
pstree

# 5. Verificar procesos zombie
ps aux | grep -w Z

# 6. Ver uso de recursos por proceso
ps aux --sort=-%cpu | head -10
```

### Reto 5.1 — Servicio Systemd Personalizado

::: {.callout-important}
## Reto
Crea un servicio systemd que:

1. Ejecute un script de monitoreo cada 5 minutos
2. Registre logs en el journal del sistema
3. Se reinicie automáticamente si falla
4. Inicie al arrancar el sistema

**Pista 1:** Crea una unidad `.service` en `/etc/systemd/system/`
**Pista 2:** Usa `Restart=on-failure` y `RestartSec=30`
**Pista 3:** Verifica con `systemctl status tu-servicio`
:::

## Checklist Unidad V

- [ ] Puedo monitorear procesos con `top`, `ps`, `htop`
- [ ] Entiendo las señales de procesos (SIGTERM, SIGKILL)
- [ ] Creo unidades systemd personalizadas
- [ ] Programo tareas con cron o systemd timers
- [ ] Completé el Reto 5.1 exitosamente


---

# UNIDAD VI — Gestión de Almacenamiento y LVM

> *"Los datos sin respaldo son datos en espera de perderse."*

## Objetivos de Aprendizaje

1. Administrar sistemas de archivos (ext4, XFS)
2. Configurar y gestionar LVM (Logical Volume Manager)
3. Crear y montar particiones
4. Implementar estrategias de respaldo

## Menú de Ruta de Aprendizaje

::: {.callout-note}
## Elige tu camino

| Nivel | Descripción | Tiempo |
|-------|-------------|--------|
| 🟢 Básico | Montaje + gestión de discos | 60 min |
| 🟡 Intermedio | LVM completo (PV → VG → LV) | 105 min |
| 🔴 Avanzado | Snapshot + backup automatizado | 135 min |
:::

## Lab 6.1 — Gestión de Discos

### Instrucciones Paso a Paso

```bash
# 1. Ver discos disponibles
lsblk
sudo fdisk -l

# 2. Crear un archivo de disco virtual
dd if=/dev/zero of=~/laboratorio/disk.img bs=1M count=100

# 3. Formatear con ext4
sudo mkfs.ext4 ~/laboratorio/disk.img

# 4. Crear punto de montaje
sudo mkdir -p /mnt/laboratorio

# 5. Montar el disco virtual
sudo mount ~/laboratorio/disk.img /mnt/laboratorio

# 6. Verificar montaje
df -h /mnt/laboratorio
mount | grep laboratorio
```

### Reto 6.1 — Configuración LVM

::: {.callout-important}
## Reto
Configura un entorno LVM completo:

1. Crea 3 discos virtuales de 50MB cada uno
2. Inicialízalos como Physical Volumes (PV)
3. Crea un Volume Group (VG) llamado `datos`
4. Crea un Logical Volume (LV) de 100MB
5. Formatea y monta el LV
6. Agrega un cuarto disco y extiende el LV

**Pista 1:** Usa `pvcreate`, `vgcreate`, `lvcreate`
**Pista 2:** Para extender: `lvextend -L +50M` + `resize2fs`
:::

## Checklist Unidad VI

- [ ] Puedo crear y montar sistemas de archivos
- [ ] Entiendo la arquitectura LVM (PV → VG → LV)
- [ ] Puedo extender volúmenes LVM sin perder datos
- [ ] Implementé un respaldo básico con `rsync`
- [ ] Completé el Reto 6.1 exitosamente


---

# UNIDAD VII — Hardening del Sistema

> *"La seguridad no es un producto, es un proceso."*

## Objetivos de Aprendizaje

1. Aplicar benchmarks de seguridad (CIS)
2. Configurar firewalls (UFW/iptables)
3. Implementar detección de intrusos (fail2ban)
4. Auditar permisos y configuraciones

## Menú de Ruta de Aprendizaje

::: {.callout-note}
## Elige tu camino

| Nivel | Descripción | Tiempo |
|-------|-------------|--------|
| 🟢 Básico | UFW + actualizaciones de seguridad | 45 min |
| 🟡 Intermedio | fail2ban + auditoría de permisos | 90 min |
| 🔴 Avanzado | CIS Benchmark + auditoría completa | 135 min |
:::

## Lab 7.1 — Firewall con UFW

### Instrucciones Paso a Paso

```bash
# 1. Verificar estado actual
sudo ufw status verbose

# 2. Configurar políticas por defecto
sudo ufw default deny incoming
sudo ufw default allow outgoing

# 3. Permitir SSH (¡cuidado de no bloquearte!)
sudo ufw allow ssh

# 4. Permitir HTTP y HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# 5. Activar el firewall
sudo ufw enable

# 6. Verificar reglas
sudo ufw status numbered
```

### Reto 7.1 — Configuración fail2ban

::: {.callout-important}
## Reto
Configura fail2ban para proteger tu servidor:

1. Instala fail2ban
2. Crea una jail personalizada para SSH
3. Configura el ban after 3 intentos fallidos
4. Establece un tiempo de ban de 1 hora
5. Crea una jail para Nginx (anti-scraping)
6. Verifica que funciona con logs

**Pista 1:** Edita `/etc/fail2ban/jail.local`
**Pista 2:** Usa `[sshd]` y `[nginx-http-auth]` como nombres de jail
**Pista 3:** Verifica con `fail2ban-client status sshd`
:::

## Checklist Unidad VII

- [ ] UFW está activo con políticas restrictivas
- [ ] fail2ban protege SSH y servicios web
- [ ] Entiendo cómo leer logs de seguridad
- [ ] Puedo auditar permisos con `find` y `stat`
- [ ] Completé el Reto 7.1 exitosamente


---

# UNIDAD VIII — Contenedores con Docker

> *"Los contenedores no reemplazan al servidor; lo hacen reproducible."*

## Objetivos de Aprendizaje

1. Entender la arquitectura de contenedores vs VMs
2. Crear y gestionar contenedores Docker
3. Construir imágenes con Dockerfile
4. Redes y volúmenes en Docker

## Menú de Ruta de Aprendizaje

::: {.callout-note}
## Elige tu camino

| Nivel | Descripción | Tiempo |
|-------|-------------|--------|
| 🟢 Básico | Contenedores + imágenes básicas | 60 min |
| 🟡 Intermedio | Dockerfile + redes | 90 min |
| 🔴 Avanzado | Multi-stage build + optimización | 120 min |
:::

## Lab 8.1 — Primeros Pasos con Docker

### Instrucciones Paso a Paso

```bash
# 1. Verificar instalación
docker --version
docker ps

# 2. Ejecutar tu primer contenedor
docker run -it ubuntu:22.04 bash

# 3. Listar contenedores (incluyendo detenidos)
docker ps -a

# 4. Ejecutar un contenedor en background
docker run -d --name webserver nginx:latest

# 5. Ver logs del contenedor
docker logs webserver

# 6. Entrar a un contenedor en ejecución
docker exec -it webserver bash

# 7. Limpiar contenedores detenidos
docker container prune
```

### Reto 8.1 — Dockerfile Personalizado

::: {.callout-important}
## Reto
Crea una imagen Docker que:

1. Se base en Ubuntu 22.04
2. Instale Python 3 y pip
3. Copie un script Python al contenedor
4. Ejecute el script al iniciar el contenedor
5. Exponga un puerto para un servidor web simple

**Pista 1:** Usa `FROM`, `RUN`, `COPY`, `EXPOSE`, `CMD`
**Pista 2:** Ejecuta `docker build -t mi-app .`
**Pista 3:** Usa `docker run -p 8080:8000 mi-app`
:::

## Checklist Unidad VIII

- [ ] Puedo ejecutar, detener y eliminar contenedores
- [ ] Creo imágenes personalizadas con Dockerfile
- [ ] Entiendo la diferencia entre `COPY` y `ADD`
- [ ] Configuro redes y volúmenes Docker
- [ ] Completé el Reto 8.1 exitosamente


---

# UNIDAD IX — Servidor Web con Nginx

> *"Un servidor web mal configurado es una puerta abierta."*

## Objetivos de Aprendizaje

1. Instalar y configurar Nginx
2. Hostear sitios estáticos y dinámicos
3. Configurar bloques de servidor (virtual hosts)
4. Implementar proxy reverso

## Menú de Ruta de Aprendizaje

::: {.callout-note}
## Elige tu camino

| Nivel | Descripción | Tiempo |
|-------|-------------|--------|
| 🟢 Básico | Instalación + sitio estático | 45 min |
| 🟡 Intermedio | Virtual hosts + PHP-FPM | 90 min |
| 🔴 Avanzado | Proxy reverso + balanceo de carga | 120 min |
:::

## Lab 9.1 — Nginx Básico

### Instrucciones Paso a Paso

```bash
# 1. Instalar Nginx
sudo apt update
sudo apt install -y nginx

# 2. Verificar estado
sudo systemctl status nginx

# 3. Probar la página por defecto
curl http://localhost

# 4. Crear tu sitio
sudo mkdir -p /var/www/misitio
sudo chown -R $USER:$USER /var/www/misitio

# 5. Crear página de prueba
cat > /var/www/misitio/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head><title>Mi Sitio</title></head>
<body>
    <h1>¡Nginx funciona!</h1>
    <p>Este es mi primer sitio web.</p>
</body>
</html>
EOF

# 6. Configurar el bloque de servidor
sudo nano /etc/nginx/sites-available/misitio
```

### Reto 9.1 — Proxy Reverso

::: {.callout-important}
## Reto
Configura Nginx como proxy reverso:

1. Ejecuta una aplicación Node.js en el puerto 3000
2. Configura Nginx para proxy reverso en el puerto 80
3. Agrega headers de seguridad (X-Frame-Options, CSP)
4. Configura compresión gzip
5. Habilita caching estático

**Pista 1:** Usa `proxy_pass http://localhost:3000;`
**Pista 2:** Headers con `add_header X-Frame-Options "SAMEORIGIN";`
**Pista 3:** Gzip con `gzip on; gzip_types text/plain application/json;`
:::

## Checklist Unidad IX

- [ ] Nginx está instalado y sirviendo contenido
- [ ] Configuré bloques de servidor (virtual hosts)
- [ ] Implementé proxy reverso correctamente
- [ ] Agregué headers de seguridad
- [ ] Completé el Reto 9.1 exitosamente


---

# UNIDAD X — Certificados SSL y HTTPS

> *"Sin HTTPS, tu sitio es una postal abierta para espías."*

## Objetivos de Aprendizaje

1. Entender TLS/SSL y la cadena de certificados
2. Obtener certificados con Let's Encrypt / Certbot
3. Configurar HTTPS en Nginx
4. Automatizar renovación de certificados

## Menú de Ruta de Aprendizaje

::: {.callout-note}
## Elige tu camino

| Nivel | Descripción | Tiempo |
|-------|-------------|--------|
| 🟢 Básico | Certbot + HTTPS básico | 45 min |
| 🟡 Intermedio | Configuración avanzada TLS | 75 min |
| 🔴 Avanzado | HSTS + CT logs + monitoreo | 105 min |
:::

## Lab 10.1 — Certificado con Certbot

### Instrucciones Paso a Paso

```bash
# 1. Instalar Certbot
sudo apt install -y certbot python3-certbot-nginx

# 2. Obtener certificado (modo staging para pruebas)
sudo certbot --nginx -d misitio.com -d www.misitio.com --staging

# 3. Verificar renovación automática
sudo certbot renew --dry-run

# 4. Verificar configuración SSL
sudo nginx -t
sudo systemctl reload nginx

# 5. Probar HTTPS
curl -I https://misitio.com

# 6. Verificar headers de seguridad
curl -I https://misitio.com | grep -i strict
```

### Reto 10.1 — Hardening TLS

::: {.callout-important}
## Reto
Mejora la configuración TLS de tu servidor:

1. Configura solo TLS 1.2 y 1.3
2. Habilita HSTS con max-age de 1 año
3. Configura OCSP Stapling
4. Agrega CT (Certificate Transparency) headers
5. Verifica con SSL Labs (A+ o superior)

**Pista 1:** Edita `/etc/nginx/snippets/ssl-params.conf`
**Pista 2:** HSTS: `add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;`
**Pista 3:** OCSP: `ssl_stapling on; ssl_stapling_verify on;`
:::

## Checklist Unidad X

- [ ] Certbot instaló el certificado correctamente
- [ ] HTTPS funciona con redirección desde HTTP
- [ ] HSTS está configurado
- [ ] La renovación automática funciona
- [ ] Completé el Reto 10.1 exitosamente


---

# UNIDAD XI — Docker Compose y Bases de Datos

> *"La orquestación convierte contenedores en sistemas completos."*

## Objetivos de Aprendizaje

1. Definir aplicaciones multi-contenedor con Docker Compose
2. Configurar redes y volúmenes persistente
3. Integrar bases de datos (MySQL, PostgreSQL, Redis)
4. Implementar estrategias de respaldo de BD en contenedores

## Menú de Ruta de Aprendizaje

::: {.callout-note}
## Elige tu camino

| Nivel | Descripción | Tiempo |
|-------|-------------|--------|
| 🟢 Básico | docker-compose.yml básico | 60 min |
| 🟡 Intermedio | Multi-servicio + redes | 105 min |
| 🔴 Avanzado | Backup + monitoreo + producción | 150 min |
:::

## Lab 11.1 — Primer docker-compose.yml

### Instrucciones Paso a Paso

```bash
# 1. Crear directorio del proyecto
mkdir -p ~/laboratorio/docker-stack
cd ~/laboratorio/docker-stack

# 2. Crear docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  web:
    image: nginx:latest
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html
    depends_on:
      - app
    networks:
      - frontend

  app:
    image: node:18-alpine
    working_dir: /app
    volumes:
      - ./app:/app
    command: sh -c "npm install && node server.js"
    networks:
      - frontend
      - backend

  db:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: rootpass123
      MYSQL_DATABASE: laboratorio
      MYSQL_USER: admin
      MYSQL_PASSWORD: admin123
    volumes:
      - db-data:/var/lib/mysql
    networks:
      - backend

volumes:
  db-data:

networks:
  frontend:
  backend:
EOF

# 3. Crear archivos de ejemplo
mkdir -p html app

cat > html/index.html << 'EOF'
<h1>¡Docker Compose funciona!</h1>
EOF

cat > app/server.js << 'EOF'
const http = require('http');
const server = http.createServer((req, res) => {
  res.writeHead(200, {'Content-Type': 'text/plain'});
  res.end('API funcionando\n');
});
server.listen(3000, () => console.log('Escuchando en :3000'));
EOF

# 4. Levantar el stack
docker-compose up -d

# 5. Verificar servicios
docker-compose ps
docker-compose logs -f
```

### Reto 11.1 — Stack Completo con Backup

::: {.callout-important}
## Reto
Amplía el stack con:

1. Agrega un servicio Redis para caché
2. Configura backup automático de MySQL con `mysqldump`
3. Crea un script de monitoreo que verifique todos los servicios
4. Configura logs centralizados con `docker logs`
5. Implementa healthchecks para cada servicio

**Pista 1:** Redis: `image: redis:7-alpine` + `ports: "6379:6379"`
**Pista 2:** Backup: `docker exec db mysqldump -u root -prootpass123 laboratorio > backup.sql`
**Pista 3:** Healthchecks: `healthcheck: { test: ["CMD", "curl", "-f", "http://localhost"] }`
:::

## Checklist Unidad XI

- [ ] Docker Compose levanta un stack multi-servicio
- [ ] Las redes están configuradas correctamente
- [ ] Los volúmenes persisten datos entre reinicios
- [ ] La base de datos funciona y se conecta desde la app
- [ ] Completé el Reto 11.1 exitosamente


---

# Proyectos Integradores {.unnumbered}

## Proyecto Final — Servidor Web Completo

Al finalizar las 11 unidades, el estudiante deberá implementar:

### Requisitos

1. **Infraestructura**
   - Servidor Ubuntu 22.04 con hardening aplicado
   - Firewall UFW configurado
   - fail2ban activo
   - SSH con autenticación por claves

2. **Servicios**
   - Nginx como proxy reverso
   - HTTPS con Let's Encrypt
   - Docker Compose para la aplicación
   - Base de datos (MySQL o PostgreSQL)
   - Redis para caché

3. **Automatización**
   - Script de backup automatizado
   - Monitoreo con alertas
   - Logs centralizados
   - Cron jobs para mantenimiento

4. **Documentación**
   - Diagrama de arquitectura
   - Runbook de operaciones
   - Procedimiento de restore

### Criterios de Evaluación

| Criterio | Peso | Descripción |
|----------|------|-------------|
| Seguridad | 25% | Hardening, firewalls, SSL |
| Funcionalidad | 25% | Servicios operativos |
| Automatización | 25% | Scripts, backups, monitoreo |
| Documentación | 25% | Claridad, completitud |


---

# Recursos Adicionales {.unnumbered}

## Documentación Oficial

- [Ubuntu Documentation](https://help.ubuntu.com/)
- [Docker Documentation](https://docs.docker.com/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [Let's Encrypt](https://letsencrypt.org/docs/)

## Herramientas Recomendadas

- **Terminal**: tmux, zsh + oh-my-zsh
- **Editor**: vim, neovim, VS Code
- **Monitoreo**: htop, glances, netdata
- **Seguridad**: Lynis, ClamAV

## Comunidades

- [Linux Questions](https://linuxquestions.org/)
- [Ask Ubuntu](https://askubuntu.com/)
- [Docker Community](https://www.docker.com/community/)

::: {.callout-note}
## Licencia
Esta propuesta pedagógica está bajo licencia CC BY-SA 40.
Autor: Diego Saavedra García — Profesor titular, Investigador Senior.
:::
