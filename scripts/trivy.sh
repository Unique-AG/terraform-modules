#!/bin/bash
# SPDX-SnippetBegin
# SPDX-License-Identifier: Proprietary
# SPDX-SnippetCopyrightText: 2024 © Unique AG
# SPDX-SnippetEnd
# shellcheck source=scripts/images.sh
source "$(dirname "$0")/images.sh"

echo "Running Trivy for Terraform scanning"

CMD="docker run --rm -v "$(pwd):/workdir" $TRIVY_IMAGE config --ignorefile /workdir/.github/configs/trivyignore.yaml"

# Check if output file path is provided as argument
if [ -n "$1" ]; then
  TRIVY_OUTPUT_FILE="/workdir/$1"
  touch "$TRIVY_OUTPUT_FILE"
  chmod 666 "$TRIVY_OUTPUT_FILE"
  CMD="$CMD --format sarif -o $TRIVY_OUTPUT_FILE"
fi

CMD="$CMD /workdir"

eval "$CMD"