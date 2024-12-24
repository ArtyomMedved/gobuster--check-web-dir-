#!/bin/bash

# Путь к логу Apache
LOG_FILE="/var/log/apache2/access.log"

# Лог файл для блокировок
BLOCK_LOG="/var/log/apache2/ip_block.log"

# Файл для хранения заблокированных IP
BLOCKED_IPS_FILE="/var/log/apache2/blocked_ips.txt"

# Время между проверками
SLEEP_TIME=60

# Порог количества запросов от одного IP
THRESHOLD=100

# Исключенные IP, которые нельзя блокировать
EXCLUDED_IP="178.206.208.0"

# Функция для блокировки IP
block_ip() {
    local IP=$1
    if [[ "$IP" != "$EXCLUDED_IP" && ! $(grep -Fx "$IP" "$BLOCKED_IPS_FILE") ]]; then
        if [[ "$IP" != "127.0.0.1" && "$IP" != "$(hostname -I | awk '{print $1}')" ]]; then
            iptables -A INPUT -s "$IP" -j DROP
            echo "$IP" >> "$BLOCKED_IPS_FILE"
            WHOIS_INFO=$(whois "$IP")
            echo "$(date): Заблокирован IP $IP" >> "$BLOCK_LOG"
            echo "Whois information for $IP:" >> "$BLOCK_LOG"
            echo "$WHOIS_INFO" >> "$BLOCK_LOG"
            echo "----------------------------------" >> "$BLOCK_LOG"
        fi
    fi
}

# Функция для разблокировки IP
unblock_ip() {
    local IP=$1
    iptables -D INPUT -s "$IP" -j DROP
    sed -i "/$IP/d" "$BLOCKED_IPS_FILE"
    echo "$(date): Разблокирован IP $IP" >> "$BLOCK_LOG"
}

# Функция для отображения списка заблокированных IP
list_blocked_ips() {
    if [ -f "$BLOCKED_IPS_FILE" ]; then
        echo "Заблокированные IP:"
        cat "$BLOCKED_IPS_FILE"
    else
        echo "Нет заблокированных IP."
    fi
}

# Проверка аргументов командной строки
if [[ "$1" == "list" ]]; then
    list_blocked_ips
    exit 0
fi

if [[ "$1" == "unblock" && -n "$2" ]]; then
    unblock_ip "$2"
    exit 0
fi

# Основной цикл для проверки и блокировки
while true; do
    ABUSIVE_IPS=$(awk '{print $1}' "$LOG_FILE" | sort | uniq -c | sort -nr | awk -v threshold="$THRESHOLD" '$1 > threshold {print $2}')
    for IP in $ABUSIVE_IPS; do
        if [[ "$IP" != "$EXCLUDED_IP" && ! $(grep -Fx "$IP" "$BLOCKED_IPS_FILE") ]]; then
            block_ip "$IP"
        fi
    done
    sleep "$SLEEP_TIME"
done
