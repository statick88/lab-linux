# Laboratorio: Fundamentos de Sistemas de Archivos y Terminal Linux

## Descripción

Laboratorio interactivo para aprender fundamentos de administración de sistemas de archivos y comandos de terminal en Linux. El laboratorio se ejecuta en un contenedor Docker con un entorno de pruebas automatizado.

**Características principales:**
- 5 retos guiados con instrucciones paso a paso
- Validación automática de cada reto
- Frase oculta que se revela al completar todos los retos
- Generación automática de evidencia de finalización

## Prerrequisitos

- Docker instalado en tu sistema
- Docker Compose (incluido en Docker Desktop)
- Terminal o línea de comandos

## Inicio Rápido

### 1. Clonar o descargar el repositorio

```bash
# Si usas git
git clone <url-del-repositorio>
cd lab-filesystem-bash

# O simplemente navega al directorio del laboratorio
cd /Users/statick/prueba/lab
```

### 2. Construir la imagen Docker

```bash
docker compose build
```

### 3. Levantar el contenedor

```bash
docker compose up -d
```

### 4. Entrar al contenedor

```bash
docker compose exec lab-linux bash
```

### 5. ¡Comenzar el laboratorio!

Una vez dentro del contenedor, verás un banner de bienvenida con los comandos disponibles.

## Comandos Disponibles (Dentro del Contenedor)

| Comando | Descripción |
|---------|-------------|
| `evaluar` | Ejecuta las pruebas de validación y muestra tu puntaje |
| `lab` | Navega al directorio del laboratorio (`~/laboratorio`) |
| `retos` | Muestra las instrucciones y retos del laboratorio |
| `revelar-frase` | Muestra la frase oculta cuando todos los retos están completados |
| `generar-respuestas` | Genera tu archivo de respuestas como evidencia de finalización |

## Retos del Laboratorio

### Reto 1: Navegación
- Crea el directorio `/tmp/backup`
- Demuestra que puedes navegar entre directorios
- **Palabra oculta:** Se revela al completar

### Reto 2: Creación de Directorios y Estructura
- Crea la estructura `~/laboratorio/proyectos/web/html`
- Crea la estructura `~/laboratorio/proyectos/web/css`
- Demuestra uso de `mkdir -p`
- **Palabra oculta:** Se revela al completar

### Reto 3: Creación y Edición de Archivos
- Crea `index.html` en `proyectos/web/html/` con contenido HTML específico
- Crea `main.css` en `proyectos/web/css/` con estilos CSS específicos
- Demuestra uso de editores (`nano`, `vim`) o redirección
- **Palabra oculta:** Se revela al completar

### Reto 4: Copia y Movimiento
- Copia `index.html` a `~/laboratorio/proyectos/web/index.bak`
- Renombra `styles.css` a `main.css`
- Demuestra uso de `cp`, `mv`
- **Palabra oculta:** Se revela al completar

### Reto 5: Eliminación Limpia
- Elimina el directorio `temp_dir` y su contenido
- Demuestra uso de `rm -r`
- **Frase completa:** Se revela la frase oculta completa

## Frase Oculta

Al completar cada reto, se revela una palabra. Al completar los 5 retos, se desoculta la frase completa:

| Reto | Palabra |
|------|---------|
| 1 | ??? |
| 2 | ??? |
| 3 | ??? |
| 4 | ??? |
| 5 | **Frase completa** |

Usa `revelar-frase` para ver tu progreso.

## Generación de Evidencia

Una vez completados todos los retos:

```bash
# Genera tu archivo de respuestas
generar-respuestas

# El archivo se guarda como ~/laboratorio/respuestas-YYYY-MM-DD-HH-MM-SS.md
# Cópialo a tu máquina host:
docker cp lab-linux:/home/estudiante/laboratorio/respuestas-*.md .
```

## Plantilla de Respuestas

El archivo `plantilla.md` se proporciona dentro del contenedor para que registres tus respuestas durante el laboratorio. Puedes editarlo directamente:

```bash
# Dentro del contenedor
nano ~/laboratorio/plantilla.md
```

## Validación

El script `test.sh` valida automáticamente que todos los retos se hayan completado correctamente. Al ejecutar `evaluar`, verás:

- **✓ PASS** - Reto completado exitosamente
- **✗ FAIL** - Reto no completado o con errores
- **Puntaje final** - Resumen de progreso

### Ejemplo de salida:

```
  [RETO 1] Navegación: /tmp, backup, ~
    ✓ /tmp/backup existe y es un directorio
  ✓ PASS  Reto 1: Navegación

  [RETO 2] Creación de Directorios y Estructura
    ✓ ~/laboratorio/proyectos/web/html existe
    ✓ ~/laboratorio/proyectos/web/css existe
  ✓ PASS  Reto 2: Creación de Directorios

  ...

  RESULTADO FINAL:

  Retos completados: 5 / 5
  Porcentaje: 100%

  [████████████████████████████]

  🎉 ¡FELICIDADES! ¡Todos los retos completados exitosamente!

  📝 Frase oculta: EL CONOCIMIENTO ES PODER
```

## Estructura del Repositorio

```
lab-filesystem-bash/
├── Dockerfile          # Configuración del contenedor
├── docker-compose.yml  # Orquestación del servicio
├── entrypoint.sh       # Punto de entrada del contenedor
├── test.sh             # Script de validación de retos
├── manual.sh           # Script interactivo con retos guiados
├── revelar-frase.sh    # Revela la frase oculta
├── generar-respuestas.sh # Genera evidencia de finalización
├── plantilla.md        # Plantilla para respuestas del estudiante
├── .env                # Variables de entorno (opcional)
└── README.md           # Este archivo
```

## Solución de Problemas

### El contenedor no inicia
```bash
# Verificar logs
docker compose logs lab-linux

# Reconstruir la imagen
docker compose build --no-cache
docker compose up -d
```

### Los comandos `evaluar` o `lab` no funcionan
- Asegúrate de estar dentro del contenedor con `docker compose exec lab-linux bash`
- Los aliases se configuran automáticamente al iniciar el contenedor

### Las pruebas fallan aunque completé los retos
- Verifica que estés en el directorio correcto (`~/laboratorio`)
- Revisa que los nombres de archivos y directorios coincidan exactamente con las especificaciones
- Ejecuta `evaluar` nuevamente para ver los detalles

## Personalización

### Cambiar el editor predeterminado
Edita el archivo `.env` y modifica `DEFAULT_EDITOR`:
```
DEFAULT_EDITOR=vim  # o nano, code, etc.
```

### Agregar herramientas adicionales
Edita el `Dockerfile` y agrega paquetes en la sección `apt-get install`.

## Licencia

Este laboratorio es para uso educativo. Puedes modificarlo y distribuirlo libremente en contextos académicos.

## Autor

Desarrollado para el curso de Fundamentos de Sistemas Operativos y Administración de Servidores en Red.
