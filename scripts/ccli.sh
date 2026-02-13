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

# Symlink clauderunner's nvm binaries into /usr/local/bin so root can access them
_symlink_nvm_bins() {
  if [ "$(id -u)" -ne 0 ]; then
    return 0
  fi
  local _nvm_bin_dir="/home/clauderunner/.nvm/versions/node"
  if [ ! -d "$_nvm_bin_dir" ]; then
    return 0
  fi
  local _node_bin
  _node_bin="$(find "$_nvm_bin_dir" -maxdepth 2 -name bin -type d 2>/dev/null | sort -V | tail -1)"
  if [ -z "$_node_bin" ]; then
    return 0
  fi
  for bin in node openclaw; do
    if [ -f "$_node_bin/$bin" ] && [ ! -e "/usr/local/bin/$bin" ]; then
      ln -s "$_node_bin/$bin" "/usr/local/bin/$bin"
    fi
  done
}

_symlink_nvm_bins

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
    # Install claude for the runner user if needed
    if [ ! -f "/home/$_ccli_user/.local/bin/claude" ]; then
      su - "$_ccli_user" -c "curl -fsSL https://claude.ai/install.sh | bash"
    fi
    # Run claude as the non-root user
    su - "$_ccli_user" -c "export NVM_DIR=\"/home/$_ccli_user/.nvm\" && [ -s \"\$NVM_DIR/nvm.sh\" ] && . \"\$NVM_DIR/nvm.sh\"; export PATH=\"/home/$_ccli_user/.local/bin:\$PATH\"; cd \"$_ccli_cwd\" && claude --dangerously-skip-permissions $*"
  else
    claude --dangerously-skip-permissions "$@"
  fi
}

# Load NVM for root if available from clauderunner
if [ "$(id -u)" -eq 0 ] && [ -s "/home/clauderunner/.nvm/nvm.sh" ]; then
  export NVM_DIR="/home/clauderunner/.nvm"
  . "$NVM_DIR/nvm.sh"
fi

claw() {
  # Restart gateway to avoid token mismatch issues
  pkill -f "openclaw gateway" 2>/dev/null
  sleep 1
  openclaw gateway start 2>/dev/null &
  sleep 2
  openclaw tui "$@"
}
