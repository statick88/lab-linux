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
| VI — Redes y almacenamiento | [Práctica de redes](practicas/06-redes.md) con datos sintéticos de interfaz, rutas, DNS y firewall; [VI interna](../units/vi/) cubre almacenamiento básico. | La guía evalúa un diagnóstico offline; todavía faltan operación real de redes y una práctica de LVM. |
| VII — Hardening | **Parcial:** [VII](../units/vii/) revisa UID 0, permisos críticos, sudoers, puertos, firewall, SSH, accesos y SUID. | Predomina la inspección; faltan configuración endurecida, auditoría y remediación verificable. Evidencia: `units/vii/test.sh`; VM aislada. |
| VIII — DHCP | [Práctica de ISC DHCP](practicas/08-dhcp.md): ámbito, opciones, reserva y concesión a partir de datos preparados. | Evidencia escrita offline; no acredita operación de un servidor ni emite tráfico DHCP. |
| IX — Apache | [Práctica de Apache](practicas/09-apache.md): virtual host, política de directorios, módulos y registros. | Validación y evidencia HTTP en loopback dentro de una VM desechable; fuera del evaluador interactivo. |
| X — Nginx y Apache | [Práctica del proxy inverso](practicas/10-nginx-apache.md) hacia Apache; [IX interna](../units/ix/) contiene retos de Nginx. | Evidencia: respuesta HTTP y registro de Nginx y Apache en la misma VM aislada; la integración no tiene evaluación automática. |
| XI — MariaDB | [Práctica de MariaDB](practicas/11-mariadb.md): mínimo privilegio, datos sintéticos, copia, restauración y análisis de consultas. | Evidencia: permisos, datos restaurados y salida de `EXPLAIN` en entorno aislado. [XI interna](../units/xi/) es respaldo de archivos, no una práctica de MariaDB. |
| XII — Rescate/proyecto | [Práctica de rescate y proyecto](practicas/12-rescate-proyecto.md): diagnóstico offline, informe de evidencias y rúbrica de 100 puntos. | VM desechable, instantánea e imagen de prueba sin montar; evidencia de `fsck` en solo lectura, registros y observabilidad de un proceso propio. No forma parte del evaluador interactivo. |

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

Las guías del brochure complementan los retos interactivos y tienen entregables y rúbricas propios. No cuentan para el progreso automático de los once IDs internos.
