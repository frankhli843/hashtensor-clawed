#!/usr/bin/env bash

# Ensure Claude Code's install location is in PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

# Install Claude Code if not already installed
install_claude_code() {
  if command -v claude &>/dev/null; then
    return 0
  fi

  echo "Installing Claude Code..."
  curl -fsSL https://claude.ai/install.sh | bash
  echo "Claude Code installed."
}

install_claude_code

# Claude CLI alias - skip permissions prompt
alias ccli='claude --dangerously-skip-permissions'
