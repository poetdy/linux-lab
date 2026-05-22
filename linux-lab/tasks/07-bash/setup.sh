#!/usr/bin/env bash
set -euo pipefail
LAB="$HOME/linux-lab/sandbox/bash-lab"
rm -rf "$LAB"
mkdir -p "$LAB"
cat > "$LAB/access.log" <<'EOF'
2026-05-21T18:00:01 INFO GET /health 200
2026-05-21T18:00:04 WARN GET /login 401
2026-05-21T18:00:09 ERROR POST /api/report 500
2026-05-21T18:00:10 INFO GET /docs 200
2026-05-21T18:00:11 ERROR POST /api/report 500
2026-05-21T18:00:12 INFO GET /assets/logo.png 200
2026-05-21T18:00:13 ERROR GET /api/export 500
EOF
rm -f "$LAB/error-summary.txt" "$LAB/paths.txt" "$LAB/report-count.txt"
echo 'Среда для урока 07 подготовлена: ~/linux-lab/sandbox/bash-lab'
