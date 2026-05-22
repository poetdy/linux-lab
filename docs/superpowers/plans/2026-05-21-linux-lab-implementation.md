# Linux Lab Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Russian-language Linux training ground in `~/linux-lab/tasks` with lessons, hands-on practice, troubleshooting tasks, and verification scripts across eight topics.

**Architecture:** The implementation uses a consistent per-topic file layout inside `tasks/`, plus shared preparation artifacts under existing lab directories such as `sandbox/`, `broken/`, `services/`, and `scripts/`. Content is shell-first, file-based, and safe to rerun, with learner-facing materials in Russian and topic checks implemented through simple `verify.sh` and optional `setup.sh` scripts.

**Tech Stack:** Debian shell environment, Markdown, Bash, standard Linux userland tools, OpenSSH, systemd/journalctl, Docker when available

---

## File Structure

### Local planning documents

- Create: `docs/superpowers/plans/2026-05-21-linux-lab-implementation.md`
- Existing reference: `docs/superpowers/specs/2026-05-21-linux-lab-design.md`

### Server content roots

- Modify: `~/linux-lab/tasks/01-files/`
- Modify: `~/linux-lab/tasks/02-permissions/`
- Modify: `~/linux-lab/tasks/03-processes/`
- Modify: `~/linux-lab/tasks/04-network/`
- Modify: `~/linux-lab/tasks/05-logs/`
- Modify: `~/linux-lab/tasks/06-ssh/`
- Modify: `~/linux-lab/tasks/07-bash/`
- Modify: `~/linux-lab/tasks/08-docker/`
- Modify when needed: `~/linux-lab/sandbox/`
- Modify when needed: `~/linux-lab/broken/`
- Modify when needed: `~/linux-lab/services/`
- Modify when needed: `~/linux-lab/scripts/`

### Standard per-topic deliverables

Each topic should end with:

- `lesson.md`
- `practice.md`
- `checks.md`
- `verify.sh`
- `setup.sh` only if the topic needs prepared state

## Task 1: Prepare Shared Authoring Pattern And Lab Scaffolding

**Files:**
- Create or modify: `~/linux-lab/scripts/`
- Modify when needed: `~/linux-lab/sandbox/`
- Modify when needed: `~/linux-lab/broken/`
- Modify when needed: `~/linux-lab/services/`

- [ ] **Step 1: Inspect current writable state before making changes**

Run:

```bash
cd ~/linux-lab
find tasks sandbox broken services scripts -maxdepth 2 \( -type f -o -type d \) | sort
```

Expected:
- existing topic directories are present
- support directories exist and can hold scenario files

- [ ] **Step 2: Define a repeatable topic file template in notes for internal reuse**

Create a short internal reference file such as:

```text
Тема:
- lesson.md: цель, команды, мини-примеры, типовые ошибки
- practice.md: разогрев, пошаговая практика, мини-кейс
- checks.md: признаки успеха, контрольные вопросы, что проверить
- verify.sh: автоматическая проверка результата
- setup.sh: только если теме нужна подготовка среды
```

Save it to:

```bash
mkdir -p ~/linux-lab/notes
cat > ~/linux-lab/notes/topic-template.txt <<'EOF'
Тема:
- lesson.md: цель, команды, мини-примеры, типовые ошибки
- practice.md: разогрев, пошаговая практика, мини-кейс
- checks.md: признаки успеха, контрольные вопросы, что проверить
- verify.sh: автоматическая проверка результата
- setup.sh: только если теме нужна подготовка среды
EOF
```

- [ ] **Step 3: Create shared lab subdirectories for prepared scenarios**

Run:

```bash
mkdir -p ~/linux-lab/sandbox/files-lab
mkdir -p ~/linux-lab/sandbox/permissions-lab
mkdir -p ~/linux-lab/services/process-lab
mkdir -p ~/linux-lab/services/log-lab
mkdir -p ~/linux-lab/broken/network-lab
mkdir -p ~/linux-lab/broken/ssh-lab
mkdir -p ~/linux-lab/broken/docker-lab
```

