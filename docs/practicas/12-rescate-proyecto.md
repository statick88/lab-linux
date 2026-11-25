# XII — Rescate y proyecto integrador

**Objetivo:** demostrar diagnóstico, preservación de evidencia y recuperación
planificada en una VM **sin red**, desechable y con snapshot. Esta práctica
cierra las unidades anteriores: documenta el entorno como en redes/DHCP,
interpreta servicios web locales como en Apache/Nginx y entrega evidencias
reproducibles. No modifica discos, particiones, credenciales ni servicios.

## Límites de seguridad

Antes de comenzar, el docente debe proporcionar una VM aislada, con adaptador
de red desconectado, y un snapshot llamado `XII-inicial`. También debe dejar
una imagen de sistema de archivos desechable en la VM, por ejemplo
`$HOME/xii-material/rescate.img`. La imagen es material de lectura: **no se
monta, no se repara y no se escribe**. Si no existe el snapshot o la imagen,
detente y solicita la preparación; no la crees con `dd`, `mkfs` ni descargas.

Trabaja solo en tu directorio y no ejecutes `sudo`, `mount`, `fsck` reparador,
`systemctl`, `service`, `passwd`, herramientas de fuerza bruta ni comandos
contra una IP, dominio o interfaz. No existe una cuenta que desbloquear: el
rescate consiste en observar y proponer una recuperación autorizada.

## Preparación y contrato de evidencia

Inicia una sesión local y crea una carpeta de entrega. Estos archivos son la
única escritura de la práctica; el snapshot será el rollback definitivo.

```bash
export LAB_XII="$HOME/lab-xii"
mkdir -p "$LAB_XII"/{evidencia,proyecto}
printf 'XII rescate — NOMBRE — FECHA\n' > "$LAB_XII/README-entrega.txt"
printf 'Snapshot de partida: XII-inicial\nRed: desconectada\n' > "$LAB_XII/alcance.txt"
test -f "$HOME/xii-material/rescate.img" && echo 'imagen presente' | tee "$LAB_XII/evidencia/imagen.txt"
```

Sustituye `NOMBRE` y `FECHA`. Guarda también en `alcance.txt` que no montaste
la imagen y que cualquier reparación requeriría autorización y una copia.

## Estación 1 — inventario local y lectura segura (30 puntos)

Registra el contexto sin contactar la red. El PID que se usará después es un
proceso local e inocuo, no un servicio.

```bash
uname -a | tee "$LAB_XII/evidencia/uname.txt"
id | tee "$LAB_XII/evidencia/id.txt"
printf 'proyecto XII\n' > "$LAB_XII/proyecto/estado.txt"
sleep 180 & PID=$!
printf '%s\n' "$PID" | tee "$LAB_XII/evidencia/pid.txt"
case "$PID" in (*[!0-9]*|'') echo 'PID inválido'; exit 1;; esac
kill -0 "$PID" && echo "PID local activo: $PID" | tee "$LAB_XII/evidencia/pid-verificado.txt"
```

Ejecuta una comprobación no destructiva de la imagen. `-n` prohíbe escribir;
una salida que informe inconsistencias es un hallazgo, no una orden de reparar.

```bash
fsck -n "$HOME/xii-material/rescate.img" 2>&1 | tee "$LAB_XII/evidencia/fsck-solo-lectura.txt"
printf 'Imagen sin montar; fsck -n ejecutado solo para observar.\n' >> "$LAB_XII/alcance.txt"
```

En `hallazgos.md`, anota: el nombre de la imagen, si `fsck -n` terminó limpio
o informó problemas, y la siguiente acción segura: conservar el snapshot y
escalar al responsable. No propongas ni ejecutes reparación, montaje o cambio
de contraseña.

## Estación 2 — proceso, archivos abiertos y traza local (30 puntos)

Usa el PID numérico guardado arriba. `lsof` y `strace` solo observan al
`sleep` creado por ti; la traza se limita a lecturas/aperturas/cierres y dura
como máximo tres segundos.

