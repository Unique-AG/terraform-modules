#!/bin/bash
# SPDX-SnippetBegin
# SPDX-License-Identifier: Proprietary
# SPDX-SnippetCopyrightText: 2026 © Unique AG
# SPDX-SnippetEnd
# Scanner images, pinned by digest. Change a digest together with the version beside it.
# The scripts that source this file use the variables.
# shellcheck disable=SC2034
TRIVY_IMAGE="aquasec/trivy@sha256:bcc376de8d77cfe086a917230e818dc9f8528e3c852f7b1aff648949b6258d1c" # v0.69.3
CHECKOV_IMAGE="bridgecrew/checkov@sha256:7407699a91a556849ae66e05c3753f58cf0ce922aa6ddfac7839aad4f390c016" # 3.3.16
TFLINT_IMAGE="ghcr.io/terraform-linters/tflint@sha256:2788f4d4fc663c0e953b011b01bf443fe5bfce7587ee916e588e6057b85d6359" # v0.65.0
