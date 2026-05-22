# Linux Lab Russian Help Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Добавить в Linux Lab гарантированную русскую справку через `tldr`, `man` и локальный офлайн fallback после установки на Debian.

**Architecture:** Установщик настраивает локаль, ставит системные пакеты справки и раскладывает локальные help-файлы в `~/.local/share/linux-lab/help`. Shell-слой использует цепочку `tldr -> man -> локальная подсказка`, а отдельный wrapper `tldr` гарантирует наличие русских подсказок даже без системного клиента.

**Tech Stack:** Bash, Debian `apt`, `man-db`, `locales`, shell functions, локальные текстовые help-файлы

---

### Task 1: Подготовить локальный слой справки

**Files:**
- Create: `shell/help/*.txt`
- Create: `shell/tldr`

- [ ] Создать набор русских help-файлов для базовых команд Linux Lab.
- [ ] Добавить wrapper `tldr`, который сначала пробует системный клиент, а затем показывает локальную подсказку.

### Task 2: Обновить shell helper-логику

**Files:**
- Modify: `shell/linux-lab.sh`

- [ ] Добавить функции поиска локальной справки.
- [ ] Обновить `h`, `hman` и `hs` под новую цепочку fallback.

### Task 3: Обновить установщик

**Files:**
- Modify: `install.sh`

- [ ] Добавить установку `locales`, `manpages`, `manpages-ru`, `tree`.
- [ ] Добавить мягкую попытку поставить системный `tldr`-клиент.
- [ ] Добавить генерацию `ru_RU.UTF-8`.
- [ ] Добавить установку `shell/help/` и wrapper `tldr`.

### Task 4: Обновить документацию и проверить результат

**Files:**
- Modify: `README.md`
- Modify: `docs/install.md`

- [ ] Описать трехслойную русскую справку без преувеличений.
- [ ] Прогнать `bash -n` для обновленных скриптов.
- [ ] Проверить grep-ом, что shell-файлы и docs не содержат планировочного мусора.

