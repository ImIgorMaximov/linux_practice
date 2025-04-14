#!/bin/bash

LOCKFILE="./log_analyzer.lock"
LOG_FILE="./access.log"

# Предотвращаем одновременный запуск
exec 200>"$LOCKFILE"
flock -n 200 || {
	    echo "Скрипт уже выполняется. Завершение."
    exit 1
}

echo "========== Топ 10 запрашиваемых IP-адресов =========="
awk '{print $1}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -n 10 | while read count ip; do
    echo "$count запросов с IP-адреса $ip"
done

echo
echo "========== Количество запросов с IP-адресов с кодами ответа =========="
awk '{print $1, $9}' "$LOG_FILE" | sort | uniq -c | sort -nr | while read count ip code; do
    echo "$count запросов с IP-адреса $ip с кодом $code"
done

echo
echo "========== Ошибки со стороны веб-сервера/приложения (4xx и 5xx) =========="
awk '{print $1, $9, $7}' "$LOG_FILE" | grep -E ' [45][0-9]{2} ' | sort | uniq -c | sort -nr | while read count ip error page; do
    echo "$count запросов с IP-адреса $ip с ошибкой $error на ресурс $page"
done

echo
echo "========== Список запрашиваемых URL с IP-адресов =========="
awk '{print $1, $7}' "$LOG_FILE" | sort | uniq -c | sort -nr | while read count ip page; do
    echo "$count раз(а) $ip запросил страницу $page"
done
