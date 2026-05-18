#!/bin/bash
#VERSION=1.3

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

update_script() {
    local remote_url="https://raw.githubusercontent.com/whoisrry/postfix-queue-telegram-notif/main/monit.sh"
    local remote_script
    remote_script=$(curl -s "$remote_url")
    
    if [ -z "$remote_script" ]; then
        echo "Failed to fetch remote script."
        exit 1
    fi

    local current_version
    current_version=$(grep -m 1 '^#VERSION=' "$0" | cut -d'=' -f2 | tr -d '\r')
    local remote_version
    remote_version=$(echo "$remote_script" | grep -m 1 '^#VERSION=' | cut -d'=' -f2 | tr -d '\r')

    if [ -z "$remote_version" ]; then
        echo "Could not determine remote version."
        exit 1
    fi

    if awk 'BEGIN {if ('"$remote_version"' > '"$current_version"') exit 0; else exit 1}'; then
        echo "Updating from version $current_version to $remote_version..."
        
        local current_threshold=$(grep -m 1 '^QUEUE_THRESHOLD=' "$0" | cut -d'=' -f2)
        local current_token=$(grep -m 1 '^TELEGRAM_BOT_TOKEN=' "$0" | cut -d'=' -f2-)
        local current_chat=$(grep -m 1 '^TELEGRAM_CHAT_ID=' "$0" | cut -d'=' -f2-)
        
        awk -v th="$current_threshold" -v tk="$current_token" -v ci="$current_chat" '
        /^QUEUE_THRESHOLD=/ { print "QUEUE_THRESHOLD=" th; next }
        /^TELEGRAM_BOT_TOKEN=/ { print "TELEGRAM_BOT_TOKEN=" tk; next }
        /^TELEGRAM_CHAT_ID=/ { print "TELEGRAM_CHAT_ID=" ci; next }
        { print }
        ' <<< "$remote_script" > "$0.tmp"
        
        mv "$0.tmp" "$0"
        chmod +x "$0"
        echo "Update complete."
        exit 0
    else
        echo "Already up to date (version $current_version)."
        exit 0
    fi
}

if [ "$1" == "update" ]; then
    update_script
else
    check_postfix_queue
fi
