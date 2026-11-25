# IX — Apache: sitio virtual local

**Objetivo:** publicar una página propia con Apache y demostrar el *virtual host*
con archivos y logs producidos por ti. Hazlo **solo** en una VM aislada,
desechable, sin adaptador puente ni puertos publicados; todas las escuchas y
peticiones son `127.0.0.1`. No ejecutes estos pasos en el host.

## Preparación

En la VM instala Apache si falta: `sudo apt-get install apache2`. No edites
`/etc/apache2`, no habilites un sitio global ni uses `systemctl`.

```bash
export LAB="$HOME/lab-web-ix"
mkdir -p "$LAB"/{publico,logs,run}
printf '<h1>Apache IX: evidencia de TU_NOMBRE</h1>\n' > "$LAB/publico/index.html"
apachectl -M | grep -E '(mpm|headers|log_config)'
sudo a2enmod headers # solo si el listado muestra que falta
```

## Configuración del estudiante

Guarda lo siguiente en `$LAB/apache.conf`, reemplazando `TU_USUARIO` y
`TU_NOMBRE`. Si el MPM no existe, usa el módulo MPM que indique `apachectl -M`
y deja constancia del cambio. `Directory` limita el contenido publicado y los
logs permanecen fuera de él.

```apache
ServerRoot "/etc/apache2"
PidFile "/home/TU_USUARIO/lab-web-ix/run/apache.pid"
Listen 127.0.0.1:8080
LoadModule mpm_event_module /usr/lib/apache2/modules/mod_mpm_event.so
LoadModule authz_core_module /usr/lib/apache2/modules/mod_authz_core.so
LoadModule headers_module /usr/lib/apache2/modules/mod_headers.so
LoadModule log_config_module /usr/lib/apache2/modules/mod_log_config.so
<VirtualHost 127.0.0.1:8080>
  ServerName apache-ix.local
  DocumentRoot "/home/TU_USUARIO/lab-web-ix/publico"
  <Directory "/home/TU_USUARIO/lab-web-ix/publico">
    Require all granted
    Options -Indexes
  </Directory>
  Header always set X-Lab-Estudiante "TU_NOMBRE"
  ErrorLog "/home/TU_USUARIO/lab-web-ix/logs/error.log"
  CustomLog "/home/TU_USUARIO/lab-web-ix/logs/access.log" combined
</VirtualHost>
```

## Verificación y evidencia

Primero valida sin abrir puertos: `apachectl -t -f "$LAB/apache.conf"` y
`apachectl -t -D DUMP_VHOSTS -f "$LAB/apache.conf" | tee "$LAB/vhosts.txt"`.
Solo en la VM, tras ambas salidas correctas, crea una única petición local y
apaga la instancia manual:

```bash
apache2 -f "$LAB/apache.conf" -DFOREGROUND & echo $! > "$LAB/run/pid"; sleep 1
curl --noproxy '*' -i http://127.0.0.1:8080/ | tee "$LAB/respuesta-http.txt"
tail -n 1 "$LAB/logs/access.log" | tee "$LAB/acceso-observado.txt"
kill "$(cat "$LAB/run/pid")"; wait "$(cat "$LAB/run/pid")" 2>/dev/null || true
```

Entrega `apache.conf`, `vhosts.txt`, `respuesta-http.txt` y
`acceso-observado.txt`; deben evidenciar tu nombre, `200`,
`X-Lab-Estudiante` y acceso a `/`. Conserva `error.log` si falla.

## Rúbrica (10 puntos)

| Evidencia observable | Puntos |
|---|---:|
| Vhost loopback, nombre y DocumentRoot propios | 2 |
| Módulos justificados y `Directory` restrictivo | 2 |
| Sintaxis y DUMP_VHOSTS correctos | 2 |
| Respuesta local con cabecera y contenido propio | 2 |
| Log y apagado manual documentados | 2 |

## Rollback

Confirma que el PID no existe con `kill -0 "$(cat "$LAB/run/pid")"`; tras
entregar, elimina **solo** `$LAB` y revierte el snapshot de la VM.
