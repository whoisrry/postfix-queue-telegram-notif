# Walkthrough

## Monit Script Architecture Updates

### Original Flow
- Execute `postqueue -p` to check for empty queue.
- Re-execute `postqueue -p` to get queue count.
- If threshold is exceeded, execute `postqueue -p` a third time.
- Parse top senders using a chain of `grep | awk | grep`.
- Write alert message to a temporary file on disk.
- Read temporary file to send Telegram alert via `curl`.

### Documentation
- Created `README.md` to document prerequisites, setup instructions, configuration variables, and crontab deployment.
- Updated `README.md` to indicate implicit support for Zimbra and root cron execution.

### Environment Management
- Injected `export PATH` directly into `monit.sh` to ensure `/opt/zimbra/...` and `/usr/local/sbin` binaries (like `postqueue`) are available, specifically bypassing standard `cron` environment limitations.

### Optimized Flow
- Execute `postqueue -p` **once** and store output in memory.
- Check stored output for empty queue.
- Extract count directly from stored output.
- If threshold is exceeded, extract top senders from stored output using a single `awk` statement.
- Prepare alert message as an in-memory variable.
- Send Telegram alert using `curl` with `--data-urlencode` for safe payload transmission.