Expected:
- all directories are created or already exist
- rerunning the command does not break anything

- [ ] **Step 4: Verify shared scaffolding exists**

Run:

```bash
find ~/linux-lab/sandbox ~/linux-lab/broken ~/linux-lab/services -maxdepth 2 -type d | sort
```

Expected:
- the new scenario directories are listed

## Task 2: Create Topic 01 Files Lesson Pack

**Files:**
- Create: `~/linux-lab/tasks/01-files/lesson.md`
- Create: `~/linux-lab/tasks/01-files/practice.md`
- Create: `~/linux-lab/tasks/01-files/checks.md`
- Create: `~/linux-lab/tasks/01-files/setup.sh`
- Create: `~/linux-lab/tasks/01-files/verify.sh`

- [ ] **Step 1: Write `lesson.md` for files and directories**

Content should include:
- navigation commands
- listing and hidden files
- copy, move, remove
- `find`, `du`, `tar`
- Russian examples
- typical mistakes such as deleting from the wrong directory

- [ ] **Step 2: Write `practice.md` with hands-on drills**

Content should include:
- create a tree of directories and files
- sort files by extension
- find the largest directory
- archive selected files
- final mini-case restoring order in a messy workspace

- [ ] **Step 3: Write `checks.md` with self-check criteria**

Checks should confirm:
- required directories exist
- required files moved to correct places
- archive contains expected content
- learner can explain why a command was used

- [ ] **Step 4: Write `setup.sh` to create a safe messy workspace**

Script responsibilities:
- reset `~/linux-lab/sandbox/files-lab`
- create mixed file types and nested folders
- leave a clear “broken but safe” state for exercises

- [ ] **Step 5: Write `verify.sh` to validate results**

Script responsibilities:
- check final directory structure
- check archive presence
- print Russian pass/fail messages

- [ ] **Step 6: Run setup and verify basic script behavior**

Run:

```bash
bash ~/linux-lab/tasks/01-files/setup.sh
bash ~/linux-lab/tasks/01-files/verify.sh
```

Expected:
- setup completes without errors
- verify reports incomplete state before the learner solves tasks or reports success only when the setup intentionally matches checks

## Task 3: Create Topic 02 Permissions Lesson Pack

**Files:**
- Create: `~/linux-lab/tasks/02-permissions/lesson.md`
- Create: `~/linux-lab/tasks/02-permissions/practice.md`
- Create: `~/linux-lab/tasks/02-permissions/checks.md`
- Create: `~/linux-lab/tasks/02-permissions/setup.sh`
- Create: `~/linux-lab/tasks/02-permissions/verify.sh`

- [ ] **Step 1: Write the permissions lesson in Russian**

Cover:
- ownership
- `chmod`
- `chown`
- symbolic and octal modes
- directory execute bit
- `umask`

- [ ] **Step 2: Write practical drills**

Exercises should include:
- fix a script that is not executable
- repair access to a shared folder
- explain why entering a directory fails
- adjust group-readable project files

- [ ] **Step 3: Write checks**

Checks should validate:
- target files have exact expected modes
- correct owner or group is applied where realistic
- learner can confirm why a previous state failed

- [ ] **Step 4: Write `setup.sh`**

Setup should:
- create `~/linux-lab/sandbox/permissions-lab`
- create files with wrong modes
- create at least one directory with traversal issues

- [ ] **Step 5: Write `verify.sh`**

Verification should:
- use `stat` or equivalent checks
- print actionable Russian hints for mismatches

- [ ] **Step 6: Run setup and verify**

Run:

```bash
bash ~/linux-lab/tasks/02-permissions/setup.sh
bash ~/linux-lab/tasks/02-permissions/verify.sh
```

Expected:
- scripts run without syntax errors

## Task 4: Create Topic 03 Processes Lesson Pack

