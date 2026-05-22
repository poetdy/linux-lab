# Linux Lab Monorepo Design

Date: 2026-05-22
Topic: Public monorepo for Linux Lab content and installation

## Goal

Create a public-facing monorepo for Linux Lab that:

- keeps the learning content as the primary asset
- includes the installation and environment setup logic
- is easy for outside contributors to understand and improve
- can deploy the lab onto a clean Debian-based server

## Product Direction

Linux Lab should be presented as an educational project first, not just a deploy script.

The repository should make it easy to:

- read and improve lessons
- contribute new exercises
- improve verification scripts
- install the lab on a clean machine
- later extend to SSH and web-terminal based delivery

## Monorepo Decision

The repository will be a monorepo.

This is preferred over splitting content and installation into separate repositories because:

- contributors can see the full project in one place
- lesson changes and installer changes stay in sync
- onboarding is easier for new maintainers
- the public repository looks like a complete educational product

## Core Principles

- content-first structure
- Russian learner-facing materials
- simple installation path for Debian
- safe shell-based learning environment
- consistent lesson format
- contributor-friendly documentation

## Repository Shape

Recommended top-level structure:

- `README.md`
- `LICENSE`
- `CONTRIBUTING.md`
- `install.sh`
- `linux-lab/`
- `shell/`
- `docs/`
- optional later: `ansible/`

## Top-Level Responsibilities

### `README.md`

Public landing page for the project:

- what Linux Lab is
- who it is for
- what topics exist
- how to install
- how to contribute

### `LICENSE`

Project license for public collaboration.

### `CONTRIBUTING.md`

Guide for outside contributors:

- how lessons are structured
- how to propose changes
- content style expectations
- safe change boundaries

### `install.sh`

Main installation entrypoint for a clean Debian machine.

Responsibilities:

- validate environment
- install required packages
- place Linux Lab files
- install shell helpers
- enable welcome experience

## Content Directory

### `linux-lab/`

This is the main educational content root that will be copied onto the target machine.

Recommended structure:

- `linux-lab/README.md`
- `linux-lab/tasks/`
- `linux-lab/sandbox/`
- `linux-lab/broken/`
- `linux-lab/services/`
- `linux-lab/notes/`

### `linux-lab/tasks/`

Contains the actual lessons.

Each topic should remain in its own directory:

- `01-files`
- `02-permissions`
- `03-processes`
- `04-network`
- `05-logs`
- `06-ssh`
- `07-bash`
- `08-docker`

Each topic should keep the standard structure:

- `lesson.md`
- `practice.md`
- `checks.md`
- `setup.sh`
- `verify.sh`

### `linux-lab/sandbox/`

Safe space for file manipulation exercises.

### `linux-lab/broken/`

Prepared broken scenarios for troubleshooting lessons.

### `linux-lab/services/`

Service and process related training scenarios.

### `linux-lab/notes/`

Optional notes, templates, and learner scratch material.

## Shell Directory

### `shell/`

Contains reusable shell experience files to be installed onto the target machine.

Recommended contents:

- `shell/lab-welcome`
- `shell/linux-lab.sh`

### `shell/lab-welcome`

SSH/login welcome script.

Responsibilities:

- friendly onboarding message
- reminder of training flow
- pointer to `~/linux-lab/README.md`
- mention of author and project identity

### `shell/linux-lab.sh`

Shell helpers and functions loaded from `.bashrc` or a sourced shell file.

Responsibilities:

- aliases like `ll`, `ports`, `ip4`
- helper functions `h`, `hman`, `hs`, `lab`
- `menu` command for optional menu-driven navigation

## Documentation Directory

### `docs/`

Maintainer and contributor documentation.

Recommended files:

- `docs/install.md`
- `docs/content-guide.md`
- `docs/release-notes.md` later if needed

### `docs/install.md`

Documents install behavior and supported environments.

### `docs/content-guide.md`

Defines how to write and review educational content.

Suggested sections:

- lesson tone
- required topic files
- exercise style
- verification philosophy
- Russian language policy

## Installation Model

The install path should target clean Debian first.

### Initial supported model

- Debian 12 or Debian 13
- interactive shell environment
- SSH-based usage first

### `install.sh` initial responsibilities

1. check for Debian-like environment
2. install required packages
3. create or reuse a target user context
4. copy `linux-lab/` into the target home directory
5. copy shell scripts into `~/.local/bin/`
6. install sourced shell helper file
7. ensure `.bashrc` loads Linux Lab helpers safely

### Install target

Default learner-facing install target should be:

- `~/linux-lab`

This keeps the system understandable and easy to inspect.

## Public Collaboration Goals

The repository should be legible to people who discover it organically.

That means:

- readable top-level `README.md`
- clear install instructions
- visible topic list
- easy entry point for contributors
- obvious place to improve lessons

## Language Policy

All repository documentation should be in Russian.

This includes:

- learner-facing lesson content
- onboarding text
- root `README.md`
- `CONTRIBUTING.md`
- files in `docs/`

Technical file and directory names may remain in English where that improves tooling,
navigation, or consistency, but the written documentation itself should be Russian.

## Safe Scope For First Repo Version

The first public version should include:

- existing topic content
- root repository `README.md`
- `CONTRIBUTING.md`
- `install.sh`
- shell onboarding files
- maintainer docs for content structure

It should not try to solve every future deployment mode yet.

## Deferred Features

These are important but can come later:

- web terminal deployment automation
- multi-user provisioning
- time-limited student accounts
- automated reset orchestration
- full Ansible/Packer/Terraform stack

## Risks And Mitigations

Risk:
- repo becomes deploy-heavy and content loses visibility
Mitigation:
- keep `linux-lab/tasks/` central in README and structure

Risk:
- installation logic drifts from actual content structure
Mitigation:
- keep installer in same repo and document expected paths

Risk:
- outside contributors do not know how to add lessons
Mitigation:
- add `CONTRIBUTING.md` and `docs/content-guide.md`

Risk:
- public repo feels unfinished
Mitigation:
- make first version small but complete: install, content, onboarding, contribution path

## Expected Outcome

After implementation, the monorepo should serve as:

- the canonical home of Linux Lab
- the source of truth for lesson content
- the place where contributors improve the training system
- the source from which a target machine can be provisioned with Linux Lab
