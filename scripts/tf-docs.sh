#!/bin/bash
# SPDX-SnippetBegin
# SPDX-License-Identifier: Apache License 2.0
# SPDX-SnippetCopyrightText: 2024 © Argo Project, argoproj/argo-helm
# SPDX-SnippetCopyrightText: 2024 © Unique AG
# SPDX-SnippetEnd
## Reference: https://github.com/norwoodj/helm-docs
set -eux
TF_DOCS_VERSION="0.19.0"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
echo "Repo root: $REPO_ROOT"

echo "Running tf-docs"
docker run \
    --rm --volume "$(pwd):/workdir" \
    -u $(id -u) quay.io/terraform-docs/terraform-docs:$TF_DOCS_VERSION /workdir \
    --config /workdir/.github/configs/tfdocs.yaml