**Files:**
- Create: `~/linux-lab/tasks/03-processes/lesson.md`
- Create: `~/linux-lab/tasks/03-processes/practice.md`
- Create: `~/linux-lab/tasks/03-processes/checks.md`
- Create: `~/linux-lab/tasks/03-processes/setup.sh`
- Create: `~/linux-lab/tasks/03-processes/verify.sh`

- [ ] **Step 1: Write the processes lesson**

Cover:
- `ps`
- `top`
- `kill`
- `pkill`
- foreground/background jobs
- `systemctl status`
- restart loops

- [ ] **Step 2: Write practice scenarios**

Exercises should include:
- identify the correct PID
- stop a stuck process
- inspect a service that restarts
- distinguish process inspection from service inspection

- [ ] **Step 3: Write checks**

Checks should look for:
- a stopped or running target process state
- a corrected service file or command if one is part of the exercise
- evidence that the learner reached the intended state

- [ ] **Step 4: Write `setup.sh`**

Setup should:
- create a simple long-running process scenario
- stage a broken service example inside `~/linux-lab/services/process-lab`

- [ ] **Step 5: Write `verify.sh`**

Verification should:
- confirm process or service state
- print Russian diagnostics

- [ ] **Step 6: Run setup and verify**

Run:

```bash
bash ~/linux-lab/tasks/03-processes/setup.sh
bash ~/linux-lab/tasks/03-processes/verify.sh
```

Expected:
- scripts run cleanly even if some checks intentionally fail before learner action

## Task 5: Create Topic 04 Network Lesson Pack

**Files:**
- Create: `~/linux-lab/tasks/04-network/lesson.md`
- Create: `~/linux-lab/tasks/04-network/practice.md`
- Create: `~/linux-lab/tasks/04-network/checks.md`
- Create: `~/linux-lab/tasks/04-network/setup.sh`
- Create: `~/linux-lab/tasks/04-network/verify.sh`

- [ ] **Step 1: Write the network lesson**

Cover:
- `ip addr`
- `ip route`
- `ss -tulpn`
- `ping`
- `curl`
- service reachability basics

- [ ] **Step 2: Write network drills**

Exercises should include:
- identify server addresses
- check which port a service uses
- compare timeout, refusal, and resolution failures
- inspect a local HTTP listener

- [ ] **Step 3: Write checks**

Checks should validate:
- learner discovered the intended endpoint
- target listener is reachable
- expected output or response is returned

- [ ] **Step 4: Write `setup.sh`**

Setup should:
- prepare a simple reachable local service or a reference target
- place any broken hints under `~/linux-lab/broken/network-lab`

- [ ] **Step 5: Write `verify.sh`**

Verification should:
- test a target port or HTTP response
- print clear Russian results

- [ ] **Step 6: Run setup and verify**

Run:

```bash
bash ~/linux-lab/tasks/04-network/setup.sh
bash ~/linux-lab/tasks/04-network/verify.sh
```

Expected:
- scripts complete without syntax errors

## Task 6: Create Topic 05 Logs Lesson Pack

**Files:**
- Create: `~/linux-lab/tasks/05-logs/lesson.md`
- Create: `~/linux-lab/tasks/05-logs/practice.md`
- Create: `~/linux-lab/tasks/05-logs/checks.md`
- Create: `~/linux-lab/tasks/05-logs/setup.sh`
- Create: `~/linux-lab/tasks/05-logs/verify.sh`

- [ ] **Step 1: Write the logs lesson**

Cover:
- `tail`
- `less`
- `grep`
- `journalctl`
- time-based and unit-based filtering

- [ ] **Step 2: Write practice scenarios**

Exercises should include:
- find the latest error
- extract only failed requests
- follow a log while reproducing a problem
- compare healthy and broken log lines

- [ ] **Step 3: Write checks**

Checks should validate:
- learner identified the right error signature
- filtered output points to the intended cause

- [ ] **Step 4: Write `setup.sh`**

