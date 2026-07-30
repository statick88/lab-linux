# Laboratorio Interactivo: Administración de Servidores Linux

11 unidades progresivas · 110 retos prácticos · evaluación automática · frase secreta oculta. Todo corre en Docker.

---

## Inicio Rápido

```bash
git clone <url-del-repositorio>
cd lab-linux
docker compose build
docker compose up -d
docker compose exec lab-linux bash
```

Dentro del contenedor: `menu` para navegar, `evaluar` para validar, `jugar` para modo interactivo.

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
- 4 GB RAM libres (DinD en Unidad VIII)
- Linux / macOS / Windows con WSL2

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

## Autor

**Lic. Diego Medardo Saavedra García, Mg. Sc.**
🌐 https://statick88.github.io
✉️ dsaavedra88@gmail.com

---

*Curso "Fundamentos de Sistemas Operativos y Administración de Servidores en Red"*
