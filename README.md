# Clawed

Personal shell scripts, automatically sourced for both interactive and non-interactive bash sessions.

## Quick Install

```bash
git clone https://github.com/frankhli843/clawed.git ~/clawed && ~/clawed/install.sh
```

This will:

1. Clone the repo to `~/clawed`
2. Add `source "$HOME/clawed/main.sh"` to `~/.bashrc` (interactive shells)
3. Add `source` + `export BASH_ENV` to `~/.bash_profile` (login shells + non-interactive shells)

`BASH_ENV` tells bash to source the script even in non-interactive mode (e.g. shell scripts, cron jobs, `bash -c "..."`).

## Adding Scripts

Drop any `.sh` file into the `scripts/` directory (subdirectories work too). It will be sourced automatically by `main.sh`.

## Updating

```bash
cd ~/clawed && git pull
```
