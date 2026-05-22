#!/usr/bin/env bash

if [ -z "${LINUX_LAB_RUNNER_LIB_LOADED:-}" ]; then
  LINUX_LAB_RUNNER_LIB_LOADED=1

  declare -ag LINUX_LAB_RUNNER_INTRO=()
  declare -ag LINUX_LAB_RUNNER_STEP_IDS=()
  declare -ag LINUX_LAB_RUNNER_STEP_VARS=()

  LINUX_LAB_RUNNER_TITLE=""
  LINUX_LAB_RUNNER_COMMANDS=""
  LINUX_LAB_RUNNER_CURRENT_TOPIC=""
  LINUX_LAB_RUNNER_WORKDIR=""
  LINUX_LAB_RUNNER_SETUP_CMD=""
  LINUX_LAB_RUNNER_LAST_MESSAGE=""
  LINUX_LAB_RUNNER_LAST_STATUS=1
  LINUX_LAB_RUNNER_LAST_COMMAND_STATUS=0
  LINUX_LAB_RUNNER_HELP_LOADED=0
fi

linux_lab_trim() {
  local value="$*"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

linux_lab_runner_sanitize_key() {
  printf '%s' "$1" | tr '[:lower:]-' '[:upper:]_' | sed 's/[^A-Z0-9_]/_/g'
}

linux_lab_runner_var_name() {
  local step_id="$1"
  local field_name="$2"
  printf 'LINUX_LAB_STEP_%s_%s' \
    "$(linux_lab_runner_sanitize_key "$step_id")" \
    "$(linux_lab_runner_sanitize_key "$field_name")"
}

linux_lab_runner_set_step_value() {
  local step_id="$1"
  local field_name="$2"
  local value="$3"
  local var_name

  var_name="$(linux_lab_runner_var_name "$step_id" "$field_name")"
  printf -v "$var_name" '%s' "$value"
  LINUX_LAB_RUNNER_STEP_VARS+=("$var_name")
}

linux_lab_runner_file() {
  printf '%s\n' "$1/runner.txt"
}

linux_lab_runner_reset() {
  local var_name

  for var_name in "${LINUX_LAB_RUNNER_STEP_VARS[@]:-}"; do
    unset "$var_name"
  done

  LINUX_LAB_RUNNER_TITLE=""
  LINUX_LAB_RUNNER_COMMANDS=""
  LINUX_LAB_RUNNER_CURRENT_TOPIC=""
  LINUX_LAB_RUNNER_WORKDIR=""
  LINUX_LAB_RUNNER_SETUP_CMD=""
  LINUX_LAB_RUNNER_LAST_MESSAGE=""
  LINUX_LAB_RUNNER_LAST_STATUS=1
  LINUX_LAB_RUNNER_LAST_COMMAND_STATUS=0
  LINUX_LAB_RUNNER_INTRO=()
  LINUX_LAB_RUNNER_STEP_IDS=()
  LINUX_LAB_RUNNER_STEP_VARS=()
}

linux_lab_load_runner() {
  local topic_dir="$1"
  local runner_file
  local raw_line line key value current_step=""

  linux_lab_runner_reset
  runner_file="$(linux_lab_runner_file "$topic_dir")"

  if [ ! -f "$runner_file" ]; then
    printf 'Сценарий lesson runner не найден: %s\n' "$runner_file" >&2
    return 1
  fi

  LINUX_LAB_RUNNER_CURRENT_TOPIC="$(basename "$topic_dir")"

  while IFS= read -r raw_line || [ -n "$raw_line" ]; do
    line="${raw_line%$'\r'}"
    line="$(linux_lab_trim "$line")"

    if [ -z "$line" ] || [[ "$line" == \#* ]]; then
      continue
    fi

    if [[ "$line" != *:* ]]; then
      continue
    fi

    key="$(linux_lab_trim "${line%%:*}")"
    value="$(linux_lab_trim "${line#*:}")"

    case "$key" in
      TITLE)
        LINUX_LAB_RUNNER_TITLE="$value"
        ;;
      INTRO)
        LINUX_LAB_RUNNER_INTRO+=("$value")
        ;;
      COMMANDS)
        if [ -n "$LINUX_LAB_RUNNER_COMMANDS" ]; then
          LINUX_LAB_RUNNER_COMMANDS="$LINUX_LAB_RUNNER_COMMANDS $value"
        else
          LINUX_LAB_RUNNER_COMMANDS="$value"
        fi
        ;;
      WORKDIR)
        LINUX_LAB_RUNNER_WORKDIR="$value"
        ;;
      SETUP_CMD)
        LINUX_LAB_RUNNER_SETUP_CMD="$value"
        ;;
      STEP)
        current_step="$value"
        LINUX_LAB_RUNNER_STEP_IDS+=("$current_step")
        ;;
      *)
        if [ -n "$current_step" ]; then
          linux_lab_runner_set_step_value "$current_step" "$key" "$value"
        fi
        ;;
    esac
  done < "$runner_file"

  if [ -z "$LINUX_LAB_RUNNER_TITLE" ]; then
    LINUX_LAB_RUNNER_TITLE="$LINUX_LAB_RUNNER_CURRENT_TOPIC"
  fi

  if [ "${#LINUX_LAB_RUNNER_STEP_IDS[@]}" -eq 0 ]; then
    printf 'Сценарий не содержит шагов: %s\n' "$runner_file" >&2
    return 1
  fi
}

