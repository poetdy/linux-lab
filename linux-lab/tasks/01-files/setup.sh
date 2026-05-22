#!/usr/bin/env bash
set -euo pipefail
LAB="$HOME/linux-lab/sandbox/files-lab"
rm -rf "$LAB"
mkdir -p "$LAB/misc" "$LAB/inbox" "$LAB/raw/pics" "$LAB/raw/texts" "$LAB/tmp"
printf 'alpha\n' > "$LAB/inbox/notes.txt"
printf 'beta\n' > "$LAB/raw/texts/manual.txt"
printf 'gamma\n' > "$LAB/raw/texts/report-final.txt"
printf 'pngdata\n' > "$LAB/raw/pics/image1.png"
printf 'jpgdata\n' > "$LAB/raw/pics/photo.jpg"
printf 'warn\n' > "$LAB/misc/app.log"
printf 'error\n' > "$LAB/tmp/system.log"
printf 'hidden\n' > "$LAB/.secret"
rm -rf "$LAB/organized" "$LAB/organized.tar.gz"
echo 'Среда для урока 01 подготовлена: ~/linux-lab/sandbox/files-lab'
