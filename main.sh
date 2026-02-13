#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

while IFS= read -r -d '' file; do
  source "$file"
done < <(find "$SCRIPT_DIR/scripts" -type f -name '*.sh' -print0)
