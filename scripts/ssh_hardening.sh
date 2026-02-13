#!/usr/bin/env bash

# Disable SSH password authentication (key-only)
disable_ssh_password() {
  if [ "$(id -u)" -ne 0 ]; then
    echo "Run as root: sudo disable_ssh_password"
    return 1
  fi

  local cfg="/etc/ssh/sshd_config"

  sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' "$cfg"
  sed -i 's/^#\?ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' "$cfg"
  sed -i 's/^#\?KbdInteractiveAuthentication.*/KbdInteractiveAuthentication no/' "$cfg"

  systemctl restart sshd
  echo "SSH password authentication disabled."
}

# Auto-disable SSH password auth if running as root and it's still enabled
if [ "$(id -u)" -eq 0 ] && [ -f /etc/ssh/sshd_config ]; then
  if grep -qE '^\s*PasswordAuthentication\s+yes' /etc/ssh/sshd_config; then
    disable_ssh_password
  fi
fi
