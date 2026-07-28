# Laboratorio Interactivo: Administración de Servidores Linux

Curso completo de **11 unidades progresivas** con retos prácticos, evaluación automática y modo tutorial guiado. Se ejecuta en contenedor Docker con entorno de pruebas integrado.

> **Estado actual:** 10/11 unidades implementadas (Unidad I pendiente). Ver [Progreso](#progreso-de-implementación).

---

## Inicio Rápido

```bash
# 1. Clonar y entrar
git clone <url-del-repositorio>
cd lab-linux

# 2. Construir imagen
docker compose build

# 3. Levantar contenedor
docker compose up -d

# 4. Entrar al laboratorio
docker compose exec lab-linux bash
```

Dentro del contenedor verás el banner de bienvenida con los comandos disponibles.

---

## Comandos Disponibles (Dentro del Contenedor)

| Comando | Descripción |
|---------|-------------|
| `evaluar` | Ejecuta las pruebas de validación y muestra tu puntaje |
| `lab` | Navega al directorio del laboratorio (`~/laboratorio`) |
| `unidad <n>` | Cambia a la unidad n (ej: `unidad 2`) |
| `retos` | Muestra las instrucciones y retos de la unidad actual |
| `revelar-frase` | Muestra la frase oculta al completar todos los retos de la unidad |
| `generar-respuestas` | Genera archivo de evidencia de finalización |

---

## Estructura del Curso

| Unidad | Tema | Estado | Retos |
|--------|------|--------|-------|
| I | Fundamentos de Linux y WSL2 | ⏳ Pendiente | — |
| II | Gestión de Paquetes y APT | ✅ Implementada | 3 |
| III | Scripting Bash | ✅ Implementada | 3 |
| IV | Gestión de Usuarios y SSH | ✅ Implementada | 3 |
| V | Gestión de Procesos y systemd | ✅ Implementada | 3 |
| VI | Gestión de Almacenamiento y LVM | ✅ Implementada | 3 |
| VII | Hardening del Sistema | ✅ Implementada | 3 |
| VIII | Contenedores con Docker | ✅ Implementada | 3 |
| IX | Servidor Web con Nginx | ✅ Implementada | 3 |
| X | Certificados SSL y HTTPS | ✅ Implementada | 3 |
| XI | Docker Compose y Bases de Datos | ✅ Implementada | 3 |

**Total:** 30 retos implementados, 33 planificados.

---

## Flujo de Trabajo por Unidad

1. **Seleccionar unidad:** `unidad 2`
2. **Ver retos:** `retos` — muestra instrucciones paso a paso con pistas progresivas
3. **Resolver:** Ejecuta comandos en la terminal
4. **Validar:** `evaluar` — muestra ✓ PASS / ✗ FAIL por reto
5. **Evidencia:** `generar-respuestas` — crea `respuestas-YYYY-MM-DD-HH-MM-SS.md`
6. **Frase oculta:** `revelar-frase` — revela palabra al completar todos los retos de la unidad

---

## Validación

El script `test.sh` valida automáticamente cada reto:

```
[UNIDAD II] Gestión de Paquetes y APT
  [RETO 1] Actualizar caché e instalar paquete
    ✓ PASS  apt update ejecutado
    ✓ PASS  curl instalado
  [RETO 2] Buscar y mostrar info de paquete
    ✓ PASS  apt search nginx
    ✓ PASS  apt show nginx
  [RETO 3] Limpiar caché y verificar espacio
    ✓ PASS  apt clean ejecutado

RESULTADO FINAL:
  Retos completados: 3 / 3
  Porcentaje: 100%
  [████████████████████████████]

🎉 ¡UNIDAD COMPLETADA!
📝 Palabra: CONOCIMIENTO
```

---

## Generación de Evidencia

```bash
# Dentro del contenedor, tras completar una unidad
generar-respuestas

# El archivo se guarda en ~/laboratorio/respuestas-*.md
# Copiar al host:
docker cp lab-linux:/home/estudiante/laboratorio/respuestas-*.md .
```

---

## Arquitectura del Repositorio

```
lab-linux/
├── Dockerfile              # Imagen base Ubuntu 24.04 + usuario estudiante
├── docker-compose.yml      # Orquestación con volumen persistente lab-data
├── entrypoint.sh           # Configura aliases y banner de bienvenida
├── test.sh                 # Validador global (10 desafíos legacy)
├── manual.sh               # Tutorial interactivo legacy (5 retos)
├── revelar-frase.sh        # Sistema de frase oculta legacy
├── generar-respuestas.sh   # Generador de evidencia legacy
├── plantilla.md            # Plantilla de respuestas legacy
├── shared/                 # Librería compartida
│   ├── colors.sh           # Códigos de color ANSI
│   ├── eval.sh             # Assertions y contadores de prueba
│   ├── menu.sh             # Menús interactivos por unidad
│   ├── banner.sh           # Banners de bienvenida/unidad
│   └── utils.sh            # Utilidades comunes (logging, paths)
├── units/                  # Unidades II–XI (10 directorios)
│   ├── ii/                 # Gestión de Paquetes
│   │   ├── setup.sh        # Preparación del entorno
│   │   ├── manual.sh       # Tutorial guiado con pistas
│   │   └── test.sh         # Validación de 3 retos
│   ├── iii/                # Scripting Bash
│   ├── iv/                 # Usuarios y SSH
│   ├── v/                  # Procesos y systemd
│   ├── vi/                 # Almacenamiento y LVM (simulado)
│   ├── vii/                # Hardening
│   ├── viii/               # Docker (DinD habilitado)
│   ├── ix/                 # Nginx
│   ├── x/                  # SSL/HTTPS (staging + producción)
│   └── xi/                 # Docker Compose + MariaDB
├── propuesta-pedagogica.md # Documento completo del curso (11 unidades)
├── verify-report.md        # Informe de verificación SDD
└── README.md               # Este archivo
```

---

## Prerrequisitos

- Docker Engine 24+
- Docker Compose (incluido en Docker Desktop)
- 4 GB RAM libres (para DinD en Unidad VIII)
- Linux / macOS / Windows con WSL2

---

## Solución de Problemas

| Problema | Solución |
|----------|----------|
| Contenedor no inicia | `docker compose logs lab-linux` → `docker compose build --no-cache` |
| Comandos `evaluar`/`unidad` no funcionan | Estar dentro del contenedor: `docker compose exec lab-linux bash` |
| Pruebas fallan tras completar retos | Verificar directorio actual (`~/laboratorio`) y nombres exactos |
| Docker-in-Docker falla (Unidad VIII) | Verificar que `docker-compose.yml` tiene `privileged: true` y `/var/run/docker.sock` montado |

---

## Personalización

### Editor por defecto
```bash
# En .env
DEFAULT_EDITOR=vim  # o nano, code
```

### Agregar herramientas
Editar `Dockerfile` → sección `apt-get install`.

---

## Progreso de Implementación

| Fase SDD | Estado | Artefacto |
|----------|--------|-----------|
| Preflight | ✅ | 4 decisiones cacheadas |
| Init | ✅ | `sdd-init/lab` (engram #5031) |
| Explore | ✅ | `sdd/full-course/explore` |
| Propose | ✅ | `openspec/changes/full-course/proposal.md` |
| Spec | ✅ | 99 requisitos, 27 escenarios |
| Design | ✅ | `openspec/changes/full-course/design.md` |
| Tasks | ✅ | 40 tareas, 7 PRs encadenados |
| Apply | ✅ | 5 commits, 35 archivos |
| Verify | ✅ | 2 bugs corregidos (Unit VI retos, Docker socket) |
| Archive | ✅ | `sdd/full-course/archive-report` |

**Pendiente:** Unidad I (Fundamentos) — no bloquea el resto del curso.

---

## Licencia

Uso educativo libre. Modificación y distribución permitida en contextos académicos.

---

## Autor

**Lic. Diego Medardo Saavedra García, Mg. Sc.**  
🌐 https://statick88.github.io  
✉️ dsaavedra88@gmail.com  
📞 +593 98 019 2790

---

*Desarrollado para el curso "Fundamentos de Sistemas Operativos y Administración de Servidores en Red"*