# Linux Lab Monorepo Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the first public Linux Lab monorepo locally, with Russian documentation, the current lesson content, shell onboarding scripts, and a Debian installation script.

**Architecture:** The repository is content-first: `linux-lab/` holds the educational environment, `shell/` holds onboarding and helper shell logic, and `install.sh` deploys the environment onto a Debian system. Public-facing docs remain in Russian so the repository is both contributor-friendly and aligned with the training experience itself.

**Tech Stack:** Markdown, Bash, Debian shell environment, PowerShell for local inspection, SSH for extracting current server content

---

## File Structure

### Existing planning references

- Existing reference: `docs/superpowers/specs/2026-05-22-linux-lab-monorepo-design.md`
- Existing reference: `docs/superpowers/specs/2026-05-21-linux-lab-design.md`

### New repository root files

- Create: `README.md`
- Create: `LICENSE`
- Create: `CONTRIBUTING.md`
- Create: `install.sh`
- Create: `.gitignore`

### Repository content directories

- Create: `linux-lab/`
- Create: `linux-lab/README.md`
- Create: `linux-lab/tasks/`
- Create: `linux-lab/sandbox/`
- Create: `linux-lab/broken/`
- Create: `linux-lab/services/`
- Create: `linux-lab/notes/`

### Shell integration files

- Create: `shell/lab-welcome`
- Create: `shell/linux-lab.sh`

### Maintainer docs

- Create: `docs/install.md`
- Create: `docs/content-guide.md`

## Task 1: Create The Monorepo Skeleton

**Files:**
- Create: `README.md`
- Create: `LICENSE`
- Create: `CONTRIBUTING.md`
- Create: `install.sh`
- Create: `.gitignore`
- Create: `linux-lab/README.md`
- Create: `linux-lab/tasks/.gitkeep`
- Create: `linux-lab/sandbox/.gitkeep`
- Create: `linux-lab/broken/.gitkeep`
- Create: `linux-lab/services/.gitkeep`
- Create: `linux-lab/notes/.gitkeep`
- Create: `shell/lab-welcome`
- Create: `shell/linux-lab.sh`
- Create: `docs/install.md`
- Create: `docs/content-guide.md`

- [ ] **Step 1: Create the directory skeleton**

Run:

```powershell
New-Item -ItemType Directory -Force linux-lab
New-Item -ItemType Directory -Force linux-lab\tasks
New-Item -ItemType Directory -Force linux-lab\sandbox
New-Item -ItemType Directory -Force linux-lab\broken
New-Item -ItemType Directory -Force linux-lab\services
New-Item -ItemType Directory -Force linux-lab\notes
New-Item -ItemType Directory -Force shell
New-Item -ItemType Directory -Force docs
```

Expected:
- all top-level repository directories exist

- [ ] **Step 2: Add placeholder keep files for empty directories**

Create:

```text
linux-lab/tasks/.gitkeep
linux-lab/sandbox/.gitkeep
linux-lab/broken/.gitkeep
linux-lab/services/.gitkeep
linux-lab/notes/.gitkeep
```

Expected:
- empty directories stay trackable in git

- [ ] **Step 3: Add `.gitignore`**

Content should ignore:

```gitignore
.DS_Store
Thumbs.db
*.swp
*.tmp
*.bak
```

- [ ] **Step 4: Verify skeleton exists**

Run:

```powershell
Get-ChildItem -Recurse -Force linux-lab,shell,docs
```

Expected:
- the new repository structure is visible

## Task 2: Write The Public Root README

**Files:**
- Create: `README.md`

- [ ] **Step 1: Write the project introduction in Russian**

The README should explain:
- what Linux Lab is
- who it is for
- why the project exists
- that it is a practical shell-first training ground

- [ ] **Step 2: Add the topic list**

Include all current topics:
- files
- permissions
- processes
- network
- logs
- ssh
- bash
- docker

- [ ] **Step 3: Add install instructions**

The initial README install path should describe:
- clone repository
- run `install.sh`
- reopen shell or reconnect

- [ ] **Step 4: Add contribution entry points**

Explain:
- where lessons live
- how to improve a topic
- where maintainer docs are

- [ ] **Step 5: Review readability**

Check that the README:
- is fully in Russian
- clearly prioritizes content over deployment
- makes the repository discoverable for outside contributors

## Task 3: Write Contributor And Maintainer Documentation

**Files:**
- Create: `CONTRIBUTING.md`
- Create: `docs/install.md`
- Create: `docs/content-guide.md`

- [ ] **Step 1: Write `CONTRIBUTING.md` in Russian**

It should cover:
- how to propose lesson edits
- expected lesson structure
- safe contribution boundaries
- tone and style for educational content

- [ ] **Step 2: Write `docs/content-guide.md`**

It should define:
- required files per topic
- how to write `lesson.md`, `practice.md`, `checks.md`
- how `setup.sh` and `verify.sh` should behave
- why learner-facing content must stay in Russian

- [ ] **Step 3: Write `docs/install.md`**

It should explain:
- supported Debian target
- what `install.sh` does
- what files it places
- how to rerun install safely

- [ ] **Step 4: Verify consistency across docs**

Check:
- topic file names are consistent everywhere
- all docs are in Russian
- no contradictions between public README and maintainer docs

## Task 4: Export Current Linux Lab Content Into `linux-lab/`

**Files:**
- Create: `linux-lab/README.md`
- Create: `linux-lab/tasks/01-files/*`
- Create: `linux-lab/tasks/02-permissions/*`
- Create: `linux-lab/tasks/03-processes/*`
- Create: `linux-lab/tasks/04-network/*`
- Create: `linux-lab/tasks/05-logs/*`
- Create: `linux-lab/tasks/06-ssh/*`
- Create: `linux-lab/tasks/07-bash/*`
- Create: `linux-lab/tasks/08-docker/*`
- Create: `linux-lab/notes/topic-template.txt`

