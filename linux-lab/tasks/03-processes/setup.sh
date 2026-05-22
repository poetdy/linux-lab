#!/usr/bin/env bash
set -euo pipefail
LAB="$HOME/linux-lab/services/process-lab"
mkdir -p "$LAB"
pkill -f 'sleep 5000' >/dev/null 2>&1 || true
cat > "$LAB/start-worker.sh" <<'EOF'
#!/usr/bin/env bash
nohup sleep 5000 >/dev/null 2>&1 &
echo $! > "$HOME/linux-lab/services/process-lab/worker.pid"
echo "worker started"
EOF
cat > "$LAB/broken-service.sh" <<'EOF'
#!/usr/bin/env bash
set -e
cd /no/such/path
echo "service ok"
EOF
chmod +x "$LAB/start-worker.sh" "$LAB/broken-service.sh"
"$LAB/start-worker.sh" >/dev/null
mkdir -p "$HOME/linux-lab/broken"
ln -snf "$LAB" "$HOME/linux-lab/broken/process-lab"
echo 'Среда для урока 03 подготовлена: ~/linux-lab/services/process-lab'
