# Práctica VIII — ISC DHCP: ámbito, opciones, reserva y concesión

**Modalidad:** diseño y verificación offline · **Duración:** 75 minutos

## Propósito y límites

Esta práctica cubre la unidad oficial VIII: interpretar ISC DHCP y contrastarlo con una concesión **sintética**. Usa solo `198.51.100.0/24`, rango RFC 5737 de documentación, y un directorio local como `~/evidencia-dhcp`.

No instales, habilites, recargues ni inicies `isc-dhcp-server`; no edites DHCP, abras puertos, cambies interfaces ni toques la política de una LAN real. El producto es una propuesta revisable, no un servicio DHCP.

## Escenario y entradas sintéticas

Una sala usa `198.51.100.0/24`: necesita pool dinámico, DNS, gateway y reserva para impresora. Copia lo siguiente en `dhcpd.conf.sintetico`:

```conf
# Propuesta sin ejecutar: no es configuración de producción.
default-lease-time 600;
max-lease-time 7200;
option domain-name "lab.example";
option domain-name-servers 198.51.100.53;

subnet 198.51.100.0 netmask 255.255.255.0 {
  range 198.51.100.100 198.51.100.150;
  option routers 198.51.100.1;
  option subnet-mask 255.255.255.0;
  option broadcast-address 198.51.100.255;
}

host impresora-aula {
  hardware ethernet 02:00:5e:10:00:42;
  fixed-address 198.51.100.42;
}
```

Copia este resultado ficticio en `lease.sintetica`:

```text
lease 198.51.100.118 {
  starts 3 2025/02/12 09:00:00;
  ends 3 2025/02/12 09:10:00;
  binding state active;
  hardware ethernet 02:00:5e:10:00:99;
  client-hostname "puesto-07";
}
```

No existe una concesión presentada para `impresora-aula`: el archivo no prueba uso de la reserva ni arranque del servidor.

## Actividad guiada

1. En `analisis-dhcp.md`, delimita red, máscara, broadcast, rango inclusivo y reserva; separa `.42` del pool.
2. Distingue opciones globales y del bloque `subnet`; explica router, DNS, dominio y máscara que recibe un cliente dinámico.
3. Calcula duración de la lease, compárala con ambos límites e identifica la MAC y estado que realmente acredita `lease.sintetica`.
4. Relaciona la reserva con `02:00:5e:10:00:42` y señala la evidencia necesaria para afirmar que esa impresora recibió `.42`.
5. Indica dos controles antes de despliegue: evitar solape con estáticas y validar sintaxis en una copia aislada. No ejecutes el daemon.
6. Conserva las entradas y completa la evidencia exacta.

## Evidencia mínima entregable

`evidencia-dhcp.txt` debe contener estas líneas; añade en el análisis por qué `.118` no demuestra la reserva y por qué una reserva externa al pool exige evitar conflictos:

```text
red=198.51.100.0/24 mascara=255.255.255.0 broadcast=198.51.100.255
rango_dinamico=198.51.100.100-198.51.100.150 gateway=198.51.100.1
opciones_globales=domain-name,domain-name-servers opciones_subred=routers,subnet-mask,broadcast-address
dns=198.51.100.53 dominio=lab.example
reserva=impresora-aula mac=02:00:5e:10:00:42 ip=198.51.100.42 fuera_del_rango=si
lease_ip=198.51.100.118 mac=02:00:5e:10:00:99 estado=active duracion=600s
limites=default:600s,max:7200s evidencia_reserva=pendiente
controles=sin_solapamiento_con_estaticas,validacion_en_copia_aislada
```

## Comprobación esperada

```bash
grep -Fx 'rango_dinamico=198.51.100.100-198.51.100.150 gateway=198.51.100.1' evidencia-dhcp.txt
grep -Fx 'reserva=impresora-aula mac=02:00:5e:10:00:42 ip=198.51.100.42 fuera_del_rango=si' evidencia-dhcp.txt
grep -Fx 'lease_ip=198.51.100.118 mac=02:00:5e:10:00:99 estado=active duracion=600s' evidencia-dhcp.txt
```

Cada búsqueda debe mostrar una línea y salir 0. Confirma que `09:10:00 - 09:00:00 = 600` segundos, que `600` cumple los límites y que la reserva sigue sin evidencia de uso.

## Rúbrica (10 puntos)

| Criterio | Puntos | Evidencia observable |
|---|---:|---|
| Red, máscara, broadcast y rango correctos | 2 | Dos primeras líneas |
| Opciones y efecto para el cliente diferenciados | 2 | Opciones, DNS y dominio |
| Reserva vinculada a MAC e IP, no confundida con pool | 2 | Línea de reserva y análisis |
| Concesión, estado y duración interpretados | 2 | Línea de lease y límites |
| Controles previos y límites offline respetados | 2 | Controles; sin daemon ni cambios de red |

**Resultado esperado:** 7/10 o más y las tres comprobaciones correctas.
