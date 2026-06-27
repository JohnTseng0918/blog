#!/usr/bin/env bash
# Local dev server for WSL2 — binds to all interfaces so a Windows browser
# can reach it, and overrides baseURL to localhost (the production baseURL
# carries a /blog/ path that breaks local serving at the root).
#
# Port 8080 is used on purpose: Hugo's default 1313 falls inside a Windows
# winnat reserved range (1214-1313), which breaks WSL2 localhost forwarding,
# so http://localhost:1313 is unreachable from Windows. 8080 is outside it.
# Check current reserved ranges from Windows with:
#   netsh interface ipv4 show excludedportrange protocol=tcp
#
# Usage: ./dev.sh        then open http://localhost:8080 in Windows
set -euo pipefail

PORT="${PORT:-8080}"
exec hugo server -D --bind 0.0.0.0 --baseURL "http://localhost:${PORT}/" --port "$PORT" "$@"
