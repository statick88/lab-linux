# Laboratorio Interactivo: Administración de Servidores Linux

11 unidades progresivas · 110 retos prácticos · evaluación automática · frase secreta oculta. Todo corre en Docker.

---

## Quick Start

```bash
git clone https://github.com/statick88/lab-linux.git
cd lab-linux
docker compose build
docker compose up -d
docker compose exec lab-linux bash
```

Dentro del contenedor: `menu` · `jugar` · `retos` · `evaluar` · `progreso`

---

## Instalación por Sistema Operativo

<details>
<summary>macOS</summary>

```bash
brew install --cask docker
git clone https://github.com/statick88/lab-linux.git
cd lab-linux
docker compose build && docker compose up -d
docker compose exec lab-linux bash
```
</details>

<details>
<summary>Ubuntu / Debian</summary>

```bash
sudo apt update && sudo apt install -y docker.io docker-compose-v2
sudo usermod -aG docker $USER
# Cerrar y abrir sesión para aplicar el grupo
git clone https://github.com/statick88/lab-linux.git
cd lab-linux
docker compose build && docker compose up -d
docker compose exec lab-linux bash
```
</details>

<details>
<summary>Fedora</summary>

```bash
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo systemctl start docker && sudo usermod -aG docker $USER
# Cerrar y abrir sesión para aplicar el grupo
git clone https://github.com/statick88/lab-linux.git
cd lab-linux
docker compose build && docker compose up -d
docker compose exec lab-linux bash
```
</details>

<details>
<summary>Windows (WSL2)</summary>

```bash
# PowerShell como Administrador:
wsl --install
# Reiniciar el equipo

# Dentro de WSL:
sudo apt update && sudo apt install -y docker.io docker-compose-v2
sudo usermod -aG docker $USER
# Cerrar y abrir sesión de WSL

git clone https://github.com/statick88/lab-linux.git
cd lab-linux
docker compose build && docker compose up -d
docker compose exec lab-linux bash
```
</details>

---

## Comandos del Contenedor

| Comando | Qué hace | Cómo se accede |
|---------|----------|----------------|
| `menu` | Menú principal con progreso global | Alias en .bash_aliases |
| `jugar` | Modo interactivo: instrucción → comando → verificar | Alias en .bash_aliases |
| `unidad <n>` | Seleccionar unidad (ej: `unidad 3`) | Alias en .bash_aliases |
| `retos` | Ver retos de la unidad actual | Alias en .bash_aliases |
| `evaluar` | Ejecutar validación y mostrar puntaje | Alias en .bash_aliases |
| `revelar-frase` | Revelar palabra al completar una unidad | Alias en .bash_aliases |
| `progreso` | Ver barra de progreso global | Alias en .bash_aliases |
| `ayuda` | Lista de comandos disponibles | Función en menu.sh |
| `~/bin/lab` | Lanza el menú interactivo desde cualquier ruta | Script en ~/bin/ |

---

## Flujo por Unidad

```
Seleccionar → Instrucciones → Resolver → Validar → Revelar palabra
    │              │              │           │            │
    ▼              ▼              ▼           ▼            ▼
unidad 2       retos        (terminal)    evaluar    revelar-frase
```

1. **Seleccionar** → `unidad 2` cambia la unidad activa
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

## Solución de Problemas

| Problema | Solución |
|----------|----------|
| Contenedor no inicia | `docker compose logs lab-linux` → `docker compose build --no-cache` |
| Comandos no funcionan | Verificar que estás dentro: `docker compose exec lab-linux bash` |
| Pruebas fallan | directorio debe ser `~/laboratorio`, nombres exactos |
| Docker-in-Docker falla | Verificar `privileged: true` y `/var/run/docker.sock` montado |

---

## Arquitectura

```
lab-linux/
├── Dockerfile              # Ubuntu 24.04 + usuario estudiante
├── docker-compose.yml      # Volumen persistente lab-data
├── entrypoint.sh           # Sourcing, aliases y banner
├── shared/                 # Librería compartida
│   ├── common.sh           # Funciones base, FRASES_OCULTAS, carga todos los módulos
│   ├── menu.sh             # Menú principal y navegación
│   ├── interactive.sh      # Funciones interactivas (jugar, evaluar, retos)
│   ├── eval.sh             # Sistema de evaluación
│   ├── colors.sh           # Colores de terminal
│   ├── banner.sh           # Banners visuales
│   └── metrics.sh          # Métricas de progreso
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

### Cadena de Sourcing

```
entrypoint.sh
  └→ common.sh → colors.sh, eval.sh, metrics.sh, menu.sh, banner.sh
  └→ interactive.sh
  └→ crea .bash_aliases + ~/bin/lab
  └→ banner_bienvenida
  └→ exec bash -i

Cada shell nueva:
  .bashrc → .bash_aliases → common.sh + interactive.sh → funciones disponibles
```

---

## Novedades v1.1.0

- **Comandos interactivos funcionan en cualquier shell**: `menu`, `jugar`, `retos`, `evaluar`, `revelar-frase` ahora usan funciones cargadas desde `shared/interactive.sh` vía `.bash_aliases`
- **Autocompletado Tab habilitado**: instalado `bash-completion` en la imagen base
- **Instrucciones paso a paso claras**: Unidad III (Scripting) muestra comandos en líneas separadas para evitar errores de copiado
- **Validadores robustos**: reto 5 (Permisos 755) ahora verifica el archivo `archivo` del estudiante, no un archivo temporal interno

---

## Contribuir

Ver [CONTRIBUTING.md](CONTRIBUTING.md) para la estrategia de ramas y flujo de trabajo.

---

## Autor

**Lic. Diego Medardo Saavedra García, Mg. Sc.**
🌐 https://statick88.github.io
✉️ dsaavedra88@gmail.com

---

*Curso "Fundamentos de Sistemas Operativos y Administración de Servidores en Red"*
