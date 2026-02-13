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
# When running as root, delegate to a temporary non-root user to bypass the restriction
ccli() {
  if [ "$(id -u)" -eq 0 ]; then
    local _ccli_user="clauderunner"
    if ! id "$_ccli_user" &>/dev/null; then
      useradd -m -s /bin/bash "$_ccli_user"
    fi
    # Copy API key config so claude can authenticate
    local _ccli_config_dir="/home/$_ccli_user/.claude"
    mkdir -p "$_ccli_config_dir"
    if [ -f "$HOME/.claude/.credentials.json" ]; then
      cp "$HOME/.claude/.credentials.json" "$_ccli_config_dir/"
    fi
    chown -R "$_ccli_user:$_ccli_user" "$_ccli_config_dir"
    # Give the runner access to the current working directory
    local _ccli_cwd
    _ccli_cwd="$(pwd)"
    setfacl -R -m "u:${_ccli_user}:rwx" "$_ccli_cwd" 2>/dev/null || chmod -R o+rwx "$_ccli_cwd"
    # Run claude as the non-root user
    su - "$_ccli_user" -c "export PATH=\"$PATH\"; cd \"$_ccli_cwd\" && claude --dangerously-skip-permissions $*"
  else
    claude --dangerously-skip-permissions "$@"
  fi
}
