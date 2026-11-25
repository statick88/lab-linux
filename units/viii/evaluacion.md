# Unit VIII — Docker Containers
## Evaluación: 2 preguntas prácticas

> **Alcance del reto 10:** es una decisión de limpieza sintética. Revisa `~/laboratorio/docker/reto10_inventario.txt` y crea `reto10_plan.txt` seleccionando solo los ID con `propietario=unidad-viii` y `desechable=si`. Cada entrada debe tener el formato `eliminar id=<ID>`. `bash reto10.sh` y el evaluador son de solo lectura: no contactan Docker ni realizan limpieza. No uses comandos globales como `docker system prune`.

---

### Pregunta 1 — Ejecución de contenedor y validación de salida

**Título:** Container ops ticket — hello-world Ubuntu container

**Escenario:**  
El equipo de DevOps necesita automatizar la validación de que Docker está operativo en el runner de CI. Debes ejecutar un contenedor efímero de Ubuntu que imprima un mensaje de prueba y capturar la salida exacta para el pipeline de verificación. Como evidencia, el validador comparará la salida estándar del contenedor contra el valor esperado.

**Requisitos:**
- Ejecutar `docker run --rm ubuntu:latest echo "test"`.
- Capturar la salida estándar en una variable o archivo.
- Confirmar que el contenedor se elimina automáticamente después de la ejecución.

**Restricciones:**
- No usar `docker exec` sobre contenedores en ejecución; usar `docker run`.
- No publicar la imagen en ningún registro.
- El contenedor debe ejecutarse en modo `--rm` para no dejar residuos.

**Criterios de validación:**
- `docker ps -a` no muestra el contenedor después de la ejecución.
- La salida capturada es exactamente `test`.

**Pregunta de selección múltiple:**

> Después de ejecutar `docker run --rm ubuntu:latest echo "test"`, ¿cuál es el valor exacto de la variable `$?` (exit code) retornado por el comando, asumiendo que la imagen se descargó previamente?

A) 0  
B) 1  
C) 2  
D) 127  

**Explicación de distractores:**
- B) 1: código de error genérico; lo retorna Docker cuando el comando dentro del contenedor falla, pero `echo "test"` no falla.
- C) 2: código de error por argumentos inválidos en Docker; no aplica porque `docker run` recibe argumentos válidos.
- D) 127: típicamente indica "comando no encontrado"; podría aparecer si `ubuntu:latest` no existiera localmente y no se pudiera descargar, pero el escenario asume imagen disponible.

**Respuesta correcta:** A) 0  
**Evidencia:** El `test.sh` de Unit VIII, Reto 2, verifica que `[ "$output" = "test" ]` y que el contenedor se ejecuta correctamente, lo que implica exit code 0. Se confirma ejecutando: `docker run --rm ubuntu:latest echo "test"; echo $?`.

---

### Pregunta 2 — Construcción de imagen personalizada y validación de CMD

**Título:** Image build ticket — custom Ubuntu image with nano

**Escenario:**  
El equipo de infraestructura debe empaquetar una imagen base personalizada que incluya `nano` preinstalado. Debes escribir el Dockerfile, construir la imagen con tag `mi_imagen` y ejecutarla para confirmar que el CMD se ejecuta correctamente. Como evidencia, el validador capturará la salida del contenedor en ejecución.

**Requisitos:**
- Crear un Dockerfile con al menos `FROM ubuntu:latest`, `RUN apt-get update && apt-get install -y nano` y `CMD ["echo", "imagen_creada"]`.
- Construir la imagen con `docker build -t mi_imagen -f /tmp/Dockerfile.custom /tmp/`.
- Ejecutar `docker run --rm mi_imagen` y capturar la salida.

**Restricciones:**
- No dejar procesos colgados; usar `--rm`.
- El Dockerfile debe estar en `/tmp/Dockerfile.custom` para coincidir con el validador.
- No usar `sudo` si Docker está disponible para el usuario actual.

**Criterios de validación:**
- `docker images` lista `mi_imagen`.
- `docker run --rm mi_imagen` imprime exactamente `imagen_creada`.

**Pregunta de selección múltiple:**

> Después de construir y ejecutar la imagen personalizada, ¿cuál es la salida exacta del `CMD` definido en el Dockerfile del Reto 9?

A) `Hola Mundo`  
B) `imagen_creada`  
C) `Imagen personalizada creada`  
D) `test`  

**Explicación de distractores:**
- A) `Hola Mundo`: coincide con el texto de ejemplo en el mensaje informativo `reto9_info()` del `test.sh`, pero no con el CMD real del Dockerfile del `setup.sh`.
- C) `Imagen personalizada creada`: coincide con el mensaje de éxito del `setup.sh`, pero no con el `CMD` del Dockerfile, que usa `echo "imagen_creada"`.
- D) `test`: coincide con el `test.sh` (Reto 9 usa `CMD ["echo", "image_test"]` en su validador interno), pero no con el `setup.sh` del estudiante.

**Respuesta correcta:** B) `imagen_creada`  
**Evidencia:** El `setup.sh` de Unit VIII, Reto 9, define `CMD ["echo", "imagen_creada"]` en el Dockerfile generado. Se confirma ejecutando: `docker build -t mi_imagen -f /tmp/Dockerfile.custom /tmp/ && docker run --rm mi_imagen`.
