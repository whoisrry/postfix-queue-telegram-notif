#!/bin/bash
#VERSION=1.2

# Ensure postqueue is in PATH for root cron and Zimbra environments
export PATH="/opt/zimbra/common/sbin:/opt/zimbra/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

QUEUE_THRESHOLD=100
TELEGRAM_BOT_TOKEN="YOUR_BOT_TOKEN_HERE"
TELEGRAM_CHAT_ID="YOUR_CHAT_ID_OR_CHANNEL_ID_HERE"

check_postfix_queue() {
    local pq_output
    pq_output=$(postqueue -p)

    if echo "$pq_output" | grep -q "Mail queue is empty"; then
        return 0
    fi

    local current_queue
    current_queue=$(echo "$pq_output" | tail -n 1 | awk '{print $5}')
    
    if [[ ! "$current_queue" =~ ^[0-9]+$ ]]; then
        return 1
    fi

    if [ "$current_queue" -gt "$QUEUE_THRESHOLD" ]; then
        local senders_list
        senders_list=$(echo "$pq_output" | awk '/^[0-9A-F]+[*!]?/ {print $7}' | sort | uniq -c | sort -nr | head -n 5)
        
        local hostname=$(hostname)
        local message
        message=$(cat <<EOF
*Postfix Queue Alert on ${hostname}*

*Current Queue Size:* ${current_queue} (Threshold: ${QUEUE_THRESHOLD})

*Top 5 Sender Accounts:*
\`\`\`text
${senders_list}
\`\`\`
EOF
)

        curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
            -d "chat_id=${TELEGRAM_CHAT_ID}" \
            --data-urlencode "text=${message}" \
            -d "parse_mode=Markdown" > /dev/null
    fi
}

check_postfix_queue
