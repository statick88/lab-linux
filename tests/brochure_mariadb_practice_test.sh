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
require 'export MARIADB_CONTAINER="$(docker run -d \'
require '  -v /var/lib/mysql '
require 'CREATE USER IF NOT EXISTS '\''consulta_xi'\''@'\''localhost'\'''
require 'GRANT SELECT ON ventas_xi.* TO '\''consulta_xi'\''@'\''localhost'\'''
require 'SHOW GRANTS FOR '\''consulta_xi'\''@'\''localhost'\'''
require 'ventas_xi_restaurada'
require 'mariadb-dump'
require '--databases --single-transaction'
require 'EXPLAIN FORMAT=JSON'
require 'idx_pedidos_cliente_fecha'
require 'Rúbrica de entrega (10 puntos)'
require 'docker rm -fv "$MARIADB_CONTAINER"'

if grep -Eq '^[[:space:]]*GRANT[[:space:]]+ALL|@'\''%'\''' "$practice"; then
  echo 'unsafe broad database privilege found' >&2
  exit 1
fi

if grep -Eq 'docker[[:space:]]+volume[[:space:]]+(create|rm)|DROP[[:space:]]+DATABASE' "$practice"; then
  echo 'practice reuses or deletes MariaDB data' >&2
  exit 1
fi

if grep -Fq -- 'docker rm -f xi-mariadb' "$practice"; then
  echo 'cleanup does not remove the run-owned anonymous volume' >&2
  exit 1
fi

printf 'MariaDB XI practice static checks passed.\n'
