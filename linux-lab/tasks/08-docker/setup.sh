#!/usr/bin/env bash
set -euo pipefail
LAB="$HOME/linux-lab/broken/docker-lab"
mkdir -p "$LAB"
cat > "$LAB/docker-scenarios.md" <<'EOF'
# Docker-сценарии

1. Контейнер завершился сразу после старта. С чего начать проверку?
2. Контейнер работает, но приложение не открывается снаружи. Что проверять?
3. После перезапуска контейнера данные исчезли. Почему?
4. В каком случае поможет `docker exec -it`?
EOF
echo 'Среда для урока 08 подготовлена: ~/linux-lab/broken/docker-lab'
