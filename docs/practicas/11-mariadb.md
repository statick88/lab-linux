# Práctica XI — MariaDB: datos, privilegios, respaldo y rendimiento

## Propósito

En esta práctica guiada crearás una base de datos **sintética** en MariaDB,
diseñarás un usuario de mínimo privilegio, harás una copia lógica y la
restaurarás en otro esquema. Al final interpretarás `EXPLAIN` y comprobarás la
mejora de una consulta con evidencia medible.

> **Entorno aislado obligatorio.** Usa únicamente el contenedor efímero de
> esta guía y los datos inventados incluidos abajo. No apuntes comandos a
> servidores de trabajo, producción, aulas compartidas ni copias reales. No
> pegues contraseñas, hostnames ni volcados de sistemas reales en el informe.

## Resultados de aprendizaje

- Crear tablas, claves y datos de prueba con SQL reproducible.
- Aplicar privilegios mínimos a una cuenta de aplicación.
- Generar y verificar un respaldo lógico, y restaurarlo bajo otro esquema.
- Leer el plan de ejecución y justificar un índice con métricas antes/después.

## 1. Preparar un laboratorio desechable

Requisitos: Docker instalado en tu equipo y un puerto local disponible. Estas
órdenes crean un contenedor nuevo con un volumen anónimo gestionado por Docker;
no reutilizan una instancia, datos MariaDB ni otros recursos preexistentes.

```bash
mkdir -p "$HOME/mariadb-xi-lab" && cd "$HOME/mariadb-xi-lab"
chmod 700 .
export MARIADB_ROOT_PASSWORD='cambia-esta-clave-solo-local'
export MARIADB_CONTAINER="$(docker run -d \
  -e MARIADB_ROOT_PASSWORD="$MARIADB_ROOT_PASSWORD" \
  -v /var/lib/mysql \
  mariadb:11)"
until docker exec "$MARIADB_CONTAINER" mariadb-admin ping -uroot \
  -p"$MARIADB_ROOT_PASSWORD" --silent; do sleep 2; done
```

La contraseña anterior es un ejemplo local, no un secreto reutilizable. No
expongas el puerto del contenedor: todos los clientes de esta práctica se
ejecutan con `docker exec`. Confirma el aislamiento:

```bash
docker ps --filter "id=$MARIADB_CONTAINER" --format 'table {{.ID}}\t{{.Status}}'
docker exec "$MARIADB_CONTAINER" mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" \
  -e 'SELECT @@hostname AS contenedor, @@version AS version;'
```

**Evidencia 1:** guarda la salida, mostrando el identificador del contenedor y
la versión, sin incluir la contraseña.

## 2. Crear esquema y filas sintéticas

Crea el archivo `01-datos.sql` con este contenido. Los nombres, correos,
importes y pedidos son ficticios.

```sql
CREATE DATABASE ventas_xi CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ventas_xi;

CREATE TABLE clientes (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(80) NOT NULL,
  correo VARCHAR(120) NOT NULL UNIQUE,
  ciudad VARCHAR(60) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE pedidos (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  cliente_id INT UNSIGNED NOT NULL,
  creado_en DATE NOT NULL,
  total DECIMAL(10,2) NOT NULL,
  estado ENUM('nuevo','pagado','enviado') NOT NULL,
  CONSTRAINT fk_pedidos_cliente FOREIGN KEY (cliente_id) REFERENCES clientes(id)
) ENGINE=InnoDB;

INSERT INTO clientes (nombre, correo, ciudad) VALUES
  ('Ada Norte', 'ada.norte@example.test', 'Sevilla'),
  ('Bruno Río', 'bruno.rio@example.test', 'Bilbao'),
  ('Celia Mar', 'celia.mar@example.test', 'Sevilla'),
  ('Diego Sol', 'diego.sol@example.test', 'Valencia');

INSERT INTO pedidos (cliente_id, creado_en, total, estado) VALUES
  (1, '2025-01-10', 120.50, 'pagado'),
  (1, '2025-02-18', 42.00, 'enviado'),
  (2, '2025-02-03', 210.00, 'pagado'),
  (3, '2025-03-01', 18.75, 'nuevo'),
  (3, '2025-03-12', 95.20, 'pagado'),
  (4, '2025-03-20', 300.00, 'enviado');
```

