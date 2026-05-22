#!/usr/bin/env bash
set -euo pipefail
LAB="$HOME/linux-lab/services/log-lab"
mkdir -p "$LAB"
cat > "$LAB/app.log" <<'EOF'
2026-05-21T18:00:01 INFO GET /health 200
2026-05-21T18:00:04 WARN GET /login 401
2026-05-21T18:00:09 ERROR POST /api/report 500 database timeout
2026-05-21T18:00:12 INFO GET /assets/logo.png 200
2026-05-21T18:00:14 ERROR POST /api/report 500 database timeout
2026-05-21T18:00:17 WARN GET /admin 403
2026-05-21T18:00:22 ERROR GET /api/export 500 permission denied
EOF
rm -f "$LAB/errors-only.log" "$LAB/failed-requests.log"
echo 'Среда для урока 05 подготовлена: ~/linux-lab/services/log-lab/app.log'
