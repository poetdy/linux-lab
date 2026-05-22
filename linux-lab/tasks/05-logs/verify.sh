#!/usr/bin/env bash
set -euo pipefail
LAB="$HOME/linux-lab/services/log-lab"
fail(){ echo "Не пройдено: $1"; exit 1; }
[ -f "$LAB/errors-only.log" ] || fail "нет файла errors-only.log"
[ -f "$LAB/failed-requests.log" ] || fail "нет файла failed-requests.log"
! grep -q ' INFO ' "$LAB/errors-only.log" || fail "в errors-only.log попали неошибочные строки"
! grep -q ' 200' "$LAB/failed-requests.log" || fail "в failed-requests.log попали успешные ответы"
grep -q 'database timeout' "$LAB/errors-only.log" || fail "в errors-only.log нет строк с database timeout"
echo 'Урок 05 пройден: логи отфильтрованы корректно.'
