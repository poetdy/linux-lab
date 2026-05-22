# Linux Lab Design

Date: 2026-05-21
Topic: Debian learning ground with lessons, practice, and checks

## Goal

Turn `~/linux-lab` on the Debian test server into a practical Linux training ground.
The system should help the user build command fluency, perform common admin operations,
and solve realistic troubleshooting tasks through repeated hands-on work.

## Existing Context

The server already contains the following structure:

- `README.md`
- `broken/`
- `notes/`
- `sandbox/`
- `scripts/`
- `services/`
- `tasks/`

The top-level `README.md` already defines eight learning topics:

1. `01-files`
2. `02-permissions`
3. `03-processes`
4. `04-network`
5. `05-logs`
6. `06-ssh`
7. `07-bash`
8. `08-docker`

These topic directories already exist under `tasks/` and should be preserved.

## Product Direction

The learning ground should prioritize:

- short lessons instead of long theory
- command repetition and muscle memory
- realistic exercises instead of abstract quizzes
- troubleshooting and recovery work
- self-checks and automated checks where possible

This is not intended to be a passive knowledge base. It should feel like a guided
practice environment.

## Standard Topic Structure

Each topic directory under `tasks/` should follow the same layout:

- `lesson.md`
- `practice.md`
- `checks.md`
- `verify.sh`
- `setup.sh` when the topic needs prepared data, broken state, or reset logic

### File Roles

`lesson.md`
- short explanation of what the topic covers
- list of key commands and flags
- small examples
- common mistakes to watch for

`practice.md`
- step-by-step practical drills
- short scenarios that require the learner to use commands, not just read them
- a final mini-case that combines several operations

`checks.md`
- expected outcomes
- prompts for self-verification
- criteria that confirm the task is complete without giving away full solutions

`verify.sh`
- non-interactive checks for artifacts, file state, permissions, service state, or output patterns
- should print a clear success or failure message

`setup.sh`
- creates sample files, folders, configs, logs, or intentionally broken states
- should be safe to rerun

## Learning Model

Each topic should follow the same progression:

1. Learn the core commands
2. Repeat them in guided drills
3. Apply them in realistic tasks
4. Diagnose and fix a small problem
5. Confirm success through self-check or script

The practice should move from direct command usage to judgment-based problem solving.

## Topic Design

### 01 Files

Focus:
- navigation
- listing
- copying
- moving
- removing
- searching
- archiving
- sizing files and directories

Practice examples:
- build a directory tree
- collect files by pattern
- move files into a cleaner structure
- find the largest files or directories
- create and inspect tar archives

Mini-case:
- restore a messy workspace into a required structure and ship it as an archive

### 02 Permissions

Focus:
- ownership
- rwx bits
- chmod
- chown
- groups
- default umask
- executable files

Practice examples:
- fix access to shared files
- make scripts executable
- repair directory traversal rights
- identify why a file cannot be read or run

Mini-case:
- make a shared project directory usable by the intended users without opening it too widely

### 03 Processes

Focus:
- ps
- top
- htop if available
- kill
- pkill
- jobs
- nohup
- systemctl basics

Practice examples:
- inspect running processes
- stop the correct process without killing the wrong one
- restart a service
- find why a service is not staying up

Mini-case:
- diagnose a failing or looping service in `services/`

### 04 Network

Focus:
- ip
- ss
- ping
- traceroute if available
- curl
- wget
- nc if available
- DNS resolution basics

Practice examples:
- identify local addresses
- confirm which port a service listens on
- test HTTP reachability
- distinguish connection refused from timeout from DNS failure

Mini-case:
- determine why a local service is not reachable and confirm the fix

### 05 Logs

Focus:
- journalctl
- tail
- less
- grep
- filtering by time
- filtering by unit

Practice examples:
- find the most recent error
- extract only failed requests
- follow a live log while reproducing a problem
- compare normal and broken behavior

Mini-case:
- locate the reason a service fails by using only logs and command-line filtering

### 06 SSH

Focus:
- ssh
- scp
- sftp basics
- ssh config
- key pairs
- authorized_keys
- host verification
- common auth failures

Practice examples:
- create a key pair
- add a key to an account
- define a host alias
- troubleshoot permission denied and host key warnings

Mini-case:
- recover access to a host using correct key placement and config

### 07 Bash

Focus:
- pipes
- redirection
- grep
- sed
- awk
- xargs
- command substitution
- loops for admin tasks

Practice examples:
- filter useful data out of noisy files
- transform output into a report
- batch-rename or batch-process files
- combine commands into one-liners

Mini-case:
- process logs or file metadata into a concise operational summary

### 08 Docker

Focus:
- images
- containers
- logs
- exec
- volumes
- ports
- restart behavior
- basic compose workflow if installed

Practice examples:
- run and inspect a container
- find why a container exits
- map a port correctly
- persist data through a volume

Mini-case:
- bring up a small broken containerized service and make it reachable

## Use Of Existing Directories

The current support directories should be used intentionally:

- `sandbox/` for safe file manipulation drills
- `services/` for process, service, and log scenarios
- `broken/` for repair and debugging tasks
- `scripts/` for helper setup and verify logic
- `notes/` for optional short hints or reference sheets later, not as the primary training path

## Verification Strategy

Verification should balance guidance and independence:

- use `checks.md` for human-readable verification
- use `verify.sh` for objective completion checks
- avoid printing full solutions
- fail with hints about what category is wrong when possible

Examples:
- wrong permissions
- missing file or directory
- wrong service state
- expected line not found in output
- archive missing required content

## Язык Материалов

Весь пользовательский учебный контент должен быть на русском языке:

- `lesson.md`
- `practice.md`
- `checks.md`
- комментарии и сообщения в `verify.sh`, если они видны пользователю
- комментарии и подсказки в `setup.sh`, если они предназначены для чтения

Технические имена файлов и директорий сохраняются в текущем виде на английском,
чтобы структура оставалась удобной для навигации и автоматизации.

## Authoring Rules

- keep lessons concise
- prefer commands that exist on a standard Debian system
- make tasks rerunnable
- avoid destructive operations outside the lab area
- keep wording action-oriented
- use Russian for all learner-facing materials for consistency with the existing README

## Scope For First Implementation Pass

The first pass should produce a full baseline for all eight topics:

- create `lesson.md`, `practice.md`, and `checks.md` in each topic
- create `verify.sh` for each topic
- create `setup.sh` only where needed
- wire exercises to existing shared directories where useful

Depth should be practical and consistent rather than perfect on the first pass.

## Out Of Scope

- web UI
- account system
- scoring dashboard
- complex grading backend
- large interactive TUI

The lab should remain file-based and shell-first.

## Risks And Mitigations

Risk:
- lessons become too theoretical
Mitigation:
- every topic must include hands-on drills and a mini-case

Risk:
- checks accidentally reveal solutions
Mitigation:
- validate outcomes, not command history

Risk:
- exercises depend on tools missing from Debian
Mitigation:
- prefer base tools and mark optional commands clearly

Risk:
- broken scenarios damage the broader server
Mitigation:
- keep all training artifacts inside `~/linux-lab`

## Implementation Outcome

After implementation, `~/linux-lab/tasks` should behave like a structured self-training course:

- each topic explains a narrow operational skill area
- each topic offers guided drills
- each topic includes practical troubleshooting
- each topic can be checked manually and, where appropriate, automatically
