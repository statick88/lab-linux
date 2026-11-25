# Práctica VI — Diagnóstico de redes: rutas, DNS, interfaces y firewall

**Modalidad:** análisis local sin privilegios · **Duración:** 75 minutos

## Propósito y límites

Esta práctica cubre redes de la unidad oficial VI mediante salidas **sintéticas**. No modifiques interfaz, rutas, DNS ni firewall: no ejecutes `ip link set`, `ip addr add`, `ip route add`, `nmcli con modify`, `resolvectl`, `ufw`, `nft` o `iptables`. Usa un directorio local como `~/evidencia-redes`.

Las direcciones son rangos RFC 5737 de documentación (`192.0.2.0/24`, `198.51.100.0/24` y `203.0.113.0/24`), nunca una LAN real. El resultado es un diagnóstico reproducible, no una autorización de cambio.

## Escenario y material sintético

Una estación debe resolver `repo.lab.example` y alcanzar su HTTPS. Copia estos bloques en archivos locales con los nombres indicados:

```text
# interfaces.txt
2: ens18: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 state UP
    inet 192.0.2.50/24 brd 192.0.2.255 scope global ens18

# rutas.txt
192.0.2.0/24 dev ens18 proto kernel scope link src 192.0.2.50
203.0.113.0/24 via 192.0.2.1 dev ens18

# resolv.conf.txt
search lab.example
nameserver 192.0.2.53

# consulta-dns.txt
$ dig +short repo.lab.example @192.0.2.53
198.51.100.20

# firewall.txt
chain input {
  type filter hook input priority filter; policy drop;
  ct state established,related accept
  iifname "lo" accept
  tcp dport 22 accept
}
chain output { type filter hook output priority filter; policy accept; }
```

Supón que `192.0.2.1` es el único gateway y `192.0.2.53` el DNS autorizado. No hay ruta por defecto en `rutas.txt`.

## Actividad guiada

1. En `analisis-red.md`, identifica interfaz, estado, IPv4/prefijo y red directamente conectada; explica por qué el gateway es alcanzable en capa 2.
2. Explica el destino de la ruta a `203.0.113.0/24`, qué falta para `198.51.100.20` y la ruta por defecto propuesta (solo texto: prefijo, salto e interfaz).
3. Describe resolver, nombre, respuesta A y relación con HTTPS. Nombra una consulta diagnóstica posible (`dig`, `resolvectl query` o `getent hosts`) sin usar infraestructura ajena.
4. Decide si la política permite HTTPS saliente, retorno asociado y SSH nuevo entrante. Explica que SSH no limita origen y propón conceptualmente limitarlo a `192.0.2.0/24`.
5. Conserva entradas y análisis; completa la evidencia exacta.

## Evidencia mínima entregable

`evidencia-redes.txt` debe contener estas líneas, más una justificación breve de cada una en `analisis-red.md`:

```text
interfaz=ens18 estado=UP ipv4=192.0.2.50/24 red=192.0.2.0/24
ruta_estatica=203.0.113.0/24 via 192.0.2.1 dev ens18
ruta_propuesta=default via 192.0.2.1 dev ens18
resolver=192.0.2.53 nombre=repo.lab.example respuesta=198.51.100.20
https_salida=permitido retorno=permitido ssh_entrante=permitido
limitacion_ssh=sin_restriccion_de_origen propuesta_origen=192.0.2.0/24
```

## Comprobación esperada

```bash
grep -Fx 'ruta_propuesta=default via 192.0.2.1 dev ens18' evidencia-redes.txt
grep -Fx 'resolver=192.0.2.53 nombre=repo.lab.example respuesta=198.51.100.20' evidencia-redes.txt
grep -Fx 'https_salida=permitido retorno=permitido ssh_entrante=permitido' evidencia-redes.txt
```

Las tres órdenes deben imprimir una línea y salir 0. Revisa además que no afirmes una ruta por defecto existente y distingas salida, retorno establecido y conexión entrante.

## Rúbrica (10 puntos)

| Criterio | Puntos | Evidencia observable |
|---|---:|---|
| Interfaz, dirección, prefijo y red derivados | 2 | Primera línea y análisis |
| Ruta específica y ausencia de ruta por defecto | 2 | Rutas estática y propuesta |
| DNS: nombre, resolver y respuesta A | 2 | Línea de resolver y análisis |
| Firewall por dirección y estado; limitación SSH | 3 | Dos últimas líneas |
| Límites offline y entradas sintéticas preservados | 1 | Sin cambios de red ni LAN real |

**Resultado esperado:** 7/10 o más y las tres comprobaciones correctas.