linux_lab_step_ids() {
  printf '%s\n' "${LINUX_LAB_RUNNER_STEP_IDS[@]}"
}

linux_lab_step_value() {
  local step_id="$1"
  local field_name="$2"
  local var_name

  var_name="$(linux_lab_runner_var_name "$step_id" "$field_name")"
  printf '%s\n' "${!var_name-}"
}

linux_lab_lesson_usage() {
  echo "Использование: lesson <topic>"
  echo
  echo "Примеры:"
  echo "  lesson 01-files"
  echo "  lesson 02-permissions"
}

linux_lab_runner_source_linux_lab_helpers() {
  local lib_dir helper_file

  if [ "$LINUX_LAB_RUNNER_HELP_LOADED" -eq 1 ]; then
    return 0
  fi

  lib_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  for helper_file in \
    "$HOME/.local/share/linux-lab/linux-lab.sh" \
    "$lib_dir/linux-lab.sh"
  do
    if [ -f "$helper_file" ]; then
      # Reuse the existing layered help helpers.
      . "$helper_file"
      LINUX_LAB_RUNNER_HELP_LOADED=1
      return 0
    fi
  done

  return 1
}

linux_lab_runner_heading() {
  echo
  echo "=== Lesson Runner: $LINUX_LAB_RUNNER_TITLE ==="
  echo "Тема: $LINUX_LAB_RUNNER_CURRENT_TOPIC"
}

linux_lab_render_intro() {
  local intro_line

  linux_lab_runner_heading

  if [ "${#LINUX_LAB_RUNNER_INTRO[@]}" -gt 0 ]; then
    echo
    for intro_line in "${LINUX_LAB_RUNNER_INTRO[@]}"; do
      echo "$intro_line"
    done
  fi

  if [ -n "$LINUX_LAB_RUNNER_COMMANDS" ]; then
    echo
    echo "Ключевые команды: $LINUX_LAB_RUNNER_COMMANDS"
  fi

  echo
  echo "Действия: hint, help, explain, check, skip, quit"
}

linux_lab_render_step() {
  local step_id="$1"
  local step_index="$2"
  local step_total="$3"
  local task mode expected context_line

  task="$(linux_lab_step_value "$step_id" "TASK")"
  mode="$(linux_lab_step_value "$step_id" "MODE")"
  expected="$(linux_lab_step_value "$step_id" "EXPECTED_COMMANDS")"

  echo
  echo "--- Шаг $step_index/$step_total: $step_id ---"
  echo "Режим: ${mode:-guided}"
  context_line="${LINUX_LAB_RUNNER_INTRO[0]-}"
  if [ -n "$context_line" ]; then
    echo "Контекст: $context_line"
  fi
  echo "Текущий каталог: $(pwd)"
  echo "Задание: $task"
  if [ -n "$expected" ]; then
    echo "Фокус шага: $expected"
  fi
  echo "Подсказки: hint | help | explain | check | skip | quit"
}

