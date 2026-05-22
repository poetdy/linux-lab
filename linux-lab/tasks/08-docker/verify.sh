#!/usr/bin/env bash
set -euo pipefail
if command -v docker >/dev/null 2>&1; then
  docker --version >/dev/null 2>&1 || { echo 'Не пройдено: Docker установлен, но не отвечает корректно.'; exit 1; }
  echo 'Урок 08: Docker доступен, можно выполнять практику с контейнерами.'
else
  [ -f "$HOME/linux-lab/broken/docker-lab/docker-scenarios.md" ] || { echo 'Не пройдено: нет файла со сценариями Docker.'; exit 1; }
  echo 'Урок 08: Docker в системе отсутствует, используй сценарии из docker-scenarios.md.'
fi