Cárgalo y verifica tanto el número de filas como la integridad referencial:

```bash
docker exec -i "$MARIADB_CONTAINER" mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" < 01-datos.sql
docker exec "$MARIADB_CONTAINER" mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" -N -e \
  'SELECT COUNT(*) AS clientes FROM ventas_xi.clientes; SELECT COUNT(*) AS pedidos FROM ventas_xi.pedidos;'
docker exec "$MARIADB_CONTAINER" mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" -e \
  'SELECT p.id, c.nombre, p.total FROM ventas_xi.pedidos p JOIN ventas_xi.clientes c ON c.id=p.cliente_id ORDER BY p.id;'
```

La primera consulta debe devolver `4` y `6`. **Evidencia 2:** conserva esa
salida y una fila de la unión; explica por qué `cliente_id` no puede contener
un cliente inexistente.

## 3. Conceder el mínimo privilegio

Como administrador local del contenedor, crea una cuenta exclusiva de lectura.
No uses `GRANT ALL`, no uses `%` como host y no reutilices esta clave fuera del
contenedor.

```bash
docker exec "$MARIADB_CONTAINER" mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" -e "
  CREATE USER IF NOT EXISTS 'consulta_xi'@'localhost' IDENTIFIED BY 'solo-lab-xi';
  GRANT SELECT ON ventas_xi.* TO 'consulta_xi'@'localhost';
  SHOW GRANTS FOR 'consulta_xi'@'localhost';"
```

Comprueba el permiso permitido y uno prohibido. El segundo comando **debe
fallar** con acceso denegado; ese fallo es la evidencia de mínimo privilegio.

```bash
docker exec "$MARIADB_CONTAINER" mariadb -uconsulta_xi -psolo-lab-xi -e \
  'SELECT COUNT(*) FROM ventas_xi.pedidos;'
docker exec "$MARIADB_CONTAINER" mariadb -uconsulta_xi -psolo-lab-xi -e \
  "INSERT INTO ventas_xi.clientes(nombre, correo, ciudad) VALUES ('Prueba', 'prueba@example.test', 'Lugo');"
```

**Evidencia 3:** anota `SHOW GRANTS`, el resultado del `SELECT` y el mensaje de
acceso denegado del `INSERT`. No incluyas claves en la entrega.

## 4. Respaldar y restaurar en otro esquema

Genera un volcado lógico local. El archivo contiene datos de laboratorio, pero
trátalo como información sensible: deja sus permisos en `600` y no lo subas.

```bash
docker exec "$MARIADB_CONTAINER" mariadb-dump -uroot -p"$MARIADB_ROOT_PASSWORD" \
  --databases --single-transaction --routines --events ventas_xi > ventas_xi.sql
chmod 600 ventas_xi.sql
grep -E '^(CREATE TABLE|INSERT INTO)' ventas_xi.sql | head -n 4
```

Crea el destino vacío, restaura allí cambiando sólo el nombre del esquema en el
flujo de entrada y compara conteos. No ejecutes la restauración sobre
`ventas_xi`: el destino es deliberadamente `ventas_xi_restaurada`.

```bash
docker exec "$MARIADB_CONTAINER" mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" -e \
  'CREATE DATABASE ventas_xi_restaurada CHARACTER SET utf8mb4;'
sed 's/`ventas_xi`/`ventas_xi_restaurada`/g' ventas_xi.sql | \
  docker exec -i "$MARIADB_CONTAINER" mariadb -uroot -p"$MARIADB_ROOT_PASSWORD"
docker exec "$MARIADB_CONTAINER" mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" -e '
  SELECT "origen" AS copia, COUNT(*) AS pedidos FROM ventas_xi.pedidos
  UNION ALL
  SELECT "restaurada", COUNT(*) FROM ventas_xi_restaurada.pedidos;'
```

