# Linux Lab Lesson Runner Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Добавить в Linux Lab интерактивный lesson runner с общим shell-движком, запуском через команду и `menu`, и редактируемым текстовым сценарием внутри темы.

**Architecture:** Общая логика runner живет в `shell/` и отвечает за парсинг сценария, экран шага, действия (`hint`, `help`, `explain`, `check`, `skip`, `quit`) и гибридную проверку. Контент темы хранится рядом с уроком в простом текстовом файле, чтобы любой контрибьютор мог менять шаги и подсказки без правки кода движка.

**Tech Stack:** Bash, текстовый сценарий темы, Linux shell commands, существующие `setup.sh`/`verify.sh`, content-first структура Linux Lab

---

## File Structure

### Existing files to modify

- Modify: `shell/linux-lab.sh`
- Modify: `shell/lab-welcome`
- Modify: `README.md`
- Modify: `docs/content-guide.md`
- Modify: `docs/install.md`

### New shell runner files

- Create: `shell/lesson`
- Create: `shell/lesson-runner-lib.sh`

### New topic runner content

- Create: `linux-lab/tasks/01-files/runner.txt`

### Optional topic notes

- Modify: `linux-lab/tasks/01-files/practice.md`
- Modify: `linux-lab/tasks/01-files/checks.md`

Only if needed to point learners to the runner without changing the core lesson flow.

## Task 1: Define Runner Scenario Format

**Files:**
- Create: `linux-lab/tasks/01-files/runner.txt`
- Modify: `docs/content-guide.md`

- [ ] **Step 1: Choose a simple line-oriented text format**

Use a shell-friendly format that can be parsed without external dependencies. Recommended structure:

```text
TITLE: 01-files
INTRO: Ты находишься в тренировке по файлам и каталогам.
INTRO: Сначала посмотри вокруг, затем выполни задания по одной команде.
COMMANDS: pwd ls find du mkdir mv

STEP: warmup-pwd
MODE: guided
TASK: Покажи текущую директорию.
EXPECTED_COMMANDS: pwd
HINT: Нужна команда, которая печатает путь текущего каталога.
HELP_TOPIC: pwd
EXPLAIN: Название pwd расшифровывается как print working directory.
CHECK_TYPE: command_contains
CHECK_PATTERN: pwd

STEP: warmup-list-hidden
MODE: guided
TASK: Выведи полный список файлов, включая скрытые.
EXPECTED_COMMANDS: ls
HINT: Вспомни команду списка файлов и ключ для скрытых элементов.
HELP_TOPIC: ls
EXPLAIN: Скрытые файлы в Linux начинаются с точки.
CHECK_TYPE: command_regex
CHECK_PATTERN: ls .*(-a|-la|-lah|-al)
```

Expected:
- format can be edited manually
- each step is understandable without code changes

- [ ] **Step 2: Define required and optional fields in `docs/content-guide.md`**

Document:
- required fields: `STEP`, `MODE`, `TASK`, `HINT`, `EXPLAIN`, `CHECK_TYPE`
- optional fields: `HELP_TOPIC`, `EXPECTED_COMMANDS`, `CHECK_PATTERN`, `ALLOW_ALTERNATIVES`
- allowed `MODE` values: `guided`, `flex`

Expected:
- contributors know how to add or change runner steps

- [ ] **Step 3: Verify the format is sufficient for the first topic**

Check manually that the format can represent:
- context block
- warmup tasks
- guided command-training tasks
- flexible result-based tasks

Expected:
- no extra parser complexity is required for version one

## Task 2: Build The Shared Runner Engine

**Files:**
- Create: `shell/lesson`
- Create: `shell/lesson-runner-lib.sh`

- [ ] **Step 1: Create the public entrypoint `shell/lesson`**

Responsibilities:
- accept topic argument like `lesson 01-files`
- resolve topic path under `~/linux-lab/tasks`
- load the shared library
- start the runner loop

Implementation shape:

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/lesson-runner-lib.sh"

main() {
  local topic="${1:-}"
  if [ -z "$topic" ]; then
    linux_lab_lesson_usage
    exit 1
  fi

  linux_lab_run_lesson "$HOME/linux-lab/tasks/$topic"
}