linux_lab_check_command_contains() {
  local learner_input="$1"
  local pattern="$2"

  [ -n "$pattern" ] || return 0
  [[ "$learner_input" == *"$pattern"* ]]
}

linux_lab_check_command_regex() {
  local learner_input="$1"
  local pattern="$2"

  [ -n "$pattern" ] || return 0
  printf '%s\n' "$learner_input" | grep -Eq -- "$pattern"
}

linux_lab_runner_command_matches_expected() {
  local learner_input="$1"
  local expected_commands="$2"
  local expected_name normalized
  normalized="${expected_commands//,/ }"

  for expected_name in $normalized; do
    if printf '%s\n' "$learner_input" | grep -Eq "(^|[[:space:];(|&])(command[[:space:]]+)?${expected_name}([[:space:]]|$)"; then
      return 0
    fi
  done

  return 1
}

linux_lab_runner_glob_count() {
  local glob_pattern="$1"
  local count
  local matches=()

  shopt -s nullglob
  matches=($glob_pattern)
  shopt -u nullglob
  count="${#matches[@]}"
  printf '%s\n' "$count"
}

linux_lab_runner_check_artifacts() {
  local step_id="$1"
  local check_path check_paths_raw check_glob check_globs_raw check_archive check_archive_pattern
  local min_count max_count actual_count
  local path_item glob_item total_count

  check_path="$(linux_lab_step_value "$step_id" "CHECK_PATH")"
  check_paths_raw="$(linux_lab_step_value "$step_id" "CHECK_PATHS")"
  check_glob="$(linux_lab_step_value "$step_id" "CHECK_GLOB")"
  check_globs_raw="$(linux_lab_step_value "$step_id" "CHECK_GLOBS")"
  check_archive="$(linux_lab_step_value "$step_id" "CHECK_ARCHIVE")"
  check_archive_pattern="$(linux_lab_step_value "$step_id" "CHECK_ARCHIVE_PATTERN")"
  min_count="$(linux_lab_step_value "$step_id" "CHECK_MIN_COUNT")"
  max_count="$(linux_lab_step_value "$step_id" "CHECK_MAX_COUNT")"

  if [ -n "$check_path" ] && [ ! -e "$check_path" ]; then
    return 1
  fi
  if [ -n "$check_paths_raw" ]; then
    for path_item in $check_paths_raw; do
      [ -e "$path_item" ] || return 1
    done
  fi

  if [ -n "$check_glob" ] || [ -n "$check_globs_raw" ]; then
    total_count=0
    if [ -n "$check_globs_raw" ]; then
      IFS=';' read -r -a glob_items <<< "$check_globs_raw"
      for glob_item in "${glob_items[@]}"; do
        actual_count="$(linux_lab_runner_glob_count "$glob_item")"
        total_count=$((total_count + actual_count))
      done
    else
      total_count="$(linux_lab_runner_glob_count "$check_glob")"
    fi
    if [ -z "$min_count" ]; then
      min_count=1
    fi
    if [ "$total_count" -lt "$min_count" ]; then
      return 1
    fi
    if [ -n "$max_count" ] && [ "$total_count" -gt "$max_count" ]; then
      return 1
    fi
  fi

  if [ -n "$check_archive" ]; then
    if [ ! -f "$check_archive" ]; then
      return 1
    fi
    if [ -n "$check_archive_pattern" ]; then
      tar -tf "$check_archive" 2>/dev/null | grep -Eq -- "$check_archive_pattern" || return 1
    fi
  fi

  return 0
}

