# Mapa curricular: brochure y laboratorio

Este mapa separa las doce unidades oficiales de los once IDs internos actuales.
Describe evidencia en el código público, no certifica dominio del estudiante: varios
validadores comprueban el entorno o realizan por sí mismos la acción. Las rutas enlazadas
son materiales públicos de este repositorio.

| Brochure | Cobertura verificable actual | Brecha y entorno/evidencia defendible |
|---|---|---|
| I — Arquitectura, instalación y arranque | **Parcial:** [I](../units/i/) trata FHS, `mount`, UID, disco y una pregunta de WSL2. | Faltan instalación y secuencia de arranque. Evidencia: `units/i/setup.sh` y `test.sh`; usar VM/WSL2 desechable para instalación/arranque. |
| II — Paquetes | **Parcial:** [II](../units/ii/) usa APT, `apt-cache` y `dpkg` para instalar, consultar y retirar paquetes. | No acredita repositorios, firmas ni resolución de incidencias. Evidencia: `units/ii/test.sh`; contenedor Ubuntu o VM Debian/Ubuntu. |
| III — Shell, FHS y permisos | **Implementado en parte:** [III](../units/iii/) valida scripts, `read`, condicionales, bucles, funciones, arrays, argumentos, redirección y errores; [I](../units/i/) aporta FHS y `chmod 755`. | Faltan una práctica integrada de FHS/permisos y alcance de administración. Evidencia: `units/iii/test.sh` verifica artefactos del estudiante; contenedor del lab. |
| IV — Usuarios | **Implementado en parte:** [IV](../units/iv/) valida alta/baja, grupos, contraseña, shell, home, propiedad y permisos. | No cubre políticas de cuentas, PAM ni SSH como administración de acceso. Evidencia: `units/iv/test.sh`; contenedor con privilegios del lab. |
| V — Procesos | **Parcial:** [V](../units/v/) incluye `ps`, búsqueda, segundo plano, `kill`, CPU/memoria, cron y consulta de servicios. | Las comprobaciones de proceso/cron se generan durante la validación; no prueban siempre una acción previa del estudiante. Evidencia: `units/v/test.sh`; contenedor. |
| VI — Redes y almacenamiento | **Parcial:** [VI](../units/vi/) cubre bloques, particiones, imagen ext4, montaje, `df` y `du`. | Falta red; también LVM y administración de discos reales. Evidencia: `units/vi/test.sh`; VM desechable con dispositivos de prueba (no host productivo). |
| VII — Hardening | **Parcial:** [VII](../units/vii/) revisa UID 0, permisos críticos, sudoers, puertos, firewall, SSH, accesos y SUID. | Predomina la inspección; faltan configuración endurecida, auditoría y remediación verificable. Evidencia: `units/vii/test.sh`; VM aislada. |
| VIII — DHCP | **Sin equivalente.** | No hay reto DHCP ni topología servidor/cliente. Próximo bloque: dos VMs o red aislada, servicio DHCP y pruebas de concesión. |
| IX — Apache | **Sin equivalente.** | [IX](../units/ix/) es Nginx, no Apache. Próximo bloque: VM/contenedor con Apache, virtual host, logs y prueba HTTP. |
| X — Nginx y Apache | **Parcial:** [IX](../units/ix/) implementa Nginx (sitio, host virtual, logs, prueba/recarga/parada); Apache falta. | Evidencia: `units/ix/setup.sh` y `test.sh`; contenedor para Nginx y VM/puertos aislados para comparación con Apache. |
| XI — MariaDB | **Sin equivalente.** | [XI](../units/xi/) es respaldo de archivos con `tar`, `rsync` y checksums; no instala, consulta ni respalda MariaDB. Evidencia: `units/xi/setup.sh` y `test.sh`; futuro entorno MariaDB aislado. |
| XII — Rescate/proyecto | **Sin equivalente.** | No hay unidad XII ni escenario integrador de rescate. Próximo bloque: VM recuperable con fallo inyectado y rúbrica/proyecto. |

## Complementos internos, no numeración del brochure

- [VIII](../units/viii/) (Docker) y [X](../units/x/) (TLS/SSL) son complementarios: no
  sustituyen VIII DHCP ni X Nginx y Apache. El reto VIII.10 usa inventario y plan locales;
  no limpia el daemon Docker.
- [XI](../units/xi/) es un complemento independiente de respaldo de archivos, no XI
  MariaDB ni «Docker Compose y Bases de Datos».
- Los once IDs internos vigentes son I–XI; el número coincide solo parcialmente con el
  brochure. No debe usarse `11/11` como cobertura de las doce unidades oficiales.

## Entorno y trazabilidad

El [README](../README.md#advertencia-de-seguridad--usa-una-vm-dedicada-y-desechable)
explica que el Compose es privilegiado y expone el socket Docker: úsese solo una VM
específica y desechable. Los enlaces a `setup.sh` describen el entorno creado y los
`test.sh` la comprobación actual; no se ejecutaron servicios en vivo para este mapa.

**S1–S2 cubiertos:** inventario explícito de equivalencias, brechas, evidencia y entorno.
**Siguientes brechas por preparar:** VIII DHCP, IX Apache, Apache en X, XI MariaDB y XII
rescate/proyecto; después, profundizar I, III, IV, VI y VII sin renumerar complementos.