main "$@"
```

- [ ] **Step 2: Create parser helpers in `shell/lesson-runner-lib.sh`**

Implement functions for:
- reading `runner.txt`
- splitting intro lines
- splitting scenario into step blocks
- extracting field values

Functions to define:

```bash
linux_lab_runner_file() { ... }
linux_lab_load_runner() { ... }
linux_lab_step_ids() { ... }
linux_lab_step_value() { ... }
```

Expected:
- parser works with plain Bash and simple text files

- [ ] **Step 3: Add the main lesson loop**

The loop should:
- show title and intro
- show one step at a time
- read user input
- route built-in actions vs learner commands

Built-in actions:
- `hint`
- `help`
- `explain`
- `check`
- `skip`
- `quit`

Expected:
- runner can walk a user through a scenario without leaving the shell

- [ ] **Step 4: Add screen rendering helpers**

Show:
- current topic
- step number and total
- current task
- available actions

Keep output simple and SSH-friendly. Avoid full-screen curses behavior.

Expected:
- no heavy TUI dependency
- output is readable in a normal terminal

## Task 3: Implement Hybrid Step Validation

**Files:**
- Modify: `shell/lesson-runner-lib.sh`

- [ ] **Step 1: Implement guided command checks**

For `MODE: guided`, validate:
- command string contains the expected command family
- optional regex matches the learner input

Possible check helpers:

```bash
linux_lab_check_command_contains() { ... }
linux_lab_check_command_regex() { ... }
```

Expected:
- early training steps can insist on `pwd`, `ls`, `find`, `mv`, etc.

- [ ] **Step 2: Implement flexible result checks**

For `MODE: flex`, allow alternative commands if the expected result exists.

Version one should support result checks such as:
- file exists
- directory exists
- file moved into target directory
- count of matches

Possible check types:

```text
CHECK_TYPE: path_exists
CHECK_PATH: organized/docs

