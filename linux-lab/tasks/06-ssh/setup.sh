#!/usr/bin/env bash
set -euo pipefail
LAB="$HOME/linux-lab/broken/ssh-lab"
rm -rf "$LAB"
mkdir -p "$LAB/.ssh"
printf 'ssh-ed25519 AAAATEST lab@local\n' > "$LAB/.ssh/authorized_keys"
printf 'private-lab-key\n' > "$LAB/lab_id_ed25519"
cat > "$LAB/config.sample" <<'EOF'
Host labbox
    HostName 127.0.0.1
    User trainee
    IdentityFile /no/such/key
    IdentitiesOnly yes
EOF
chmod 755 "$LAB/.ssh"
chmod 644 "$LAB/.ssh/authorized_keys"
chmod 600 "$LAB/lab_id_ed25519"
echo 'Среда для урока 06 подготовлена: ~/linux-lab/broken/ssh-lab'
