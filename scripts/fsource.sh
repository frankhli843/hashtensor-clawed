#!/usr/bin/env bash

fsource() {
  git -C "$HOME/clawed" pull
  source "$HOME/.bashrc"
}
