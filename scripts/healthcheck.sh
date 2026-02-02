#!/usr/bin/env bash
# =============================================================================
# Healthcheck - verify all services in the Compose stack
# =============================================================================
# Assumes Docker Compose environment. Exits 0 if all services healthy, 1 otherwise.
# Usage: ./scripts/healthcheck.sh
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_DIR"

if [[ ! -f compose.yml ]]; then
    echo "ERROR: compose.yml not found in $PROJECT_DIR" >&2
    exit 1
fi

FAIL=0

check() {
    local name="$1"
    if docker compose ps -a --format "{{.Name}} {{.State}}" 2>/dev/null | grep -q "^${name} running"; then
        echo "OK: $name running"
    else
        echo "FAIL: $name not running"
        FAIL=1
    fi
}

echo "Checking services..."
# Use container names (from compose.yml container_name)
check moltbot-caddy
check moltbot-app
check moltbot-postgres
check moltbot-redis

if [[ $FAIL -eq 0 ]]; then
    echo "All checks passed."
    exit 0
else
    echo "One or more checks failed."
    exit 1
fi
