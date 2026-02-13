#!/usr/bin/env bash

set -e

CLAWED_DIR="$HOME/clawed"
REPO_URL="https://github.com/frankhli843/hashtensor-clawed.git"
SOURCE_LINE='source "$HOME/clawed/main.sh"'
ENV_LINE='export BASH_ENV="$HOME/clawed/main.sh"'
MARKER="clawed/main.sh"

# Clone if not already present
if [ ! -d "$CLAWED_DIR" ]; then
  git clone "$REPO_URL" "$CLAWED_DIR"
else
  echo "Already cloned at $CLAWED_DIR, pulling latest..."
  git -C "$CLAWED_DIR" pull
fi

# Add to .bashrc (interactive non-login shells)
if ! grep -qF "$MARKER" "$HOME/.bashrc" 2>/dev/null; then
  printf '\n# Clawed scripts\n%s\n' "$SOURCE_LINE" >> "$HOME/.bashrc"
  echo "Added source line to ~/.bashrc"
fi

# Add BASH_ENV to .bash_profile (login shells set it, non-interactive children inherit it)
if ! grep -qF "$MARKER" "$HOME/.bash_profile" 2>/dev/null; then
  printf '\n# Clawed scripts\n%s\n%s\n' "$SOURCE_LINE" "$ENV_LINE" >> "$HOME/.bash_profile"
  echo "Added source + BASH_ENV to ~/.bash_profile"
fi

# Add hourly cron job to force pull latest
CRON_CMD="cd $CLAWED_DIR && git fetch --all && git reset --hard origin/main"
CRON_LINE="0 * * * * $CRON_CMD"
if ! crontab -l 2>/dev/null | grep -qF "clawed"; then
  (crontab -l 2>/dev/null; echo "$CRON_LINE") | crontab -
  echo "Added hourly cron job to force pull"
fi

echo "Done. Restart your shell or run: source ~/.bashrc"
