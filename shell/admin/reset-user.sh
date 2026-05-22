#!/usr/bin/env bash

set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
DEFAULT_GROUPS="sudo,adm,cdrom,floppy,audio,dip,video,plugdev,users,netdev"

TARGET_USER=""
TARGET_GROUPS="$DEFAULT_GROUPS"
DRY_RUN=0
CONFIRMED=0

usage() {
  cat <<EOF
Usage:
  $SCRIPT_NAME --user <name> --dry-run
  $SCRIPT_NAME --user <name> --yes-reset-user [--groups <csv>]

Reset a Debian-style user by deleting the account and home directory,
then recreating the user with a fresh home, /bin/bash, default working
groups, and an interactive passwd prompt.

Options:
  --user <name>         Target username to reset.
  --groups <csv>        Secondary groups to assign after recreation.
                        Default: $DEFAULT_GROUPS
  --dry-run             Print the planned actions without making changes.
  --yes-reset-user      Required confirmation flag for destructive mode.
  --help                Show this help text.
EOF
}

log() {
  printf '[reset-user] %s\n' "$1"
}

warn() {
  printf '[reset-user] Warning: %s\n' "$1" >&2
}

fail() {
  printf '[reset-user] Error: %s\n' "$1" >&2
  exit 1
}

run_cmd() {
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '[dry-run] '
    printf '%q ' "$@"
    printf '\n'
    return 0
  fi

  "$@"
}

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

parse_args() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --user)
        [ "$#" -ge 2 ] || fail "option --user requires a value"
        TARGET_USER="$2"
        shift 2
        ;;
      --groups)
        [ "$#" -ge 2 ] || fail "option --groups requires a value"
        TARGET_GROUPS="$2"
        shift 2
        ;;
      --dry-run)
        DRY_RUN=1
        shift
        ;;
      --yes-reset-user)
        CONFIRMED=1
        shift
        ;;
      --help|-h)
        usage
        exit 0
        ;;
      *)
        fail "unknown option: $1"
        ;;
    esac
  done
}

require_root() {
  [ "$(id -u)" -eq 0 ] || fail "run this script as root"
}

validate_confirmation() {
  [ -n "$TARGET_USER" ] || fail "option --user is required"

  if [ "$DRY_RUN" -eq 0 ] && [ "$CONFIRMED" -ne 1 ]; then
    fail "destructive mode requires --yes-reset-user"
  fi
}

validate_target_user() {
  local current_user
  current_user="$(id -un)"

  [ "$TARGET_USER" != "root" ] || fail "refusing to reset root"
  [ "$TARGET_USER" != "$current_user" ] || fail "refusing to reset the current effective user"
  [[ "$TARGET_USER" =~ ^[a-z_][a-z0-9_-]*$ ]] || fail "username '$TARGET_USER' has an unsupported format"
}

user_exists() {
  getent passwd "$TARGET_USER" >/dev/null 2>&1
}

resolve_home() {
  if user_exists; then
    getent passwd "$TARGET_USER" | cut -d: -f6
  else
    printf '/home/%s\n' "$TARGET_USER"
  fi
}

validate_home_path() {
  local home_dir="$1"
  [ "$home_dir" = "/home/$TARGET_USER" ] || fail "expected home directory /home/$TARGET_USER, got $home_dir"
}

resolve_group_csv() {
  local raw_csv="$1"
  local trimmed_csv
  local group_name
  local valid_groups=()
  local missing_groups=()

  IFS=',' read -r -a group_items <<< "$raw_csv"
  for group_name in "${group_items[@]}"; do
    group_name="$(trim "$group_name")"
    [ -n "$group_name" ] || continue
    if getent group "$group_name" >/dev/null 2>&1; then
      valid_groups+=("$group_name")
    else
      missing_groups+=("$group_name")
    fi
  done

  if [ "${#missing_groups[@]}" -gt 0 ]; then
    warn "skipping missing groups: ${missing_groups[*]}"
  fi

  if [ "${#valid_groups[@]}" -eq 0 ]; then
    printf '\n'
    return 0
  fi

  trimmed_csv="$(IFS=','; printf '%s' "${valid_groups[*]}")"
  printf '%s\n' "$trimmed_csv"
}