- [ ] **Step 1: Read back the current server content to use as source of truth**

Run:

```powershell
ssh lunix "cd ~/linux-lab && find tasks notes -maxdepth 2 -type f | sort"
```

Expected:
- all current lesson files are listed

- [ ] **Step 2: Copy the root Linux Lab README into `linux-lab/README.md`**

The copied file should preserve:
- friendly onboarding
- learning flow
- topic route
- helper commands

- [ ] **Step 3: Copy all topic files into the repo**

Each topic directory should contain:
- `lesson.md`
- `practice.md`
- `checks.md`
- `setup.sh`
- `verify.sh`

- [ ] **Step 4: Copy shared notes**

At minimum, copy:

```text
linux-lab/notes/topic-template.txt
```

- [ ] **Step 5: Verify repository content completeness**

Run:

```powershell
Get-ChildItem -Recurse linux-lab\tasks
```

Expected:
- all eight topic directories exist with full file sets

## Task 5: Capture Shell Experience Files In The Repo

**Files:**
- Create: `shell/lab-welcome`
- Create: `shell/linux-lab.sh`

- [ ] **Step 1: Export the current `lab-welcome` script from the server**

It should preserve:
- friendly SSH onboarding
- mention of Данилов Юрий (`poet_dy`)
- training flow
- helper command summary

- [ ] **Step 2: Build `shell/linux-lab.sh`**

This file should contain:
- aliases
- functions `h`, `hman`, `hs`, `lab`
- function `menu`
- SSH-only welcome trigger

- [ ] **Step 3: Remove user-specific assumptions where needed**

The repo version should be reusable:
- use `$HOME`
- avoid hardcoded home paths
- keep training paths relative to `~/linux-lab`

- [ ] **Step 4: Verify shell file syntax**

Run:

```powershell
ssh lunix "bash -n ~/.local/bin/lab-welcome && bash -n ~/.bashrc"
```

Expected:
- no syntax errors in the source references

## Task 6: Write The Debian Installer

**Files:**
- Create: `install.sh`

- [ ] **Step 1: Define installer behavior**

The installer should:
- run on Debian
- install required packages
- copy `linux-lab/` into the target home
- install shell helper files under `~/.local/bin/`
- ensure shell helpers are sourced safely

- [ ] **Step 2: Write install preflight checks**

Checks should validate:
- running on Linux
- required commands available or installable
- repository content directories exist

- [ ] **Step 3: Write file deployment logic**

The installer should:
- create `~/linux-lab`
- sync `linux-lab/` content
- create `~/.local/bin`
- place `lab-welcome`
- place or source `linux-lab.sh`

- [ ] **Step 4: Write idempotent shell integration**

The installer should add a clearly marked block in `.bashrc` only once.

- [ ] **Step 5: Write installer status output in Russian**

The script should print:
- what it is checking
- what it is installing
- where Linux Lab was placed
- what to do next

- [ ] **Step 6: Verify shell syntax**

Run:

```powershell
bash -n install.sh
```

Expected:
- no syntax errors

## Task 7: Validate Content And Installer Layout

**Files:**
- Review: `README.md`
- Review: `CONTRIBUTING.md`
- Review: `docs/install.md`
- Review: `docs/content-guide.md`
- Review: `linux-lab/**/*`
- Review: `shell/*`
- Review: `install.sh`

- [ ] **Step 1: Verify all written docs are in Russian**

Run:

```powershell
rg -n "Goal:|Architecture:|Tech Stack:|For agentic workers" README.md CONTRIBUTING.md docs shell linux-lab
```

Expected:
- no planning boilerplate is present in repository files

- [ ] **Step 2: Verify lesson file coverage**

Run:

```powershell
Get-ChildItem linux-lab\\tasks -Directory | ForEach-Object {
  $_.FullName
  Get-ChildItem $_.FullName -File | Select-Object Name
}
```

Expected:
- each topic contains the expected files

- [ ] **Step 3: Verify installer references correct paths**

Check manually that:
- source paths point into repo directories
- target paths point into `$HOME`
- shell files refer to `~/linux-lab`

- [ ] **Step 4: Verify script syntax**

Run:

```powershell
bash -n install.sh
```

Expected:
- no syntax errors

## Task 8: Prepare The First Publishable Baseline

**Files:**
- Review: all repository files

- [ ] **Step 1: Ensure the repository looks coherent from the top level**

A new visitor should be able to understand:
- what the project is
- how to install it
- where lessons live
- how to contribute

- [ ] **Step 2: Check that the install story is honest**

If something is not yet automated, state it plainly in docs instead of implying full product polish.

- [ ] **Step 3: List future work explicitly**

Document later directions such as:
- web terminal
- SSH provisioning
- time-limited student users
- reset automation

- [ ] **Step 4: Final local review**

Run:

```powershell
Get-ChildItem -Recurse -Force
```

Expected:
- repository structure matches the monorepo design

## Self-Review

Spec coverage check:
- monorepo structure is covered
- content-first repo shape is covered
- Russian-only documentation policy is covered
- installer responsibilities are covered
- shell onboarding capture is covered

Placeholder check:
- no `TODO`
- no `TBD`
- no “implement later”

Consistency check:
- `linux-lab/` is always the educational root
- `shell/` only holds reusable shell scripts
- root docs stay distinct from learner-facing docs inside `linux-lab/`

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-05-22-linux-lab-monorepo-implementation.md`. Two execution options:

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

Which approach?
