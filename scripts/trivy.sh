#!/bin/bash
# SPDX-SnippetBegin
# SPDX-License-Identifier: Proprietary
# SPDX-SnippetCopyrightText: 2024 © Unique AG
# SPDX-SnippetEnd
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
echo "Running Trivy for Terraform scanning"

output_file=""
targets=()
run_all=false

if [ "$#" -eq 0 ]; then
  run_all=true
fi

for arg in "$@"; do
  if [ "$arg" = "--all" ]; then
    run_all=true
  elif [[ "$arg" == *.sarif ]]; then
    output_file="$arg"
  else
    targets+=("$arg")
  fi
done

if [ "$run_all" = true ]; then
  targets=("")
fi

if [ -n "$output_file" ] && [ "${#targets[@]}" -gt 1 ]; then
  echo "SARIF output is only supported for a single Trivy target."
  exit 1
fi

for target in "${targets[@]}"; do
  trivy_args=(
    docker run --rm
    -v "$REPO_ROOT:/workdir"
    aquasec/trivy@sha256:bcc376de8d77cfe086a917230e818dc9f8528e3c852f7b1aff648949b6258d1c
    config
    --ignorefile /workdir/.github/configs/trivyignore.yaml
  )

  if [ -n "$output_file" ]; then
    touch "$REPO_ROOT/$output_file"
    chmod 666 "$REPO_ROOT/$output_file"
    trivy_args+=(--format sarif -o "/workdir/$output_file")
  fi

  if [ -n "$target" ]; then
    echo "Processing module: $target"
    trivy_args+=("/workdir/$target")
  else
    trivy_args+=("/workdir")
  fi

  "${trivy_args[@]}"
done