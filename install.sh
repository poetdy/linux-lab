#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_SOURCE_DIR="$REPO_ROOT/linux-lab"
WELCOME_SOURCE="$REPO_ROOT/shell/lab-welcome"
HELPERS_SOURCE="$REPO_ROOT/shell/linux-lab.sh"
HELP_SOURCE_DIR="$REPO_ROOT/shell/help"
TLDR_WRAPPER_SOURCE="$REPO_ROOT/shell/tldr"

TARGET_HOME="${HOME}"
TARGET_LAB_DIR="$TARGET_HOME/linux-lab"
TARGET_BIN_DIR="$TARGET_HOME/.local/bin"
TARGET_SHARE_DIR="$TARGET_HOME/.local/share/linux-lab"
TARGET_HELP_DIR="$TARGET_SHARE_DIR/help"
TARGET_WELCOME="$TARGET_BIN_DIR/lab-welcome"
TARGET_HELPERS="$TARGET_SHARE_DIR/linux-lab.sh"
TARGET_TLDR="$TARGET_BIN_DIR/tldr"
TARGET_BASHRC="$TARGET_HOME/.bashrc"

BASHRC_BEGIN="# >>> Linux Lab >>>"
BASHRC_END="# <<< Linux Lab <<<"

log() {
  printf '[linux-lab] %s\n' "$1"
}

fail() {
  printf '[linux-lab] Ошибка: %s\n' "$1" >&2
  exit 1
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "не найдена команда '$1'"
}

run_root() {
  if [ "${EUID}" -eq 0 ]; then
    "$@"
    return
  fi

  if command -v sudo >/dev/null 2>&1; then
    sudo "$@"
    return
  fi

  return 1
}

append_bashrc_block() {
  local block

  block=$(cat <<EOF
$BASHRC_BEGIN
if [ -f "\$HOME/.local/share/linux-lab/linux-lab.sh" ]; then
  . "\$HOME/.local/share/linux-lab/linux-lab.sh"
fi
$BASHRC_END
EOF
)

  if [ -f "$TARGET_BASHRC" ] && grep -Fq "$BASHRC_BEGIN" "$TARGET_BASHRC"; then
    log "Блок Linux Lab уже есть в ~/.bashrc, повторно не добавляю"
    return
  fi

  log "Добавляю блок подключения Linux Lab в ~/.bashrc"
  printf '\n%s\n' "$block" >> "$TARGET_BASHRC"
}

install_packages() {
  local packages optional_packages package
  packages=(bash coreutils findutils grep sed gawk tar less man-db manpages manpages-ru locales iproute2 iputils-ping curl openssh-client tree)
  optional_packages=(tldr tealdeer)

  if ! command -v apt-get >/dev/null 2>&1; then
    log "apt-get не найден, пакетную установку пропускаю"
    return
  fi

  if ! run_root true; then
    log "Нет root/sudo для установки пакетов. Продолжаю копирование файлов без пакетного шага"
    return
  fi

  log "Обновляю индекс пакетов"
  run_root apt-get update

  log "Устанавливаю базовые пакеты Linux Lab"
  run_root env DEBIAN_FRONTEND=noninteractive apt-get install -y "${packages[@]}"

  for package in "${optional_packages[@]}"; do
    if apt-cache show "$package" >/dev/null 2>&1; then
      log "Устанавливаю дополнительный пакет справки: $package"
      run_root env DEBIAN_FRONTEND=noninteractive apt-get install -y "$package"
      return
    fi
  done

  log "Системный пакет tldr не найден. Будет использоваться локальный wrapper Linux Lab"
}

ensure_russian_locale() {
  if locale -a 2>/dev/null | grep -qi '^ru_RU\.utf8$'; then
    log "Локаль ru_RU.UTF-8 уже доступна"
    return
  fi

  if ! run_root true; then
    log "Нет root/sudo для генерации ru_RU.UTF-8. Продолжаю без системной локали"
    return
  fi

  log "Готовлю локаль ru_RU.UTF-8"
  if [ -f /etc/locale.gen ]; then
    run_root sed -i 's/^# *ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen
    if ! grep -q '^ru_RU.UTF-8 UTF-8' /etc/locale.gen; then
      printf 'ru_RU.UTF-8 UTF-8\n' | run_root tee -a /etc/locale.gen >/dev/null
    fi
  fi

  if command -v locale-gen >/dev/null 2>&1; then
    run_root locale-gen ru_RU.UTF-8
  fi

  if command -v update-locale >/dev/null 2>&1; then
    run_root update-locale LANG=ru_RU.UTF-8 >/dev/null 2>&1 || true
  fi
}

sync_lab_content() {
  log "Копирую учебный контент в $TARGET_LAB_DIR"
  rm -rf "$TARGET_LAB_DIR"
  mkdir -p "$TARGET_LAB_DIR"
  cp -a "$LAB_SOURCE_DIR"/. "$TARGET_LAB_DIR"/
}

install_shell_files() {
  log "Устанавливаю shell helper-файлы"
  mkdir -p "$TARGET_BIN_DIR" "$TARGET_SHARE_DIR" "$TARGET_HELP_DIR"
  install -m 0755 "$WELCOME_SOURCE" "$TARGET_WELCOME"
  install -m 0644 "$HELPERS_SOURCE" "$TARGET_HELPERS"
  install -m 0755 "$TLDR_WRAPPER_SOURCE" "$TARGET_TLDR"
  cp -a "$HELP_SOURCE_DIR"/. "$TARGET_HELP_DIR"/
}

preflight() {
  log "Проверяю окружение"
  [ "$(uname -s)" = "Linux" ] || fail "установка поддерживается только на Linux"

  need_cmd cp
  need_cmd install
  need_cmd mkdir
  need_cmd grep

  [ -d "$LAB_SOURCE_DIR" ] || fail "не найдена директория $LAB_SOURCE_DIR"
  [ -f "$LAB_SOURCE_DIR/README.md" ] || fail "не найден $LAB_SOURCE_DIR/README.md"
  [ -d "$LAB_SOURCE_DIR/tasks" ] || fail "не найден каталог $LAB_SOURCE_DIR/tasks"
  [ -f "$WELCOME_SOURCE" ] || fail "не найден $WELCOME_SOURCE"
  [ -f "$HELPERS_SOURCE" ] || fail "не найден $HELPERS_SOURCE"
  [ -d "$HELP_SOURCE_DIR" ] || fail "не найдена директория $HELP_SOURCE_DIR"
  [ -f "$TLDR_WRAPPER_SOURCE" ] || fail "не найден $TLDR_WRAPPER_SOURCE"
}

main() {
  preflight
  install_packages
  ensure_russian_locale
  sync_lab_content
  install_shell_files
  append_bashrc_block

  log "Установка завершена"
  log "Linux Lab установлен в $TARGET_LAB_DIR"
  log "Русская справка доступна через h, hman, hs и tldr"
  log "Откройте новую shell-сессию или выполните: exec bash"
  log "После этого можно перейти в ~/linux-lab и начать с README.md"
}

main "$@"
