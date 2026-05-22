# VM Reset User Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a reusable Debian admin script that safely resets a named user by deleting and recreating that account with a fresh home, working shell, default groups, and interactive password setup.

**Architecture:** Implement a standalone Bash admin utility under `shell/admin/` with explicit argument parsing, destructive-action safeguards, dry-run support, and a single linear execution path. Document the workflow in repo docs so the script can be reused before reinstalling Linux Lab on a VM snapshot base.

**Tech Stack:** Bash, standard Debian admin tools (`deluser`, `userdel`, `adduser`, `useradd`, `usermod`, `pkill`, `passwd`)

---

### Task 1: Add the reset-user admin script

**Files:**
- Create: `shell/admin/reset-user.sh`

- [ ] Step 1: Implement argument parsing, safety checks, dry-run support, and user recreation flow in the new script.
- [ ] Step 2: Make the script self-documenting through `--help` output and clear logging.

### Task 2: Document usage

**Files:**
- Modify: `README.md`

- [ ] Step 1: Add a short maintainer-facing note pointing to the new admin reset script for preparing a clean VM user before reinstalling Linux Lab.

### Task 3: Verify the script

**Files:**
- Verify: `shell/admin/reset-user.sh`

- [ ] Step 1: Run a syntax check with `bash -n`.
- [ ] Step 2: Run `--help` and `--dry-run` to confirm safe output and argument validation.