print_plan() {
  local home_dir="$1"
  local group_csv="$2"

  log "Planned reset for user '$TARGET_USER':"
  log "  - remove account and home: $home_dir"
  log "  - recreate user with shell: /bin/bash"
  if [ -n "$group_csv" ]; then
    log "  - assign secondary groups: $group_csv"
  else
    log "  - assign secondary groups: none"
  fi
  log "  - create clean SSH directory: $home_dir/.ssh"
  log "  - prompt interactively for new password via passwd"
}

terminate_user_processes() {
  if ! user_exists; then
    log "User '$TARGET_USER' does not exist yet, skipping process termination"
    return 0
  fi

  if pgrep -u "$TARGET_USER" >/dev/null 2>&1; then
    log "Terminating processes for user '$TARGET_USER'"
    run_cmd pkill -TERM -u "$TARGET_USER"

    if [ "$DRY_RUN" -eq 0 ]; then
      sleep 2
      if pgrep -u "$TARGET_USER" >/dev/null 2>&1; then
        log "Sending SIGKILL to remaining processes for '$TARGET_USER'"
        pkill -KILL -u "$TARGET_USER" || true
        sleep 1
      fi

      if pgrep -u "$TARGET_USER" >/dev/null 2>&1; then
        fail "could not stop all processes for user '$TARGET_USER'"
      fi
    fi
  else
    log "No running processes found for user '$TARGET_USER'"
  fi
}

remove_user_account() {
  if ! user_exists; then
    log "User '$TARGET_USER' does not exist, skipping deletion"
    return 0
  fi

  log "Removing user '$TARGET_USER' and home directory"
  if command -v deluser >/dev/null 2>&1; then
    run_cmd deluser --remove-home "$TARGET_USER"
    return 0
  fi

  if command -v userdel >/dev/null 2>&1; then
    run_cmd userdel -r "$TARGET_USER"
    return 0
  fi

  fail "neither deluser nor userdel is available"
}

create_user_account() {
  log "Creating user '$TARGET_USER'"
  if command -v adduser >/dev/null 2>&1; then
    run_cmd adduser --disabled-password --gecos "" --shell /bin/bash "$TARGET_USER"
    return 0
  fi

  if command -v useradd >/dev/null 2>&1; then
    run_cmd useradd -m -s /bin/bash "$TARGET_USER"
    return 0
  fi

  fail "neither adduser nor useradd is available"
}

assign_secondary_groups() {
  local group_csv="$1"

  if [ -z "$group_csv" ]; then
    log "No secondary groups to assign"
    return 0
  fi

  log "Assigning groups to '$TARGET_USER': $group_csv"
  run_cmd usermod -aG "$group_csv" "$TARGET_USER"
}

setup_ssh_dir() {
  local home_dir="$1"
  local ssh_dir="$home_dir/.ssh"

  log "Creating clean SSH directory at $ssh_dir"
  run_cmd install -d -m 0700 -o "$TARGET_USER" -g "$TARGET_USER" "$ssh_dir"
}

set_password() {
  log "Launching interactive passwd for '$TARGET_USER'"
  passwd "$TARGET_USER"
}

print_success() {
  local home_dir="$1"

  log "User '$TARGET_USER' was recreated successfully"
  log "Suggested verification:"
  log "  id $TARGET_USER"
  log "  getent passwd $TARGET_USER"
  log "  ls -ld $home_dir $home_dir/.ssh"
}

main() {
  local home_dir
  local group_csv

  parse_args "$@"
  require_root
  validate_confirmation
  validate_target_user

  home_dir="$(resolve_home)"
  validate_home_path "$home_dir"
  group_csv="$(resolve_group_csv "$TARGET_GROUPS")"

  print_plan "$home_dir" "$group_csv"
  if [ "$DRY_RUN" -eq 1 ]; then
    log "Dry-run complete. No changes were made."
    exit 0
  fi

  terminate_user_processes
  remove_user_account
  create_user_account
  assign_secondary_groups "$group_csv"
  setup_ssh_dir "$home_dir"
  set_password
  print_success "$home_dir"
}

main "$@"
