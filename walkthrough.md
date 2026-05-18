# Walkthrough

## Monit Script Architecture Updates

### Original Flow
- Execute `postqueue -p` to check for empty queue.
- Re-execute `postqueue -p` to get queue count.
- If threshold is exceeded, execute `postqueue -p` a third time.
- Parse top senders using a chain of `grep | awk | grep`.
- Write alert message to a temporary file on disk.
- Read temporary file to send Telegram alert via `curl`.

### Optimized Flow
- Execute `postqueue -p` **once** and store output in memory.
- Check stored output for empty queue.
- Extract count directly from stored output.
- If threshold is exceeded, extract top senders from stored output using a single `awk` statement.
- Prepare alert message as an in-memory variable.
- Send Telegram alert using `curl` with `--data-urlencode` for safe payload transmission.
