# Preguntas de Evaluación - Unidad VIII: Docker

> **Nota de seguridad para el reto 10:** es un ejercicio sintético de decisión, no una limpieza del daemon. El inventario contiene recursos propios, desechables y ajenos; el plan debe seleccionar únicamente los ID propios y desechables. No se evalúa ni se autoriza `docker system prune` ni ninguna eliminación global.

## Pregunta 1: Verificación de imagen personalizada en pipeline de CI/CD

**Escenario**:
El pipeline de CI/CD del proyecto de monitoreo falló en la etapa de validación de artefactos. Como ingeniero DevOps, debes construir manualmente la imagen Docker personalizada definida en el reto 9 y verificar que la salida del contenedor coincide con el valor esperado en producción antes de re-ejecutar el pipeline.

**Requisitos**:
- Construir la imagen `mi_imagen` desde el Dockerfile ubicado en `/tmp/Dockerfile.custom`
- Ejecutar un contenedor efímero a partir de `mi_imagen` usando `docker run --rm`
- Capturar y comparar la salida estándar (stdout) del contenedor

**Restricciones**:
- No modificar el contenido del Dockerfile en `/tmp/Dockerfile.custom`
- No usar imágenes pre-construidas del registro de Docker Hub
- El contenedor debe ejecutarse con la flag `--rm` para no dejar residuos
- No eliminar la imagen después de la verificación

**Criterios de Validación**:
- `docker run --rm mi_imagen` produce exactamente: `Imagen personalizada creada`
- `docker images --format "{{.Repository}}:{{.Tag}}" | grep mi_imagen` devuelve: `mi_imagen:latest`
- `docker inspect mi_imagen --format "{{.Config.Cmd}}"` contiene: `echo` e `Imagen personalizada creada`

**Pregunta de Selección Múltiple**:

¿Qué valor exacto produce la salida estándar (stdout) al ejecutar `docker run --rm mi_imagen` después de construir la imagen desde el Dockerfile del reto 9?

A) `test`
B) `Imagen personalizada creada`
C) `Hola desde Docker`
D) `image_test`

**Explicación**:
- Respuesta correcta: B) `Imagen personalizada creada` - Es el valor definido en la instrucción CMD del Dockerfile (`CMD ["echo", "Imagen personalizada creada"]`). El comando `docker run --rm mi_imagen` ejecuta el CMD por defecto de la imagen, que invoca `echo` con ese argumento, produciendo exactamente esa salida sin caracteres adicionales.
- Distractor A: `test` - Es la salida del comando `RUN echo "test"` durante la construcción de la imagen, no del CMD. Los comandos RUN solo producen salida durante el build, no cuando se ejecuta el contenedor.
- Distractor C: `Hola desde Docker` - Es la salida del contenedor del reto 2 (`docker run --rm ubuntu:latest echo "Hola desde Docker"`). Corresponde a un reto diferente de ejecución básica.
- Distractor D: `image_test` - Es el valor utilizado por el script de validación automatizada interna (`test.sh`) para verificar el reto 9, pero no coincide con el Dockerfile real del reto 9 creado por `setup.sh`.

---

## Pregunta 2: Verificación de persistencia de datos en volumen Docker

**Escenario**:
Un desarrollador reportó que el contenedor de la aplicación de reportes no mantiene los datos después de ser reiniciado. Debes demostrar que el almacenamiento por volúmenes de Docker funciona correctamente en el entorno, creando un volumen, escribiendo datos desde un contenedor efímero, y verificando que los datos persisten independientemente del ciclo de vida del contenedor.

**Requisitos**:
- Crear el volumen `mi_volumen` usando `docker volume create`
- Ejecutar un contenedor `ubuntu:latest` que monte `mi_volumen` en `/datos` y escriba un archivo
- Leer el contenido exacto del archivo persistido en el volumen

**Restricciones**:
- Usar únicamente volúmenes gestionados por Docker (no bind mounts)
- El volumen debe llamarse exactamente `mi_volumen`
- No eliminar el volumen después de la verificación
- No modificar el script del reto 8

**Criterios de Validación**:
- `docker volume ls | grep mi_volumen` muestra el volumen `mi_volumen`
- `docker run --rm -v mi_volumen:/datos ubuntu:latest cat /datos/archivo.txt` produce exactamente: `Dato guardado`
- `docker volume inspect mi_volumen --format "{{.Name}}"` devuelve: `mi_volumen`
- `docker volume inspect mi_volumen --format "{{.Mountpoint}}"` devuelve una ruta que contiene `/var/lib/docker/volumes/mi_volumen/_data`

**Pregunta de Selección Múltiple**:

¿Qué contenido exacto tiene el archivo `/datos/archivo.txt` dentro del volumen `mi_volumen` después de ejecutar el contenedor del reto 8?

A) `logtest`
B) `Hola desde Docker`
C) `""` (archivo vacío)
D) `Dato guardado`

**Explicación**:
- Respuesta correcta: D) `Dato guardado` - Es el contenido escrito por el comando `echo 'Dato guardado' > /datos/archivo.txt` ejecutado dentro del contenedor del reto 8. La redirección `>` escribe esa cadena exacta en el archivo dentro del volumen montado.
- Distractor A: `logtest` - Es la salida del contenedor del reto 5 (`echo logtest`), utilizado para validar logs. Un estudiante podría confundir el reto de logs con el reto de volúmenes.
- Distractor B: `Hola desde Docker` - Es la salida del contenedor del reto 2. Corresponde a un reto diferente de ejecución básica.
- Distractor C: `""` (archivo vacío) - Ocurriría si el estudiante crea el volumen pero no ejecuta el contenedor que escribe el archivo, o si el montaje del volumen falla silenciosamente.
