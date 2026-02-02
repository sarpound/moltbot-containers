#!/usr/bin/env bash
# =============================================================================
# Backup PostgreSQL - daily SQL dump (gzip)
# =============================================================================
# Assumes Docker Compose environment: run from project root (directory
# containing compose.yml). Loads .env for POSTGRES_* and writes to backup/.
# Usage: ./scripts/backup_postgres.sh [output_dir]
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
OUTPUT_DIR="${1:-$PROJECT_DIR/backup}"

cd "$PROJECT_DIR"

if [[ ! -f compose.yml ]]; then
    echo "ERROR: compose.yml not found in $PROJECT_DIR" >&2
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
TIMESTAMP="$(date -u +%Y%m%d-%H%M%S)"
DUMP_FILE="$OUTPUT_DIR/postgres-${POSTGRES_DB}-${TIMESTAMP}.sql.gz"

mkdir -p "$OUTPUT_DIR"

echo "Backing up PostgreSQL ($POSTGRES_DB) to $DUMP_FILE ..."
docker compose exec -T postgres pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB" | gzip > "$DUMP_FILE"
echo "Done: $DUMP_FILE ($(du -h "$DUMP_FILE" | cut -f1))"
