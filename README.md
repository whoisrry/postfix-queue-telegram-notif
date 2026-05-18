# Postfix Queue Telegram Notifier

A lightweight script to monitor the Postfix mail queue and send an alert via Telegram if the queue size exceeds a specified threshold. It also identifies and reports the top 5 senders causing the buildup.

## Prerequisites
- A Linux server running `postfix` or `zimbra` (the script automatically supports Zimbra's `postqueue` path).
- `curl` installed (`apt-get install curl` or `yum install curl`).
- A Telegram Bot Token.
- A Telegram Chat ID or Channel ID where alerts should be sent.
- If running as `root` via cron, the script inherently includes `/usr/sbin` and `/opt/zimbra/...` in its `PATH`, so no manual environment changes are required.

## Setup Instructions

1. **Clone the repository or copy the script**
   Place `monit.sh` in a secure directory on your server, e.g., `/usr/local/bin/`.

2. **Configure Variables**
   Open `monit.sh` and edit the following variables at the top of the file:
   - `QUEUE_THRESHOLD=100`: Change this to your desired queue limit.
   - `TELEGRAM_BOT_TOKEN="YOUR_BOT_TOKEN_HERE"`: Insert your Telegram bot token.
   - `TELEGRAM_CHAT_ID="YOUR_CHAT_ID_OR_CHANNEL_ID_HERE"`: Insert the chat ID or channel ID.

3. **Make the Script Executable**
   ```bash
   chmod +x /usr/local/bin/monit.sh
   ```

4. **Test the Script**
   Run the script manually to ensure there are no syntax errors. If your queue is above the threshold, you will receive a Telegram message.
   ```bash
   /usr/local/bin/monit.sh
   ```

5. **Schedule via Cron**
   To automate the monitoring, add the script to your crontab. For example, to run it every 5 minutes:
   ```bash
   crontab -e
   ```
   Add the following line:
   ```cron
   */5 * * * * /usr/local/bin/monit.sh >/dev/null 2>&1
   ```

## Auto-Update
The script includes an automated update mechanism that fetches the latest version from GitHub while preserving your local variables (`TELEGRAM_BOT_TOKEN`, `TELEGRAM_CHAT_ID`, and `QUEUE_THRESHOLD`).

To update the script, run:
```bash
/usr/local/bin/monit.sh update
```

## Requirements
The script uses standard Linux tools: `bash`, `postqueue`, `grep`, `awk`, `tail`, `sort`, `uniq`, `head`, and `curl`. No additional dependencies are required.
