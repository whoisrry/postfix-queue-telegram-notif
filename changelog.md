# Changelog

## [1.3] - 2026-05-18
- feat: add auto-update mechanism using `monit.sh update` to pull latest script from remote while preserving local configuration variables.

## [1.2] - 2026-05-18
- feat: inject `PATH` to automatically support root crontab execution and Zimbra's custom `postqueue` paths.

## [1.1] - 2026-05-18
- docs(readme): create README.md with setup and usage instructions.
- refactor(monit.sh): run postqueue once to reduce system load, remove temporary files usage, simplify sender parsing using awk, and use URL encoding for telegram message payload.