linux_lab_runner_check_result() {
  local step_id="$1"
  local check_type check_pattern check_archive check_archive_pattern

  check_type="$(linux_lab_step_value "$step_id" "CHECK_TYPE")"
  check_pattern="$(linux_lab_step_value "$step_id" "CHECK_PATTERN")"
  check_archive="$(linux_lab_step_value "$step_id" "CHECK_ARCHIVE")"
  check_archive_pattern="$(linux_lab_step_value "$step_id" "CHECK_ARCHIVE_PATTERN")"

  case "$check_type" in
    ""|command_contains|command_regex)
      linux_lab_runner_check_artifacts "$step_id"
      ;;
    path_exists)
      linux_lab_runner_check_artifacts "$step_id"
      ;;
    dir_exists)
      [ -d "$(linux_lab_step_value "$step_id" "CHECK_PATH")" ]
      ;;
    file_exists)
      [ -f "$(linux_lab_step_value "$step_id" "CHECK_PATH")" ]
      ;;
    moved_matches|glob_count)
      linux_lab_runner_check_artifacts "$step_id"
      ;;
    archive_contains)
      [ -n "$check_archive" ] || return 1
      [ -n "$check_archive_pattern" ] || check_archive_pattern="$check_pattern"
      [ -n "$check_archive_pattern" ] || return 1
      tar -tf "$check_archive" 2>/dev/null | grep -Eq -- "$check_archive_pattern"
      ;;
    *)
      printf 'Неизвестный CHECK_TYPE: %s\n' "$check_type" >&2
      return 1
      ;;
  esac
}

linux_lab_runner_has_result_expectation() {
  local step_id="$1"

  [ -n "$(linux_lab_step_value "$step_id" "CHECK_PATH")" ] && return 0
  [ -n "$(linux_lab_step_value "$step_id" "CHECK_PATHS")" ] && return 0
  [ -n "$(linux_lab_step_value "$step_id" "CHECK_GLOB")" ] && return 0
  [ -n "$(linux_lab_step_value "$step_id" "CHECK_GLOBS")" ] && return 0
  [ -n "$(linux_lab_step_value "$step_id" "CHECK_ARCHIVE")" ] && return 0
  return 1
}

linux_lab_runner_allow_alternatives() {
  local step_id="$1"
  local value

  value="$(linux_lab_step_value "$step_id" "ALLOW_ALTERNATIVES")"
  case "${value,,}" in
    yes|true|1)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

linux_lab_runner_expand_home() {
  local path_value="$1"

  eval "printf '%s\n' \"$path_value\""
}

linux_lab_runner_prepare_workspace() {
  local expanded_workdir

  if [ -z "$LINUX_LAB_RUNNER_WORKDIR" ]; then
    return 0
  fi

  expanded_workdir="$(linux_lab_runner_expand_home "$LINUX_LAB_RUNNER_WORKDIR")"
  if [ ! -d "$expanded_workdir" ] && [ -n "$LINUX_LAB_RUNNER_SETUP_CMD" ]; then
    echo "Подготавливаю среду урока через setup-команду..."
    bash -lc "$LINUX_LAB_RUNNER_SETUP_CMD" || return 1
  fi

  if [ ! -d "$expanded_workdir" ]; then
    echo "Рабочий каталог runner не найден: $expanded_workdir"
    echo "Подготовь тему вручную и попробуй снова."
    return 1
  fi

  cd "$expanded_workdir" || return 1
  echo "Runner работает в каталоге: $expanded_workdir"
}

linux_lab_runner_set_feedback() {
  LINUX_LAB_RUNNER_LAST_STATUS="$1"
  LINUX_LAB_RUNNER_LAST_MESSAGE="$2"
}

