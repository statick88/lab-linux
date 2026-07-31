# Laboratorio Interactivo: Administración de Servidores Linux

11 unidades progresivas · 110 retos prácticos · evaluación automática · frase secreta oculta. Todo corre en Docker.

---

## Instalación por Sistema Operativo

### macOS

```bash
# Instalar Docker Desktop desde https://www.docker.com/products/docker-desktop/
# O con Homebrew:
brew install --cask docker

# Clonar y ejecutar
git clone https://github.com/statick88/lab-linux.git
cd lab-linux
docker compose build
docker compose up -d
docker compose exec lab-linux bash
```

### Ubuntu / Debian

```bash
# Instalar Docker
sudo apt update
sudo apt install -y docker.io docker-compose-v2
sudo usermod -aG docker $USER
# Cerrar y abrir sesión para aplicar el grupo

# Clonar y ejecutar
git clone https://github.com/statick88/lab-linux.git
cd lab-linux
docker compose build
docker compose up -d
docker compose exec lab-linux bash
```

### Fedora

```bash
# Instalar Docker
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo systemctl start docker
sudo usermod -aG docker $USER
# Cerrar y abrir sesión para aplicar el grupo

# Clonar y ejecutar
git clone https://github.com/statick88/lab-linux.git
cd lab-linux
docker compose build
docker compose up -d
docker compose exec lab-linux bash
```

### Windows (WSL2)

```bash
# 1. Instalar WSL (PowerShell como Administrador):
wsl --install
# Reiniciar el equipo

# 2. Dentro de WSL (Ubuntu por defecto), instalar Docker:
sudo apt update
sudo apt install -y docker.io docker-compose-v2
sudo usermod -aG docker $USER
# Cerrar y abrir sesión de WSL

# 3. O instalar Docker Desktop for Windows:
# https://www.docker.com/products/docker-desktop/
# Habilitar WSL2 backend en Settings → General

# 4. Clonar y ejecutar
git clone https://github.com/statick88/lab-linux.git
cd lab-linux
docker compose build
docker compose up -d
docker compose exec lab-linux bash
```

### Dentro del contenedor

```bash
menu       # Menú principal con progreso global
jugar      # Modo interactivo: instrucción → comando → verificar
evaluar    # Ejecutar validación y mostrar puntaje
ayuda      # Lista de comandos disponibles
```

---

## Qué aprenderás

| Unidad | Tema | Retos |
|--------|------|:-----:|
| I | Fundamentos de Linux y WSL2 | 10 |
| II | Gestión de Paquetes y APT | 10 |
| III | Scripting Bash | 10 |
| IV | Gestión de Usuarios y SSH | 10 |
| V | Gestión de Procesos y systemd | 10 |
| VI | Almacenamiento y LVM | 10 |
| VII | Hardening del Sistema | 10 |
| VIII | Contenedores con Docker | 10 |
| IX | Servidor Web con Nginx | 10 |
| X | Certificados SSL y HTTPS | 10 |
| XI | Docker Compose y Bases de Datos | 10 |

**Total: 110 retos · 11/11 unidades implementadas.**

---

## Comandos del Contenedor

| Comando | Qué hace |
|---------|----------|
| `menu` | Menú principal con progreso global |
| `jugar` | Modo interactivo: instrucción → comando → verificar |
| `unidad <n>` | Seleccionar unidad (ej: `unidad 3`) |
| `retos` | Ver retos de la unidad actual |
| `evaluar` | Ejecutar validación y mostrar puntaje |
| `revelar-frase` | Revelar palabra al completar una unidad |
| `progreso` | Ver barra de progreso global |
| `ayuda` | Lista de comandos disponibles |

---

## Flujo por Unidad

1. **Seleccionar** → `unidad 2`
2. **Instrucciones** → `retos` muestra pistas progresivas
3. **Resolver** → ejecuta comandos en la terminal
4. **Validar** → `evaluar` muestra ✓ PASS / ✗ FAIL por reto
5. **Frase** → `revelar-frase` revela la palabra oculta

---

## Frase Secreta

Cada unidad completada revela una palabra. Completa las 11 para descubrir la frase:

```
_ _ _ _ _ _ _ _ _ _ _
```

Usa `revelar-frase` tras completar todos los retos de una unidad.

---

## Prerrequisitos

- Docker Engine 24+ o Docker Desktop
- 4 GB RAM libres (necesario para DinD en Unidad VIII)
- Git

> Ver instrucciones detalladas por sistema operativo en la sección de [Instalación](#instalación-por-sistema-operativo).

---

## Solución de Problemas

| Problema | Solución |
|----------|----------|
| Contenedor no inicia | `docker compose logs lab-linux` → `docker compose build --no-cache` |
| Comandos no funcionan | Verificar que estás dentro: `docker compose exec lab-linux bash` |
| Pruebas fallan | directorio debe ser `~/laboratorio`, nombres exactos |
| Docker-in-Docker falla | Verificar `privileged: true` y `/var/run/docker.sock` montado |

---

## Novedades v1.1.0

- **Comandos interactivos funcionan en cualquier shell**: `menu`, `jugar`, `retos`, `evaluar`, `revelar-frase` ahora usan funciones cargadas desde `shared/interactive.sh` vía `.bash_aliases`
- **Autocompletado Tab habilitado**: instalado `bash-completion` en la imagen base
- **Instrucciones paso a paso claras**: Unidad III (Scripting) muestra comandos en líneas separadas para evitar errores de copiado
- **Validadores robustos**: reto 5 (Permisos 755) ahora verifica el archivo `archivo` del estudiante, no un archivo temporal interno

---

## Arquitectura

```
lab-linux/
├── Dockerfile              # Ubuntu 24.04 + usuario estudiante
├── docker-compose.yml      # Volumen persistente lab-data
├── entrypoint.sh           # Aliases y banner
├── shared/                 # Librería compartida
│   ├── common.sh           # Funciones base, FRASES_OCULTAS
│   ├── menu.sh             # Menús interactivos
│   ├── eval.sh             # Sistema de evaluación
│   ├── banner.sh           # Banners visuales
│   └── utils.sh            # Utilidades
├── units/                  # 11 unidades (I–XI)
│   ├── i/                  # Fundamentos Linux/WSL2
│   ├── ii/                 # Paquetes
│   ├── iii/                # Scripting
│   ├── iv/                 # Usuarios
│   ├── v/                  # Procesos
│   ├── vi/                 # Almacenamiento
│   ├── vii/                # Hardening
│   ├── viii/               # Docker
│   ├── ix/                 # Nginx
│   ├── x/                  # SSL
│   └── xi/                 # Docker Compose
├── propuesta-pedagogica.md # Documento del curso
└── README.md               # Este archivo
```

---

## Contribuir

Ver [CONTRIBUTING.md](CONTRIBUTING.md) para la estrategia de ramas y flujo de trabajo.

- **`main`** — Solo código verificado y probado
- **`develop`** — Mejoras y features en progreso
- **`fix/*`** — Corrección de errores (se crean bajo demanda)

---

## Autor

**Lic. Diego Medardo Saavedra García, Mg. Sc.**
🌐 https://statick88.github.io
✉️ dsaavedra88@gmail.com

---

*Curso "Fundamentos de Sistemas Operativos y Administración de Servidores en Red"*