**Evidencia 4:** ambas filas deben indicar `6`. Indica que el respaldo es
lógico y que la restauración se hizo en un esquema distinto, no sobre el origen.

## 5. Medir e interpretar una optimización

Primero añade una carga sintética suficiente para que el plan sea observable;
no modifica los datos del respaldo ya creado. Después observa el plan sin
índice compuesto, añade el índice y repite exactamente el mismo
`EXPLAIN FORMAT=JSON`:

```bash
docker exec "$MARIADB_CONTAINER" mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" -e '
  INSERT INTO ventas_xi.pedidos (cliente_id, creado_en, total, estado)
  SELECT 1 + MOD(n, 4), DATE_ADD("2024-01-01", INTERVAL n DAY),
         10.00 + MOD(n, 90), "pagado"
  FROM (
    SELECT u.n + 10*d.n + 100*c.n + 1000*m.n AS n
    FROM (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) u
    CROSS JOIN (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) d
    CROSS JOIN (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) c
    CROSS JOIN (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) m
  ) AS serie;
  ANALYZE TABLE ventas_xi.pedidos;
  EXPLAIN FORMAT=JSON SELECT id, total FROM ventas_xi.pedidos
  WHERE cliente_id = 3 AND creado_en >= "2026-01-01";'
docker exec "$MARIADB_CONTAINER" mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" -e '
  CREATE INDEX idx_pedidos_cliente_fecha ON ventas_xi.pedidos (cliente_id, creado_en);
  ANALYZE TABLE ventas_xi.pedidos;
  EXPLAIN FORMAT=JSON SELECT id, total FROM ventas_xi.pedidos
  WHERE cliente_id = 3 AND creado_en >= "2026-01-01";'
```

**Evidencia 5 (medible):** entrega ambos planes y una tabla con estos campos:

| Momento | `access_type`/`access_type` JSON | `key` | filas estimadas |
|---|---|---|---|
| Antes del índice | valor observado | `NULL` o valor observado | valor observado |
| Después del índice | valor observado | `idx_pedidos_cliente_fecha` | valor observado |

Interpreta el resultado: `ALL` suele significar exploración completa; `ref` o
`range` con la clave creada indica que el optimizador puede restringir la
búsqueda. Con unas mil filas la diferencia de tiempo puede seguir siendo muy
pequeña: la medida válida aquí es el cambio de plan, clave elegida y estimación
de filas, no una afirmación de rendimiento en producción.

## Rúbrica de entrega (10 puntos)

| Criterio | Puntos | Evidencia mínima |
|---|---:|---|
| Aislamiento y datos sintéticos | 2 | Evidencias 1 y 2; sin sistemas reales |
| Modelo e integridad | 2 | Tablas, PK/FK y conteos 4/6 explicados |
| Mínimo privilegio | 2 | `SHOW GRANTS`, `SELECT` y rechazo del `INSERT` |
| Copia y recuperación | 2 | Volcado y conteos iguales en esquema restaurado |
| Diagnóstico de rendimiento | 2 | Dos planes y comparación razonada de métricas |

## Limpieza obligatoria

Al terminar y tras guardar sólo la evidencia necesaria, elimina el entorno
desechable. Verifica el identificador del contenedor antes de ejecutar estas órdenes.

```bash
docker rm -fv "$MARIADB_CONTAINER"
unset MARIADB_ROOT_PASSWORD MARIADB_CONTAINER
```

El directorio `$HOME/mariadb-xi-lab` y `ventas_xi.sql` siguen siendo locales:
revísalos y bórralos manualmente sólo si ya no necesitas la evidencia.