CHECK_TYPE: moved_matches
CHECK_GLOB: organized/docs/*.txt
CHECK_MIN_COUNT: 1
```

Expected:
- later steps can reward correct outcomes, not just exact command strings

- [ ] **Step 3: Implement feedback messages**

Feedback should distinguish:
- wrong command family
- almost right but missing argument
- correct result through alternative path
- incomplete result

Expected:
- learner sees why the step is not accepted
- runner remains educational, not punitive

## Task 4: Add Help And Explanation Actions

**Files:**
- Modify: `shell/lesson-runner-lib.sh`
- Reuse: `shell/linux-lab.sh`

- [ ] **Step 1: Wire `help` action to the existing help layer**

When a step contains `HELP_TOPIC`, runner should call the same help chain used by Linux Lab:
- `tldr`
- `hman`
- local fallback

Expected:
- runner reuses the layered Russian help system

- [ ] **Step 2: Wire `hint` and `explain` actions to scenario content**

Behavior:
- `hint` prints a short nudge
- `explain` prints the fuller explanation from the scenario

Expected:
- help is available without revealing the full answer immediately

- [ ] **Step 3: Add `check` behavior**

For the current step, `check` should:
- rerun the step validation
- show a success or failure message
- not advance automatically unless the step passes

Expected:
- learner can request feedback without guessing whether progress was saved

## Task 5: Create The First Scenario For `01-files`

**Files:**
- Create: `linux-lab/tasks/01-files/runner.txt`

- [ ] **Step 1: Add intro and command context**

Include:
- where the learner is working
- what basic commands matter for this lesson
- how to ask for `hint`, `help`, `explain`, `check`

Expected:
- the scenario feels like a guided lesson, not just a hidden checklist

- [ ] **Step 2: Encode the warmup steps**

Cover:
- `pwd`
- `ls -a`
- `find` for `.log`
- checking the heaviest directory

Use `MODE: guided` for the first command-focused steps.

- [ ] **Step 3: Encode the directory creation and move steps**

Cover:
- creating `organized/docs`, `organized/images`, `organized/logs`, `organized/archive`
- moving `.txt` files into `organized/docs`

Use:
- `guided` where command training matters
- `flex` where result-based acceptance is more helpful

- [ ] **Step 4: Add hints and explanations that teach instead of spoil**

Examples:
- hint can explain what `mv` does without giving the whole command
- explain can clarify why `find` and `mv` are paired here

Expected:
- novice learner is unblocked without losing the chance to think

## Task 6: Integrate Runner Into Shell UX

**Files:**
- Modify: `shell/linux-lab.sh`
- Modify: `shell/lab-welcome`

- [ ] **Step 1: Add a `lesson` entrypoint to shell setup**

Make sure the installed shell environment exposes:
- `lesson 01-files`

If `shell/lesson` is installed into `~/.local/bin`, prefer that path.

Expected:
- runner can be launched directly from the shell

- [ ] **Step 2: Add runner launch path to `menu`**

Add a new item such as:
- "Запустить lesson runner"

Flow:
- show available topics
- ask for topic
- run `lesson <topic>`

Expected:
- new learners can discover the runner from the existing menu

- [ ] **Step 3: Mention runner in the welcome message**

Add one short mention in `shell/lab-welcome` so newcomers see:
- classic path through `lesson.md` and `practice.md`
- interactive path through `lesson <topic>`

Expected:
- runner is discoverable without overwhelming the welcome screen

## Task 7: Update Installer And Documentation

**Files:**
- Modify: `install.sh`
- Modify: `README.md`
- Modify: `docs/install.md`
- Modify: `docs/content-guide.md`

- [ ] **Step 1: Install the runner files**

Update `install.sh` to place:
- `shell/lesson`
- `shell/lesson-runner-lib.sh`

into user-visible installed locations.

Expected:
- lesson runner works after `install.sh` and a new shell session

- [ ] **Step 2: Document the learner-facing usage**

In `README.md`, explain:
- standard mode via markdown files
- interactive mode via `lesson 01-files`

Expected:
- public repo makes the new feature understandable at the top level

- [ ] **Step 3: Document authoring rules**

In `docs/content-guide.md`, explain:
- where `runner.txt` lives
- how to add steps
- how to write hints and explanations
- when to use `guided` vs `flex`

Expected:
- contributors can expand runner coverage topic by topic

- [ ] **Step 4: Document installation details**

In `docs/install.md`, note:
- runner files are installed with the shell layer
- `lesson` is available after a new shell session

Expected:
- no mismatch between installer behavior and docs

## Task 8: Verify Runner Behavior

**Files:**
- Review: `shell/lesson`
- Review: `shell/lesson-runner-lib.sh`
- Review: `linux-lab/tasks/01-files/runner.txt`

- [ ] **Step 1: Verify shell syntax**

Run:

```powershell
& 'C:\Program Files\Git\bin\bash.exe' -n shell/lesson
& 'C:\Program Files\Git\bin\bash.exe' -n shell/lesson-runner-lib.sh
& 'C:\Program Files\Git\bin\bash.exe' -n shell/linux-lab.sh
```

Expected:
- no syntax errors

- [ ] **Step 2: Smoke-test scenario loading**

Run:

```powershell
& 'C:\Program Files\Git\bin\bash.exe' -lc "export HOME=\"$PWD\"; mkdir -p \"$HOME/linux-lab/tasks/01-files\"; cp linux-lab/tasks/01-files/runner.txt \"$HOME/linux-lab/tasks/01-files/runner.txt\"; . ./shell/lesson-runner-lib.sh; linux_lab_run_lesson \"$HOME/linux-lab/tasks/01-files\""
```

Expected:
- title, intro, and first step render correctly

- [ ] **Step 3: Verify runner docs stay in Russian**

Run:

```powershell
rg -n "Goal:|Architecture:|Tech Stack:|For agentic workers|TODO|TBD|implement later" README.md docs shell linux-lab
```

Expected:
- no planning boilerplate in user-facing runner files

- [ ] **Step 4: Verify the first topic is actually editable through text**

Check manually that changing only `linux-lab/tasks/01-files/runner.txt` is enough to:
- change a task label
- change a hint
- change an explanation

Expected:
- content contributors do not need to modify the runner engine for normal text updates

## Self-Review

Spec coverage check:
- general runner engine is covered
- topic-local text scenario is covered
- hybrid validation is covered
- launch via command and `menu` is covered
- first scenario for `01-files` is covered
- contributor editability is covered

Placeholder check:
- no `TODO`
- no `TBD`
- no “implement later”

Consistency check:
- markdown lessons remain source of truth
- runner is an additional mode, not a replacement
- scenario content stays next to the topic it belongs to

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-05-22-linux-lab-lesson-runner-implementation.md`. Two execution options:

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

Which approach?

