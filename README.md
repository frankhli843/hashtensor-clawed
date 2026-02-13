# Clawed

Personal shell scripts, automatically sourced for both interactive and non-interactive bash sessions.

## Quick Install

```bash
git clone https://github.com/frankhli843/hashtensor-clawed.git $HOME/clawed && bash $HOME/clawed/install.sh
```

This will:

1. Clone the repo to `~/clawed`
2. Add `source "$HOME/clawed/main.sh"` to `~/.bashrc` (interactive shells)
3. Add `source` + `export BASH_ENV` to `~/.bash_profile` (login shells + non-interactive shells)
4. Add an hourly cron job that force pulls the latest from `origin/main`

`BASH_ENV` tells bash to source the script even in non-interactive mode (e.g. shell scripts, cron jobs, `bash -c "..."`).

## Claude Code Setup

Claude Code is installed automatically when the scripts are sourced. To authenticate, you have two options:

### Option A: OAuth Login (uses your Claude Pro/Max subscription)

1. Run `ccli` on the server — it will launch Claude Code and show a login prompt
2. Select **option 1** (Claude account with subscription)
3. It will display a URL — open that URL in your browser on any device
4. Complete the login in your browser
5. Claude Code on the server will detect the login and start working

### Option B: API Key (pay-as-you-go billing)

1. Go to [console.anthropic.com](https://console.anthropic.com/)
2. Sign up or log in
3. Navigate to **Settings** > **API Keys**
4. Click **Create Key**, give it a name, and copy the key (starts with `sk-ant-...`)
5. Add it to your shell profile:

```bash
echo 'export ANTHROPIC_API_KEY="sk-ant-your-key-here"' >> ~/.bash_profile
source ~/.bash_profile
```

Note: Option B uses pay-as-you-go API billing, not your Claude Pro/Max subscription. Add credits under **Settings** > **Billing** in the console.

## Adding Scripts

Drop any `.sh` file into the `scripts/` directory (subdirectories work too). It will be sourced automatically by `main.sh`.

## Updating

Scripts auto-update every hour via cron. To update manually:

```bash
cd ~/clawed && git pull
```
