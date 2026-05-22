#!/usr/bin/env bash
set -euo pipefail
LAB="$HOME/linux-lab/sandbox/files-lab"
fail(){ echo "Не пройдено: $1"; exit 1; }
[ -d "$LAB/organized/docs" ] || fail "нет каталога organized/docs"
[ -d "$LAB/organized/images" ] || fail "нет каталога organized/images"
[ -d "$LAB/organized/logs" ] || fail "нет каталога organized/logs"
[ -f "$LAB/organized/archive/report-final.txt" ] || fail "нет копии report-final.txt в archive"
find "$LAB/organized/docs" -maxdepth 1 -type f | grep -Eq '\.txt$' || fail "в organized/docs не найдены txt-файлы"
find "$LAB/organized/images" -maxdepth 1 -type f | grep -Eq '\.(png|jpg)$' || fail "в organized/images не найдены изображения"
find "$LAB/organized/logs" -maxdepth 1 -type f | grep -Eq '\.log$' || fail "в organized/logs не найдены log-файлы"
[ -f "$LAB/organized.tar.gz" ] || fail "архив organized.tar.gz не создан"
tar -tf "$LAB/organized.tar.gz" | grep -q '^organized/' || fail "архив не содержит каталог organized/"
echo 'Урок 01 пройден: структура собрана верно.'