```bash
lsof -p "$PID" | tee "$LAB_XII/evidencia/lsof-$PID.txt"
timeout 3 strace -f -tt -e trace=openat,read,close -p "$PID" \
  2> "$LAB_XII/evidencia/strace-$PID.txt" || test $? -eq 124
printf 'PID observado: %s\n' "$PID" | tee "$LAB_XII/evidencia/correlacion.txt"
```

Si `strace`, `lsof` o `timeout` no están disponibles, registra literalmente
`herramienta no disponible` y no instales paquetes. Explica en `hallazgos.md`
qué relaciona el mismo PID entre `pid.txt`, `lsof-PID.txt` y `strace-PID.txt`.
No traces procesos ajenos ni procesos privilegiados.

## Proyecto integrador — informe de rescate autorizado (40 puntos)

Crea `$LAB_XII/proyecto/informe-rescate.md` con estas secciones y referencias
a nombres de archivos de evidencia, no a capturas:

1. **Alcance y aislamiento:** snapshot `XII-inicial`, red desconectada, imagen
   sin montar y límite de solo lectura.
2. **Inventario:** identidad, kernel y PID real (`pid.txt` y
   `pid-verificado.txt`).
3. **Diagnóstico:** resultado literal de `fsck-solo-lectura.txt`, la
   correlación `lsof-PID.txt`/`strace-PID.txt` y qué dato falta para decidir.
4. **Integración previa:** explica cómo el principio de mínima exposición de
   DHCP/redes y los logs correlacionables de Apache/Nginx impiden atribuir una
   incidencia a la red o a un proxy sin evidencia local.
5. **Plan autorizado:** preservar snapshot e imagen, comunicar hallazgos al
   responsable, obtener aprobación escrita y trabajar únicamente sobre una
   copia en otra sesión. No incluyas comandos de reparación ni evasión de
   autenticación.
6. **Resultado y rollback:** indica si el diagnóstico fue concluyente y que se
   revierte al snapshot en lugar de alterar la imagen.

## Resultados esperados y rúbrica trazable (100 puntos)

| Resultado verificable | Evidencia | Puntos |
|---|---|---:|
| VM/snapshot/red aislada declarados y límites respetados | `alcance.txt`, `README-entrega.txt` | 15 |
| Imagen preexistente permanece sin montar; diagnóstico solo lectura | `imagen.txt`, `fsck-solo-lectura.txt`, `hallazgos.md` | 20 |
| Inventario e identidad locales reproducibles | `uname.txt`, `id.txt` | 10 |
| PID real, numérico y activo correlacionado | `pid.txt`, `pid-verificado.txt`, `correlacion.txt` | 15 |
| Observación inocua de archivos abiertos y traza acotada | `lsof-PID.txt`, `strace-PID.txt` o indisponibilidad documentada | 15 |
| Informe integra redes/DHCP y Apache/Nginx con conclusión basada en evidencia | `proyecto/informe-rescate.md` | 15 |
| Plan de autorización, preservación y rollback es claro | informe, `alcance.txt` | 10 |

Para aprobar, entrega todos los archivos y obtiene al menos 70/100. Una
herramienta ausente no resta si su ausencia y la limitación se documentan; no
se sustituye por instalación, acceso a red ni observación de otro proceso.

## Cierre y rollback

Detén solo el `sleep` que iniciaste y confirma que ya no existe. No borres,
formatees ni modifiques la imagen. Tras guardar la entrega fuera de la VM si
el docente lo autoriza, revierte la VM al snapshot `XII-inicial` desde el
hipervisor. Esa reversión elimina los artefactos de esta sesión y restaura el
estado conocido sin reparar el sistema de archivos.

```bash
kill "$PID"; wait "$PID" 2>/dev/null || true
kill -0 "$PID" 2>/dev/null && echo 'PID aún activo' || echo 'PID detenido'
```