Setup should:
- place prepared text logs under `~/linux-lab/services/log-lab`
- optionally stage a service/unit to inspect if the environment supports it

- [ ] **Step 5: Write `verify.sh`**

Verification should:
- inspect learner-produced result files or required conclusions
- print Russian guidance on mismatch

- [ ] **Step 6: Run setup and verify**

Run:

```bash
bash ~/linux-lab/tasks/05-logs/setup.sh
bash ~/linux-lab/tasks/05-logs/verify.sh
```

Expected:
- setup and verify run cleanly

## Task 7: Create Topic 06 SSH Lesson Pack

**Files:**
- Create: `~/linux-lab/tasks/06-ssh/lesson.md`
- Create: `~/linux-lab/tasks/06-ssh/practice.md`
- Create: `~/linux-lab/tasks/06-ssh/checks.md`
- Create: `~/linux-lab/tasks/06-ssh/setup.sh`
- Create: `~/linux-lab/tasks/06-ssh/verify.sh`

- [ ] **Step 1: Write the SSH lesson**

Cover:
- `ssh`
- key pairs
- `authorized_keys`
- `~/.ssh/config`
- host key checks
- common permission problems

- [ ] **Step 2: Write practical drills**

Exercises should include:
- generate a key pair
- install a public key
- define a host alias
- diagnose `Permission denied`
- explain host key mismatch warnings

- [ ] **Step 3: Write checks**

Checks should validate:
- expected config entries exist in a lab-specific sample file
- key permissions match SSH expectations
- learner produced the intended repair

- [ ] **Step 4: Write `setup.sh`**

Setup should:
- create a fake or local safe SSH config lab under `~/linux-lab/broken/ssh-lab`
- avoid breaking the learner’s real SSH access

- [ ] **Step 5: Write `verify.sh`**

Verification should:
- inspect sample files in the lab directory
- never touch the user’s real `~/.ssh/config`

- [ ] **Step 6: Run setup and verify**

Run:

```bash
bash ~/linux-lab/tasks/06-ssh/setup.sh
bash ~/linux-lab/tasks/06-ssh/verify.sh
```

Expected:
- safe lab-only scripts

## Task 8: Create Topic 07 Bash Lesson Pack

**Files:**
- Create: `~/linux-lab/tasks/07-bash/lesson.md`
- Create: `~/linux-lab/tasks/07-bash/practice.md`
- Create: `~/linux-lab/tasks/07-bash/checks.md`
- Create: `~/linux-lab/tasks/07-bash/setup.sh`
- Create: `~/linux-lab/tasks/07-bash/verify.sh`

- [ ] **Step 1: Write the Bash lesson**

Cover:
- pipes
- redirection
- `grep`
- `sed`
- `awk`
- `xargs`
- command substitution

- [ ] **Step 2: Write drills and mini-case**

Exercises should include:
- filter useful lines from noisy files
- convert raw output to a compact report
- rename or process multiple files
- combine commands into an operational one-liner

- [ ] **Step 3: Write checks**

Checks should validate:
- expected output file contents
- correct line counts or extracted values

- [ ] **Step 4: Write `setup.sh`**

Setup should:
- place source text and metadata files under a lab directory
- guarantee rerunnable input state

- [ ] **Step 5: Write `verify.sh`**

Verification should:
- compare expected and actual derived outputs
- keep messages in Russian

- [ ] **Step 6: Run setup and verify**

Run:

```bash
bash ~/linux-lab/tasks/07-bash/setup.sh
bash ~/linux-lab/tasks/07-bash/verify.sh
```

Expected:
- scripts run successfully

## Task 9: Create Topic 08 Docker Lesson Pack

**Files:**
- Create: `~/linux-lab/tasks/08-docker/lesson.md`
- Create: `~/linux-lab/tasks/08-docker/practice.md`
- Create: `~/linux-lab/tasks/08-docker/checks.md`
- Create: `~/linux-lab/tasks/08-docker/setup.sh`
- Create: `~/linux-lab/tasks/08-docker/verify.sh`

