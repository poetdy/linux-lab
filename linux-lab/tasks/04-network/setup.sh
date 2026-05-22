#!/usr/bin/env bash
set -euo pipefail
LAB="$HOME/linux-lab/broken/network-lab"
mkdir -p "$LAB"
pkill -f 'http.server 18080' >/dev/null 2>&1 || true
cat > "$LAB/index.html" <<'EOF'
network lab ok
EOF
nohup python3 -m http.server 18080 --directory "$LAB" >/dev/null 2>&1 &
echo $! > "$LAB/http.pid"
echo 'Среда для урока 04 подготовлена: http://127.0.0.1:18080'
