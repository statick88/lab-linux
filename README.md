# Laboratorio: Administración de Servidores Linux

> Curso interactivo de 11 unidades con retos prácticos, evaluación automática y modo tutorial. Ejecutado en Docker.

## Inicio rápido

```bash
git clone <url-del-repositorio>
cd lab
docker compose up -d --build
docker compose exec lab-linux bash
```

Una vez dentro del contenedor, verás el banner de bienvenida y los comandos disponibles.

## Qué incluye

| Unidad | Tema | Habilidades |
|--------|------|-------------|
| I | Fundamentos de Linux | Navegación FHS, WSL2, comandos esenciales |
| II | Gestión de paquetes | apt, dpkg, repositorios |
| III | Shell y scripting | Bash, variables, condicionales, bucles |
| IV | Usuarios y permisos | useradd, chmod, chown, sudo |
| V | Procesos y servicios | ps, top, systemctl, cron |
| VI | Almacenamiento | df, du, mount, LVM, particiones |
| VII | Seguridad básica | SSH, firewalls, CIS benchmarks |
| VIII | Docker | Contenedores, imágenes, Docker-in-Docker |
| IX | Servidor web | Nginx, VirtualHosts, proxy reverso |
| X | SSL/TLS | Certificados, Let's Encrypt, staging |
| XI | Backup y recuperación | rsync, cron, Docker Compose, bases de datos |

## Comandos disponibles (dentro del contenedor)

| Comando | Qué hace |
|---------|----------|
| `menu` | Menú interactivo con rutas de aprendizaje por unidad |
| `evaluar` | Ejecuta validación automática y muestra puntaje |
| `retos` | Muestra retos y pistas de la unidad actual |
| `lab` | Navega al directorio de trabajo |
| `revelar-frase` | Revela la frase oculta al completar retos |
| `generar-respuestas` | Genera archivo de evidencia |

## Estructura del proyecto

```
lab/
├── shared/                 # Librería compartida
│   ├── colors.sh           # Colores y formato
│   ├── eval.sh             # Funciones de evaluación
│   ├── menu.sh             # Menú interactivo
│   ├── banner.sh           # Banners ASCII
│   └── common.sh           # Inicialización base
├── units/
│   ├── ii/                 # Unidad II: Paquetes
│   │   ├── setup.sh        # Instalación
│   │   ├── test.sh         # Validación
│   │   └── manual.sh       # Tutorial paso a paso
│   ├── iii/                # Unidad III: Shell
│   ├── iv/                 # Unidad IV: Usuarios
│   ├── v/                  # Unidad V: Procesos
│   ├── vi/                 # Unidad VI: Almacenamiento
│   ├── vii/                # Unidad VII: Seguridad
│   ├── viii/               # Unidad VIII: Docker
│   ├── ix/                 # Unidad IX: Web
│   ├── x/                  # Unidad X: SSL
│   └── xi/                 # Unidad XI: Backup
├── Dockerfile              # Imagen Ubuntu 24.04
├── docker-compose.yml      # Orquestación
├── entrypoint.sh           # Punto de entrada
├── test.sh                 # Validación Unidad I
├── manual.sh               # Tutorial Unidad I
├── propuesta-pedagogica.md # Propuesta pedagógica completa
├── plantilla.md            # Plantilla de respuestas
└── README.md               # Este archivo
```

## Prerrequisitos

- Docker instalado
- Docker Compose (incluido en Docker Desktop)
- Terminal o línea de comandos

## Validación

Cada unidad tiene su propio `test.sh` con validación automática:

```
✓ PASS  — Reto completado
✗ FAIL  — Reto no completado o con errores
```

Ejecuta `evaluar` para ver tu progreso general.

## Solución de problemas

**El contenedor no inicia:**
```bash
docker compose logs lab-linux
docker compose build --no-cache && docker compose up -d
```

**Los comandos no funcionan:**
- Verifica que estés dentro del contenedor: `docker compose exec lab-linux bash`
- Los aliases se configuran automáticamente al iniciar

**Las pruebas fallan:**
- Verifica que estés en `~/laboratorio`
- Los nombres deben coincidir exactamente con las especificaciones

## Licencia

Uso educativo. Puedes modificarlo y distribuirlo libremente en contextos académicos.

---

## Autor

**Lic. Diego Medardo Saavedra García, Mg. Sc.**

- 🌐 [statick88.github.io](https://statick88.github.io)
- 📧 dsaavedra88@gmail.com
- 📱 +593 98 019 2790

Desarrollado para el curso de **Fundamentos de Sistemas Operativos y Administración de Servidores en Red**.