linux_lab_validate_guided_step() {
  local step_id="$1"
  local learner_input="$2"
  local command_status="$3"
  local expected_commands check_type check_pattern

  expected_commands="$(linux_lab_step_value "$step_id" "EXPECTED_COMMANDS")"
  check_type="$(linux_lab_step_value "$step_id" "CHECK_TYPE")"
  check_pattern="$(linux_lab_step_value "$step_id" "CHECK_PATTERN")"

  if [ -z "$learner_input" ]; then
    linux_lab_runner_set_feedback 1 "Сначала выполни команду для этого шага."
    return 1
  fi

  if [ -n "$expected_commands" ] && ! linux_lab_runner_command_matches_expected "$learner_input" "$expected_commands"; then
    linux_lab_runner_set_feedback 1 "Сейчас тренируем команду из семейства: $expected_commands."
    return 1
  fi

  if [ "$command_status" -ne 0 ]; then
    linux_lab_runner_set_feedback 1 "Команда похожа на нужную, но завершилась с ошибкой. Исправь запуск и попробуй еще раз."
    return 1
  fi

  case "$check_type" in
    command_contains)
      if linux_lab_check_command_contains "$learner_input" "$check_pattern"; then
        if linux_lab_runner_has_result_expectation "$step_id" && ! linux_lab_runner_check_result "$step_id"; then
          linux_lab_runner_set_feedback 1 "Команда подходит по смыслу, но ожидаемый результат шага пока не появился."
          return 1
        fi
        linux_lab_runner_set_feedback 0 "Шаг засчитан. Команда подходит по смыслу."
        return 0
      fi
      linux_lab_runner_set_feedback 1 "Почти верно: нужная команда есть, но не хватает важной части."
      return 1
      ;;
    command_regex)
      if linux_lab_check_command_regex "$learner_input" "$check_pattern"; then
        if linux_lab_runner_has_result_expectation "$step_id" && ! linux_lab_runner_check_result "$step_id"; then
          linux_lab_runner_set_feedback 1 "Формулировка команды подходит, но результат шага пока не соответствует задаче."
          return 1
        fi
        linux_lab_runner_set_feedback 0 "Шаг засчитан. Формулировка команды подходит."
        return 0
      fi
      linux_lab_runner_set_feedback 1 "Почти верно: команда из нужного семейства, но шаблон шага пока не совпал."
      return 1
      ;;
    ""|path_exists|dir_exists|file_exists|moved_matches|glob_count|archive_contains)
      if linux_lab_runner_check_result "$step_id"; then
        linux_lab_runner_set_feedback 0 "Шаг засчитан."
        return 0
      fi
      linux_lab_runner_set_feedback 1 "Команда выглядит уместно, но результат шага пока не готов."
      return 1
      ;;
    *)
      linux_lab_runner_set_feedback 1 "Не удалось проверить шаг: неизвестный тип проверки '$check_type'."
      return 1
      ;;
  esac
}

linux_lab_validate_flex_step() {
  local step_id="$1"
  local learner_input="$2"
  local command_status="${3:-0}"
  local expected_commands

  if [ -n "$learner_input" ] && [ "$command_status" -ne 0 ]; then
    linux_lab_runner_set_feedback 1 "Команда завершилась с ошибкой. Исправь ее и затем снова проверь результат."
    return 1
  fi

  expected_commands="$(linux_lab_step_value "$step_id" "EXPECTED_COMMANDS")"
  if [ -n "$learner_input" ] && ! linux_lab_runner_allow_alternatives "$step_id" && [ -n "$expected_commands" ]; then
    if ! linux_lab_runner_command_matches_expected "$learner_input" "$expected_commands"; then
      linux_lab_runner_set_feedback 1 "Для этого шага лучше использовать команду из семейства: $expected_commands."
      return 1
    fi
  fi

  if linux_lab_runner_check_result "$step_id"; then
    if [ -n "$learner_input" ]; then
      linux_lab_runner_set_feedback 0 "Шаг засчитан по результату. Команда может отличаться от ожидаемой."
    else
      linux_lab_runner_set_feedback 0 "Шаг засчитан по текущему результату."
    fi
    return 0
  fi

  linux_lab_runner_set_feedback 1 "Результат пока неполный. Проверь, все ли файлы и каталоги уже на месте."
  return 1
}

linux_lab_validate_step() {
  local step_id="$1"
  local learner_input="$2"
  local command_status="${3:-0}"
  local mode

  mode="$(linux_lab_step_value "$step_id" "MODE")"
  if [ -z "$mode" ]; then
    mode="guided"
  fi

  case "$mode" in
    guided)
      linux_lab_validate_guided_step "$step_id" "$learner_input" "$command_status"
      ;;
    flex)
      linux_lab_validate_flex_step "$step_id" "$learner_input" "$command_status"
      ;;
    *)
      linux_lab_runner_set_feedback 1 "Неизвестный режим шага: $mode"
      return 1
      ;;
  esac
}

linux_lab_runner_print_hint() {
  local step_id="$1"
  local hint_text

  hint_text="$(linux_lab_step_value "$step_id" "HINT")"
  if [ -n "$hint_text" ]; then
    echo "Подсказка: $hint_text"
  else
    echo "Для этого шага подсказка пока не задана."
  fi
}

