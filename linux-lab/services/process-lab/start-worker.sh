#!/usr/bin/env bash
nohup sleep 5000 >/dev/null 2>&1 &
echo $! > "$HOME/linux-lab/services/process-lab/worker.pid"
echo "worker started"
