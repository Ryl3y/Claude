#!/bin/bash
# Applique la migration Kassa sur un PostgreSQL local jetable et lance les tests RLS.
# Usage : tool/tester_rls_local.sh   (nécessite les binaires PostgreSQL : initdb, pg_ctl, psql)
set -euo pipefail

RACINE="$(cd "$(dirname "$0")/.." && pwd)"
PGBIN="$(ls -d /usr/lib/postgresql/*/bin | sort -V | tail -1)"
TMP="$(mktemp -d)"
PORT=54329
chmod 777 "$TMP"

trap 'su postgres -c "$PGBIN/pg_ctl -D $TMP/data stop -m fast" >/dev/null 2>&1 || true; rm -rf "$TMP"' EXIT

su postgres -c "$PGBIN/initdb -D $TMP/data -U postgres --auth=trust >/dev/null"
su postgres -c "$PGBIN/pg_ctl -D $TMP/data -o '-p $PORT -k $TMP' -l $TMP/log start -w >/dev/null"

PSQL=(psql -h "$TMP" -p "$PORT" -U postgres -d postgres -v ON_ERROR_STOP=1 -q)
"${PSQL[@]}" -f "$RACINE/supabase/tests/socle_supabase_local.sql"
for m in "$RACINE"/supabase/migrations/*.sql; do
  "${PSQL[@]}" -f "$m"
done
for t in "$RACINE"/supabase/tests/*_test.sql; do
  "${PSQL[@]}" -f "$t" 2>&1 | sed 's/^psql:[^ ]* NOTICE:  //'
done
