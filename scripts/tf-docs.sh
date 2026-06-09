#!/bin/bash
# SPDX-SnippetBegin
# SPDX-License-Identifier: Proprietary
# SPDX-SnippetCopyrightText: 2024 © Unique AG
# SPDX-SnippetEnd
## Reference: https://github.com/norwoodj/helm-docs
set -euo pipefail

TF_DOCS_VERSION="0.20.0"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
echo "Repo root: $REPO_ROOT"

targets=()
run_all=false

if [ "$#" -eq 0 ]; then
    run_all=true
fi

for arg in "$@"; do
    if [ "$arg" = "--all" ]; then
        run_all=true
    else
        targets+=("$arg")
    fi
done

echo "Running tf-docs"

if [ "$run_all" = true ]; then
    docker run \
        --rm --volume "$REPO_ROOT:/workdir" \
        -u "$(id -u)" quay.io/terraform-docs/terraform-docs:$TF_DOCS_VERSION /workdir \
        --config /workdir/.github/configs/tfdocs.yaml
    exit 0
fi

module_config="$REPO_ROOT/.github/configs/tfdocs.module.$$.yaml"
awk '
    /^recursive:/ {
        in_recursive = 1
        print
        next
    }
    in_recursive && /^[^[:space:]]/ {
        in_recursive = 0
    }
    in_recursive && /^[[:space:]]+enabled:/ {
        print "  enabled: false"
        next
    }
    {
        print
    }
' "$REPO_ROOT/.github/configs/tfdocs.yaml" > "$module_config"
trap 'rm -f "$module_config"' EXIT

for target in "${targets[@]}"; do
    echo "Processing module: $target"
    docker run \
        --rm --volume "$REPO_ROOT:/workdir" \
        -u "$(id -u)" quay.io/terraform-docs/terraform-docs:$TF_DOCS_VERSION "/workdir/$target" \
        --config "/workdir/.github/configs/$(basename "$module_config")"
done
