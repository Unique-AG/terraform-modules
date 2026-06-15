#!/bin/bash
# SPDX-SnippetBegin
# SPDX-License-Identifier: Proprietary
# SPDX-SnippetCopyrightText: 2026 © Unique AG
# SPDX-SnippetEnd
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
echo "Repo root: $REPO_ROOT"

set -e
shopt -s nullglob

TARGET_DIR_ARG="${1:-modules}"

if [[ "$TARGET_DIR_ARG" = /* ]]; then
  TARGET_DIR="$TARGET_DIR_ARG"
else
  TARGET_DIR="$REPO_ROOT/$TARGET_DIR_ARG"
fi

if [ ! -d "$TARGET_DIR" ]; then
  echo "Target directory does not exist: $TARGET_DIR" >&2
  exit 1
fi

echo "Search directory: $TARGET_DIR"

if [ -d "$TARGET_DIR/examples" ]; then
  modules=("$TARGET_DIR")
else
  modules=("$TARGET_DIR"/*)
fi

processed_examples=0

for module in "${modules[@]}"; do
  if [ -d "$module" ]; then
    echo "Processing module: $module"

    for example in "$module/examples"/*; do
      if [ -d "$example" ]; then
        echo "  Processing example: $example"

        cd "$example" || exit

        echo "    Running terraform init"
        terraform init -upgrade -input=false

        echo "    Running terraform validate"
        terraform validate

        cd - > /dev/null || exit
        processed_examples=$((processed_examples + 1))
      fi
    done
  fi
done

if [ "$processed_examples" -eq 0 ]; then
  echo "No examples found in $TARGET_DIR."
else
  echo "All $processed_examples examples processed successfully."
fi
