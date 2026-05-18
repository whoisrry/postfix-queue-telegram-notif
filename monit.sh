#!/bin/bash

QUEUE_THRESHOLD=100
TELEGRAM_BOT_TOKEN="YOUR_BOT_TOKEN_HERE"
TELEGRAM_CHAT_ID="YOUR_CHAT_ID_OR_CHANNEL_ID_HERE"
MSG_FILE="/tmp/telegram_postfix_alert.txt"

get_queue_count() {
    if postqueue -p | grep -q "Mail queue is empty"; then
        echo 0
    else
        postqueue -p | tail -n 1 | awk '{print $5}'
    fi
}

get_top_senders() {
    postqueue -p | \
    grep -v -E '(^ |^ *\(|Queue ID|-- [0-9]+ Kbytes)' | \
    awk '{print $7}' | \
    grep -v '^$' | \
    sort | \
    uniq -c | \
    sort -nr | \
    head -n 5
}

send_telegram_alert() {
    local queue_size=$1
    local top_senders=$2
    local hostname=$(hostname)
    
    cat <<EOF > "$MSG_FILE"
*Postfix Queue Alert on ${hostname}*

*Current Queue Size:* ${queue_size} (Threshold: ${QUEUE_THRESHOLD})

*Top 5 Sender Accounts:*
\`\`\`text
${top_senders}
\`\`\`
EOF

    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
        -d "chat_id=${TELEGRAM_CHAT_ID}" \
        -d "text=$(cat $MSG_FILE)" \
        -d "parse_mode=Markdown" > /dev/null

    rm -f "$MSG_FILE"
}

check_postfix_queue() {
    local current_queue=$(get_queue_count)
    
    if [[ ! "$current_queue" =~ ^[0-9]+$ ]]; then
        return 1
    fi

    if [ "$current_queue" -gt "$QUEUE_THRESHOLD" ]; then
        local senders_list=$(get_top_senders)
        send_telegram_alert "$current_queue" "$senders_list"
    fi
}

check_postfix_queue
