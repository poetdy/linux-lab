#!/usr/bin/env bash
set -euo pipefail
LAB="$HOME/linux-lab/broken/ssh-lab"
fail(){ echo "Не пройдено: $1"; exit 1; }
grep -q 'IdentityFile .*/lab_id_ed25519' "$LAB/config.sample" || fail "config.sample не указывает на lab_id_ed25519"
[ "$(stat -c '%a' "$LAB/.ssh")" = "700" ] || fail "каталог .ssh должен иметь права 700"
[ "$(stat -c '%a' "$LAB/.ssh/authorized_keys")" = "600" ] || fail "authorized_keys должен иметь права 600"
echo 'Урок 06 пройден: SSH-набор приведен в безопасный вид.'
