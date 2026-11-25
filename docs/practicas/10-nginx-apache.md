# X — Nginx como proxy inverso hacia Apache

**Objetivo:** encadenar Nginx con el Apache de IX sin salir de una VM aislada y
desechable. Nginx escucha solo `127.0.0.1:8081` y reenvía solo a
`127.0.0.1:8080`; no uses IP, dominios o HTTP externos, adaptador puente,
puertos publicados ni servicios del host.

## Preparación

Completa IX pero no dejes Apache activo. En la VM instala Nginx si falta:
`sudo apt-get install nginx`. No edites `/etc/nginx` ni uses `systemctl`.

```bash
export PROXY="$HOME/lab-web-x"
mkdir -p "$PROXY"/{logs,run}
printf 'práctica X: TU_NOMBRE\n' > "$PROXY/nota.txt"
```

## nginx.conf del estudiante

Guarda esto en `$PROXY/nginx.conf`, cambiando las rutas `TU_USUARIO` y tu
identidad. El bloque `http` declara formato/logs; el bloque `server` limita
escucha, proxy y cabeceras.

```nginx
worker_processes 1;
pid /home/TU_USUARIO/lab-web-x/run/nginx.pid;
events { worker_connections 64; }
http {
  log_format estudiante '$remote_addr $status "$request" upstream=$upstream_status';
  access_log /home/TU_USUARIO/lab-web-x/logs/access.log estudiante;
  error_log /home/TU_USUARIO/lab-web-x/logs/error.log info;
  server {
    listen 127.0.0.1:8081;
    server_name nginx-x.local;
    location / {
      proxy_pass http://127.0.0.1:8080;
      proxy_set_header Host $host;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Lab-Proxy "TU_NOMBRE";
    }
  }
}
```

Anota en `nota.txt` qué significa `upstream=200` y por qué el proxy no puede
usar un destino ajeno.

## Validación, evidencia y logs

Sin iniciar servicios, verifica ambos archivos:

```bash
nginx -t -c "$PROXY/nginx.conf"
apachectl -t -f "$HOME/lab-web-ix/apache.conf"
```

Solo dentro de la VM, inicia primero Apache y luego Nginx manualmente, solicita
loopback una vez y guarda los tres rastros observables:

```bash
apache2 -f "$HOME/lab-web-ix/apache.conf" -DFOREGROUND & echo $! > "$PROXY/run/apache.pid"
nginx -c "$PROXY/nginx.conf" -g 'daemon off;' & echo $! > "$PROXY/run/nginx.pid"; sleep 1
curl --noproxy '*' -i http://127.0.0.1:8081/ | tee "$PROXY/respuesta-proxy.txt"
tail -n 1 "$PROXY/logs/access.log" | tee "$PROXY/nginx-acceso.txt"
tail -n 1 "$HOME/lab-web-ix/logs/access.log" | tee "$PROXY/apache-acceso.txt"
```

Entrega `nginx.conf`, ambas salidas `-t`, `respuesta-proxy.txt`, los dos accesos
y `nota.txt`: deben mostrar `200`, el HTML de IX, `X-Lab-Proxy`,
`upstream=200` y la misma ruta en ambos logs. Conserva ambos `error.log` ante
fallo; no entregues capturas ni logs ajenos.

## Rúbrica (10 puntos)

| Evidencia observable | Puntos |
|---|---:|
| `server` y escucha solo loopback | 2 |
| Proxy local y cabeceras requeridas | 2 |
| Dos validaciones sintácticas correctas | 2 |
| Petición propia demuestra Nginx → Apache | 2 |
| Logs correlacionables y rollback | 2 |

## Rollback

Detén Nginx y luego Apache sin tocar servicios administrados:

```bash
kill "$(cat "$PROXY/run/nginx.pid")"; wait "$(cat "$PROXY/run/nginx.pid")" 2>/dev/null || true
kill "$(cat "$PROXY/run/apache.pid")"; wait "$(cat "$PROXY/run/apache.pid")" 2>/dev/null || true
```

Comprueba ambos PID con `kill -0`; tras entregar, elimina solo `$PROXY` y
`$HOME/lab-web-ix`, y revierte el snapshot de la VM.
