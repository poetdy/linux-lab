#!/usr/bin/env bash
set -euo pipefail
LAB="$HOME/linux-lab/sandbox/bash-lab"
fail(){ echo "Не пройдено: $1"; exit 1; }
[ -f "$LAB/error-summary.txt" ] || fail "нет error-summary.txt"
[ -f "$LAB/paths.txt" ] || fail "нет paths.txt"
[ -f "$LAB/report-count.txt" ] || fail "нет report-count.txt"
! grep -v 'ERROR' "$LAB/error-summary.txt" | grep -q '.' || fail "в error-summary.txt есть строки без ERROR"
head -n 1 "$LAB/paths.txt" | grep -Eq '^/' || fail "paths.txt должен содержать пути, начинающиеся с /"
grep -Eq '^[0-9]+$' "$LAB/report-count.txt" || fail "report-count.txt должен содержать только число"
echo 'Урок 07 пройден: конвейеры и фильтрация отработаны.'
