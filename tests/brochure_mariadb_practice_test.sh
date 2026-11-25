#!/usr/bin/env bash
# Static contract checks: this script never starts Docker or MariaDB.
set -euo pipefail

practice="docs/practicas/11-mariadb.md"
[ -f "$practice" ] || { echo "missing $practice" >&2; exit 1; }

require() {
  grep -Fq -- "$1" "$practice" || {
    echo "missing required text: $1" >&2
    exit 1
  }
}

require 'Práctica XI — MariaDB'
require 'Entorno aislado obligatorio'
require 'datos **sintética**'
require 'docker run -d --name xi-mariadb'
require 'CREATE USER IF NOT EXISTS '\''consulta_xi'\''@'\''localhost'\'''
require 'GRANT SELECT ON ventas_xi.* TO '\''consulta_xi'\''@'\''localhost'\'''
require 'SHOW GRANTS FOR '\''consulta_xi'\''@'\''localhost'\'''
require 'ventas_xi_restaurada'
require 'mariadb-dump'
require '--databases --single-transaction'
require 'EXPLAIN FORMAT=JSON'
require 'idx_pedidos_cliente_fecha'
require 'Rúbrica de entrega (10 puntos)'
require 'docker rm -f xi-mariadb'

if grep -Eq '^[[:space:]]*GRANT[[:space:]]+ALL|@'\''%'\''' "$practice"; then
  echo 'unsafe broad database privilege found' >&2
  exit 1
fi

printf 'MariaDB XI practice static checks passed.\n'
