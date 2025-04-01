#!/bin/bash
# SPDX-SnippetBegin
# SPDX-License-Identifier: Proprietary
# SPDX-SnippetCopyrightText: 2024 © Unique AG
# SPDX-SnippetEnd
echo "Running Trivy for Terraform scanning"
docker run --rm -v "$(pwd):/workdir" aquasec/trivy config --ignorefile /workdir/.github/configs/trivyignore.yaml /workdir