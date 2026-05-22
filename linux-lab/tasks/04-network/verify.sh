#!/usr/bin/env bash
set -euo pipefail
fail(){ echo "Не пройдено: $1"; exit 1; }
BODY=$(curl -fsS http://127.0.0.1:18080 2>/dev/null || true)
[ "$BODY" = "network lab ok" ] || fail "лабораторный HTTP-сервис не отвечает ожидаемым телом"
ss -tulpn | grep -q ':18080' || fail "порт 18080 не слушается"
echo 'Урок 04 пройден: сервис доступен, порт найден.'
