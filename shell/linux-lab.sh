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

hman() {
  LANG=ru_RU.UTF-8 man "$@"
}

h() {
  if [ $# -eq 0 ]; then
    echo "Linux Lab help:"
    echo "  h tar          краткая справка tldr"
    echo "  hman tar       русская man-страница"
    echo "  hs archive     поиск по описаниям man"
    echo "  lab            список учебных тем"
    echo "  ports          открытые порты"
    echo "  ip4            IP-адреса"
    return
  fi

  tldr --language ru "$1" 2>/dev/null || tldr "$1" 2>/dev/null || hman "$1"
}

hs() {
  LANG=ru_RU.UTF-8 apropos "$@"
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
}

menu() {
  local choice topic

  while true; do
    echo
    echo '=== Linux Lab Menu ==='
    echo '1) Открыть README учебного полигона'
    echo '2) Показать список тем'
    echo '3) Перейти в 01-files'
    echo '4) Выбрать тему вручную'
    echo '5) Перейти в ~/linux-lab'
    echo '6) Показать команды помощи'
    echo '7) Выход из меню'
    echo
    read -r -p 'Выбери пункт [1-7] (Enter = выход): ' choice

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
        break
        ;;
      4)
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
      5)
        cd "$HOME/linux-lab" || return 1
        echo 'Ты в ~/linux-lab'
        break
        ;;
      6)
        h
        ;;
      7|'')
        break
        ;;
      *)
        echo 'Неизвестный пункт. Выбери число от 1 до 7.'
        ;;
    esac
  done
}

if [[ $- == *i* ]] && [[ -n "${SSH_CONNECTION:-}" ]] && [ -x "$HOME/.local/bin/lab-welcome" ]; then
  "$HOME/.local/bin/lab-welcome"
fi