linux_lab_runner_print_explain() {
  local step_id="$1"
  local explain_text

  explain_text="$(linux_lab_step_value "$step_id" "EXPLAIN")"
  if [ -n "$explain_text" ]; then
    echo "Объяснение: $explain_text"
  else
    echo "Для этого шага объяснение пока не задано."
  fi
}

linux_lab_runner_show_help() {
  local step_id="$1"
  local help_topic expected_commands first_command

  help_topic="$(linux_lab_step_value "$step_id" "HELP_TOPIC")"
  expected_commands="$(linux_lab_step_value "$step_id" "EXPECTED_COMMANDS")"

  if [ -z "$help_topic" ] && [ -n "$expected_commands" ]; then
    first_command="${expected_commands%%[ ,]*}"
    help_topic="$first_command"
  fi

  if [ -z "$help_topic" ]; then
    echo "Для этого шага не указан HELP_TOPIC."
    return 1
  fi

  if ! linux_lab_runner_source_linux_lab_helpers; then
    echo "Не удалось подключить Linux Lab help layer."
    return 1
  fi

  h "$help_topic"
}

linux_lab_runner_execute_command() {
  local learner_input="$1"
  local command_status
  local current_dir

  if [ "$learner_input" = "cd" ] || [[ "$learner_input" == cd\ * ]]; then
    set +e
    builtin $learner_input
    command_status=$?
    set -e
  else
    current_dir="$(pwd)"
    set +e
    bash -lc "cd \"$current_dir\" && $learner_input"
    command_status=$?
    set -e
  fi

  LINUX_LAB_RUNNER_LAST_COMMAND_STATUS="$command_status"

  if [ "$command_status" -ne 0 ]; then
    echo "Команда завершилась с кодом $command_status."
  fi

  return "$command_status"
}

linux_lab_run_lesson() {
  local topic_dir="$1"
  local total_steps step_index current_step
  local learner_input trimmed_input last_command

  linux_lab_load_runner "$topic_dir" || return 1
  linux_lab_runner_prepare_workspace || return 1
  total_steps="${#LINUX_LAB_RUNNER_STEP_IDS[@]}"
  linux_lab_render_intro

  step_index=0
  while [ "$step_index" -lt "$total_steps" ]; do
    current_step="${LINUX_LAB_RUNNER_STEP_IDS[$step_index]}"
    last_command=""
    linux_lab_render_step "$current_step" "$((step_index + 1))" "$total_steps"

    while true; do
      echo
      read -r -p 'lesson> ' learner_input || {
        echo
        echo "Lesson runner завершен."
        return 0
      }

      trimmed_input="$(linux_lab_trim "$learner_input")"
      if [ -z "$trimmed_input" ]; then
        continue
      fi

      case "$trimmed_input" in
        hint)
          linux_lab_runner_print_hint "$current_step"
          ;;
        help)
          linux_lab_runner_show_help "$current_step"
          ;;
        explain)
          linux_lab_runner_print_explain "$current_step"
          ;;
        check)
          linux_lab_validate_step "$current_step" "$last_command" "$LINUX_LAB_RUNNER_LAST_COMMAND_STATUS"
          echo "$LINUX_LAB_RUNNER_LAST_MESSAGE"
          if [ "$LINUX_LAB_RUNNER_LAST_STATUS" -eq 0 ]; then
            step_index=$((step_index + 1))
            break
          fi
          ;;
        skip)
          echo "Шаг пропущен."
          step_index=$((step_index + 1))
          break
          ;;
        quit|exit)
          echo "Lesson runner завершен."
          return 0
          ;;
        *)
          last_command="$trimmed_input"
          linux_lab_runner_execute_command "$trimmed_input"
          linux_lab_validate_step "$current_step" "$last_command" "$LINUX_LAB_RUNNER_LAST_COMMAND_STATUS"
          echo "$LINUX_LAB_RUNNER_LAST_MESSAGE"
          if [ "$LINUX_LAB_RUNNER_LAST_STATUS" -eq 0 ]; then
            step_index=$((step_index + 1))
            break
          fi
          ;;
      esac
    done
  done

  echo
  echo "Урок '$LINUX_LAB_RUNNER_TITLE' завершен."
}
