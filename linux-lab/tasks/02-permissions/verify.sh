#!/usr/bin/env bash
set -euo pipefail
LAB="$HOME/linux-lab/sandbox/permissions-lab"
fail(){ echo "Не пройдено: $1"; exit 1; }
[ "$(stat -c '%a' "$LAB/run-report.sh")" = "744" ] || fail "run-report.sh должен иметь права 744"
[ "$(stat -c '%a' "$LAB/team.txt")" = "644" ] || fail "team.txt должен иметь права 644"
[ "$(stat -c '%a' "$LAB/restricted-dir")" = "755" ] || fail "restricted-dir должен иметь права 755"
[ -r "$LAB/restricted-dir/inside.txt" ] || fail "inside.txt не читается"
[ -x "$LAB/run-report.sh" ] || fail "run-report.sh не исполняется"
echo 'Урок 02 пройден: права настроены корректно.'
