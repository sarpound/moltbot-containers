#!/usr/bin/env bash
# =============================================================================
# Restore PostgreSQL from a gzipped SQL dump
# =============================================================================
# Assumes Docker Compose environment. Dump must have been created with
# backup_postgres.sh (or compatible pg_dump). Prompts for confirmation
# before overwriting.
# Usage: ./scripts/restore_postgres.sh <dump.sql.gz>
# =============================================================================

set -euo pipefail

if [[ ${1:-} == "" ]]; then
    echo "Usage: $0 <dump.sql.gz>" >&2
    echo "Example: $0 backup/postgres-moltbot-20250102-120000.sql.gz" >&2
    exit 1
fi

DUMP_PATH="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_DIR"

if [[ ! -f compose.yml ]]; then
    echo "ERROR: compose.yml not found in $PROJECT_DIR" >&2
    exit 1
fi

if [[ ! -f "$DUMP_PATH" ]]; then
    echo "ERROR: dump file not found: $DUMP_PATH" >&2
    exit 1
fi

if [[ -f .env ]]; then
    set -a
    # shellcheck source=/dev/null
    source .env
    set +a
fi

POSTGRES_USER="${POSTGRES_USER:-moltbot}"
POSTGRES_DB="${POSTGRES_DB:-moltbot}"

echo "WARNING: This will replace the current database ($POSTGRES_DB) with the dump."
echo "Dump: $DUMP_PATH"
read -r -p "Continue? [y/N] " ans
if [[ "${ans,,}" != "y" ]]; then
    echo "Aborted."
    exit 0
fi

echo "Restoring from $DUMP_PATH ..."
gunzip -c "$DUMP_PATH" | docker compose exec -T postgres psql -U "$POSTGRES_USER" -d "$POSTGRES_DB"
echo "Done."