- [ ] **Step 1: Inspect whether Docker is available before relying on it**

Run:

```bash
command -v docker
docker --version
```

Expected:
- Docker is installed, or the topic is written with explicit fallback notes if unavailable

- [ ] **Step 2: Write the Docker lesson**

Cover:
- images
- containers
- logs
- `docker exec`
- ports
- volumes
- restart behavior

- [ ] **Step 3: Write Docker practice**

Exercises should include:
- run a container
- inspect logs
- identify why a container exited
- map a port
- preserve data through a volume

- [ ] **Step 4: Write checks**

Checks should validate:
- a named container exists or a fallback artifact was created
- expected port mapping or volume result is visible

- [ ] **Step 5: Write `setup.sh` and `verify.sh`**

Implementation should:
- prepare any sample compose or run commands in a lab-safe directory
- verify outcomes in Russian
- degrade gracefully if Docker is unavailable

- [ ] **Step 6: Run setup and verify**

Run:

```bash
bash ~/linux-lab/tasks/08-docker/setup.sh
bash ~/linux-lab/tasks/08-docker/verify.sh
```

Expected:
- either successful Docker-backed checks or clear fallback behavior

## Task 10: Final Consistency And Smoke Verification

**Files:**
- Review: `~/linux-lab/tasks/01-files/*`
- Review: `~/linux-lab/tasks/02-permissions/*`
- Review: `~/linux-lab/tasks/03-processes/*`
- Review: `~/linux-lab/tasks/04-network/*`
- Review: `~/linux-lab/tasks/05-logs/*`
- Review: `~/linux-lab/tasks/06-ssh/*`
- Review: `~/linux-lab/tasks/07-bash/*`
- Review: `~/linux-lab/tasks/08-docker/*`

- [ ] **Step 1: Verify every topic has the required files**

Run:

```bash
cd ~/linux-lab/tasks
for d in 01-files 02-permissions 03-processes 04-network 05-logs 06-ssh 07-bash 08-docker; do
  echo "== $d =="
  find "$d" -maxdepth 1 -type f | sort
done
```

Expected:
- all topics contain `lesson.md`, `practice.md`, `checks.md`, `verify.sh`
- `setup.sh` exists where needed

- [ ] **Step 2: Verify learner-facing language is Russian**

Run:

```bash
cd ~/linux-lab/tasks
grep -RIn "Goal:|Architecture:|Tech Stack:" .
```

Expected:
- no planning-language boilerplate appears in learner-facing files

- [ ] **Step 3: Run all verification scripts**

Run:

```bash
cd ~/linux-lab/tasks
for d in 01-files 02-permissions 03-processes 04-network 05-logs 06-ssh 07-bash 08-docker; do
  echo "== verify $d =="
  bash "$d/verify.sh" || true
done
```

Expected:
- no syntax errors
- failures, if any, are intentional learning-state failures with clear Russian messages

- [ ] **Step 4: Check shell syntax for all setup and verify scripts**

Run:

```bash
cd ~/linux-lab/tasks
find . \( -name setup.sh -o -name verify.sh \) -print0 | xargs -0 -n1 bash -n
```

Expected:
- no syntax errors

- [ ] **Step 5: Document any environment-specific limitations**

Examples:
- Docker unavailable
- some systemd behavior limited in containerized environments
- optional tools missing

Save notes either in the root `README.md` or in the affected topic lesson files.

## Self-Review

Spec coverage check:
- all eight topics are covered
- Russian learner-facing content is explicitly required
- hands-on drills, mini-cases, and checks are included in every topic
- shared lab directories are used intentionally

Placeholder check:
- no `TODO`
- no `TBD`
- no “implement later”

Consistency check:
- all topics use the same file layout
- all verification references are topic-local and safe to rerun
- SSH topic is isolated from real user access files

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-05-21-linux-lab-implementation.md`. Two execution options:

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

Which approach?
