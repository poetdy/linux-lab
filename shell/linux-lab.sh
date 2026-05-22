#!/usr/bin/env bash

# Linux Lab helpers for interactive shells.

alias ll='ls -lah'
alias la='ls -A'
alias grep='grep --color=auto'
alias ip4='ip -4 addr'
alias ports='ss -tulpn'
alias psg='ps aux | grep -i'
alias cls='clear'

# Debian package names may differ from generic upstream names.
alias bat='batcat 2>/dev/null || bat'
alias fd='fdfind 2>/dev/null || fd'

linux_lab_help_dir() {
  printf '%s\n' "$HOME/.local/share/linux-lab/help"
}

linux_lab_help_file() {
  local topic="$1"
  printf '%s/%s.txt\n' "$(linux_lab_help_dir)" "$topic"
}

linux_lab_print_local_help() {
  local topic="$1"
  local help_file

  help_file="$(linux_lab_help_file "$topic")"
  if [ -f "$help_file" ]; then
    cat "$help_file"
    return 0
  fi

  return 1
}

hman() {
  if LANG=ru_RU.UTF-8 man "$@" 2>/dev/null; then
    return 0
  fi

  if [ $# -gt 0 ] && linux_lab_print_local_help "$1"; then
    return 0
  fi

  echo "Русская man-страница недоступна, и локальная подсказка не найдена."
  return 1
}

h() {
  if [ $# -eq 0 ]; then
    echo "Linux Lab help:"
    echo "  h tar          краткая справка tldr"
    echo "  hman tar       русская man-страница"
    echo "  hs archive     поиск по описаниям man"
    echo "  lab            список учебных тем"
    echo "  lesson 01-files  интерактивный lesson runner"
    echo "  ports          открытые порты"
    echo "  ip4            IP-адреса"
    return
  fi

  if command -v tldr >/dev/null 2>&1 && tldr --language ru "$1" 2>/dev/null; then
    return 0
  fi

  if command -v tldr >/dev/null 2>&1 && tldr "$1" 2>/dev/null; then
    return 0
  fi

  if hman "$1"; then
    return 0
  fi

  if linux_lab_print_local_help "$1"; then
    return 0
  fi

  echo "Не удалось найти справку для '$1'."
  return 1
}

hs() {
  local query="$*"
  local help_dir
  local found=1

  if LANG=ru_RU.UTF-8 apropos "$@" 2>/dev/null; then
    found=0
  fi

  help_dir="$(linux_lab_help_dir)"
  if [ -d "$help_dir" ]; then
    if grep -RIl -- "$query" "$help_dir" >/dev/null 2>&1; then
      echo
      echo "Локальные подсказки Linux Lab:"
      grep -RIl -- "$query" "$help_dir" | sed 's#.*/##; s#\.txt$##' | sort
      found=0
    fi
  fi

  if [ "$found" -ne 0 ]; then
    echo "Ничего не найдено по запросу: $query"
    return 1
  fi
}

lab() {
  echo "Учебные темы:"
  echo "  01-files        файлы, директории, ls/cp/mv/rm/find"
  echo "  02-permissions  права, chmod/chown/groups"
  echo "  03-processes    процессы, ps/top/kill/systemctl"
  echo "  04-network      ip/ss/ping/dig/curl/nmap"
  echo "  05-logs         journalctl, /var/log"
  echo "  06-ssh          ключи, ssh config, scp/rsync"
  echo "  07-bash         переменные, пайпы, grep/sed/awk"
  echo "  08-docker       контейнеры и compose"
  echo
  echo "Примеры:"
  echo "  h find"
  echo "  hman chmod"
  echo "  hs network"
  echo "  lesson 01-files"
}

menu() {
  local choice topic

  while true; do
    echo
    echo '=== Linux Lab Menu ==='
    echo '1) Открыть README учебного полигона'
    echo '2) Показать список тем'
    echo '3) Перейти в 01-files'
    echo '4) Запустить lesson runner'
    echo '5) Выбрать тему вручную'
    echo '6) Перейти в ~/linux-lab'
    echo '7) Показать команды помощи'
    echo '8) Выход из меню'
    echo
    read -r -p 'Выбери пункт [1-8] (Enter = выход): ' choice

    case "$choice" in
      1)
        if command -v less >/dev/null 2>&1; then
          less "$HOME/linux-lab/README.md"
        else
          sed -n '1,260p' "$HOME/linux-lab/README.md"
        fi
        ;;
      2)
        lab
        ;;
      3)
        cd "$HOME/linux-lab/tasks/01-files" || return 1
        echo 'Ты в ~/linux-lab/tasks/01-files'
        echo 'Дальше можно выполнить:'
        echo '  bash setup.sh'
        echo "  sed -n '1,200p' lesson.md"
        echo "  sed -n '1,240p' practice.md"
        echo '  lesson 01-files'
        break
        ;;
      4)
        echo 'Доступные темы для runner:'
        if [ -d "$HOME/linux-lab/tasks" ]; then
          find "$HOME/linux-lab/tasks" -mindepth 2 -maxdepth 2 -name runner.txt -print | sed 's#^.*/tasks/##; s#/runner.txt$##' | sort
        else
          echo '  01-files'
        fi
        read -r -p 'Введи имя темы: ' topic
        if [ -z "$topic" ]; then
          echo 'Тема не указана.'
        elif command -v lesson >/dev/null 2>&1; then
          lesson "$topic"
        elif [ -x "$HOME/.local/bin/lesson" ]; then
          "$HOME/.local/bin/lesson" "$topic"
        else
          echo 'Команда lesson пока не установлена. Запусти install.sh и открой новую shell-сессию.'
        fi
        ;;
      5)
        echo 'Доступные темы:'
        echo '  01-files'
        echo '  02-permissions'
        echo '  03-processes'
        echo '  04-network'
        echo '  05-logs'
        echo '  06-ssh'
        echo '  07-bash'
        echo '  08-docker'
        read -r -p 'Введи имя темы: ' topic
        if [ -n "$topic" ] && [ -d "$HOME/linux-lab/tasks/$topic" ]; then
          cd "$HOME/linux-lab/tasks/$topic" || return 1
          echo "Ты в ~/linux-lab/tasks/$topic"
          echo 'Дальше обычно идут:'
          echo '  bash setup.sh'
          echo "  sed -n '1,200p' lesson.md"
          echo "  sed -n '1,240p' practice.md"
          break
        else
          echo 'Неизвестная тема. Попробуй еще раз.'
        fi
        ;;
      6)
        cd "$HOME/linux-lab" || return 1
        echo 'Ты в ~/linux-lab'
        break
        ;;
      7)
        h
        ;;
      8|'')
        break
        ;;
      *)
        echo 'Неизвестный пункт. Выбери число от 1 до 8.'
        ;;
    esac
  done
}

if [[ $- == *i* ]] && [[ -n "${SSH_CONNECTION:-}" ]] && [ -x "$HOME/.local/bin/lab-welcome" ]; then
  "$HOME/.local/bin/lab-welcome"
fi
