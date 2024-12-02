#!/bin/bash
# SPDX-SnippetBegin
# SPDX-License-Identifier: Proprietary
# SPDX-SnippetCopyrightText: 2024 © Unique AG
# SPDX-SnippetEnd
## Reference: https://github.com/norwoodj/helm-docs
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
echo "Repo root: $REPO_ROOT"

# Set the base directory to the modules folder
BASE_DIR="modules"

for module in "$BASE_DIR"/*; do
  if [ -d "$module" ]; then
    echo "Processing module: $module"

    # Iterate over each example in the module's examples directory
    for example in "$module/examples"/*; do
      if [ -d "$example" ]; then
        echo "  Processing example: $example"

        # Change to the example directory
        cd "$example" || exit

        # Run terraform init and validate
        echo "    Running terraform init"
        terraform init -input=false

        echo "    Running terraform validate"
        terraform validate

        # Return to the base directory
        cd - > /dev/null || exit
      fi
    done
  fi
done

echo "All modules and examples processed."
