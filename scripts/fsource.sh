#!/usr/bin/env bash

unalias fsource 2>/dev/null
fsource() {
  git -C "$HOME/clawed" pull
  source "$HOME/.bashrc"
}
