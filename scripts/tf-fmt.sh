#!/bin/bash
# SPDX-SnippetBegin
# SPDX-License-Identifier: Proprietary
# SPDX-SnippetCopyrightText: 2024 © Unique AG
# SPDX-SnippetEnd
set -euo pipefail

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

if [ "$run_all" = true ]; then
    terraform fmt -recursive modules
    exit 0
fi

for target in "${targets[@]}"; do
    terraform fmt -recursive "$target"
done
