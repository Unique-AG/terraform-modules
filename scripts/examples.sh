#!/bin/bash
# SPDX-SnippetBegin
# SPDX-License-Identifier: Proprietary
# SPDX-SnippetCopyrightText: 2024 © Unique AG
# SPDX-SnippetEnd
## Reference: https://github.com/norwoodj/helm-docs
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
echo "Repo root: $REPO_ROOT"
cd "$REPO_ROOT"

modules=()
run_all=false

if [ "$#" -eq 0 ]; then
  run_all=true
fi

for arg in "$@"; do
  if [ "$arg" = "--all" ]; then
    run_all=true
  else
    modules+=("$arg")
  fi
done

if [ "$run_all" = true ]; then
  modules=(modules/*)
fi

for module in "${modules[@]}"; do
  if [ -d "$module" ]; then
    echo "Processing module: $module"

    for example in "$module/examples"/*; do
      if [ -d "$example" ]; then
        echo "  Processing example: $example"

        cd "$example" || exit

        echo "    Running terraform init"
        terraform init -upgrade -input=false || exit 1

        echo "    Running terraform validate"
        terraform validate || exit 1

        cd "$REPO_ROOT" || exit
      fi
    done
  fi
done

echo "All modules and examples processed successfully."
