#!/usr/bin/env bash
set -euo pipefail
LAB="$HOME/linux-lab/sandbox/permissions-lab"
if [ -d "$LAB/restricted-dir" ]; then
  chmod 700 "$LAB/restricted-dir" >/dev/null 2>&1 || true
fi
rm -rf "$LAB"
mkdir -p "$LAB/restricted-dir"
printf '#!/usr/bin/env bash\necho report\n' > "$LAB/run-report.sh"
printf 'shared data\n' > "$LAB/team.txt"
printf 'inside\n' > "$LAB/restricted-dir/inside.txt"
chmod 644 "$LAB/run-report.sh"
chmod 600 "$LAB/team.txt"
chmod 644 "$LAB/restricted-dir/inside.txt"
chmod 600 "$LAB/restricted-dir"
echo 'Среда для урока 02 подготовлена: ~/linux-lab/sandbox/permissions-lab'
