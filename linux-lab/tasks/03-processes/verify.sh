#!/usr/bin/env bash
set -euo pipefail
LAB="$HOME/linux-lab/services/process-lab"
fail(){ echo "Не пройдено: $1"; exit 1; }
[ -f "$LAB/worker.pid" ] || fail "нет файла worker.pid"
PID=$(cat "$LAB/worker.pid")
if ps -p "$PID" >/dev/null 2>&1; then
  :
else
  fail "лабораторный процесс не запущен"
fi
bash "$LAB/broken-service.sh" >/dev/null 2>&1 || fail "broken-service.sh все еще завершается с ошибкой"
echo 'Урок 03 пройден: процесс найден, а сервисный сценарий исправлен.'
