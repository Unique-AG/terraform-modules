#!/bin/bash
# SPDX-SnippetBegin
# SPDX-License-Identifier: Proprietary
# SPDX-SnippetCopyrightText: 2026 © Unique AG
# SPDX-SnippetEnd
# Checks every AWS module (modules/aws-*) against the IaC standard (STANDARD.md):
# TFLint, trivy (blocking at high and above), checkov with the custom checks in
# .github/checkov, and terraform test. tf.validate.yaml covers fmt, docs and examples.
set -euo pipefail
shopt -s nullglob

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=scripts/images.sh
source "$REPO_ROOT/scripts/images.sh"
cd "$REPO_ROOT"

CUSTOM_CHECKS=CKV_UQ_AWS_1,CKV_UQ_AWS_2,CKV2_UQ_AWS_3,CKV_UQ_AWS_4

in_docker() {
  docker run --rm -v "$REPO_ROOT:/workdir" -w /workdir "$@"
}

# checkov and trivy skip a directory they can't see and still exit 0, so make sure
# the containers see the repository before trusting any result.
if ! docker run --rm -v "$REPO_ROOT:/workdir" --entrypoint test "$CHECKOV_IMAGE" -f /workdir/scripts/aws-checks.sh; then
  echo "::error::docker can't see ${REPO_ROOT}; share the path with docker and run again"
  exit 1
fi

# Every custom check passes tests/pass and fails in tests/fail, so a check that
# stops matching can't pass the modules unnoticed.
echo "Testing the custom checks"
summary=$(in_docker "$CHECKOV_IMAGE" -d .github/checkov/tests/pass --framework terraform \
  --external-checks-dir .github/checkov --check "$CUSTOM_CHECKS" -o json --soft-fail \
  | jq -r '"\(.summary.passed // 0) \(.summary.failed // 0)"')
read -r passed failed_count <<< "$summary"
if [ "$passed" -eq 0 ] || [ "$failed_count" -ne 0 ]; then
  echo "::error::.github/checkov/tests/pass should pass every check; ${passed} passed, ${failed_count} failed"
  exit 1
fi
failed=$(in_docker "$CHECKOV_IMAGE" -d .github/checkov/tests/fail --framework terraform \
  --external-checks-dir .github/checkov --check "$CUSTOM_CHECKS" -o json --soft-fail \
  | jq -r '.results.failed_checks[].check_id' | sort -u | paste -sd, -)
expected=$(tr ',' '\n' <<< "$CUSTOM_CHECKS" | sort -u | paste -sd, -)
if [ "$failed" != "$expected" ]; then
  echo "::error::.github/checkov/tests/fail should fail ${expected}; it failed ${failed:-nothing}"
  exit 1
fi

modules=(modules/aws-*/)
if [ ${#modules[@]} -eq 0 ]; then
  echo "No AWS modules yet; only the custom checks were tested."
  exit 0
fi

for module in "${modules[@]}"; do
  module="${module%/}"
  echo "::group::${module}"

  tests=("$module"/tests/*.tftest.hcl)
  if [ ${#tests[@]} -eq 0 ]; then
    echo "::error::${module} has no tests/*.tftest.hcl (STANDARD.md IAC-12)"
    exit 1
  fi

  echo "TFLint"
  in_docker "$TFLINT_IMAGE" --chdir "$module" --config /workdir/.github/configs/tflint.hcl

  echo "trivy"
  in_docker "$TRIVY_IMAGE" config --quiet --ignorefile .github/configs/trivyignore.yaml \
    --severity HIGH,CRITICAL --exit-code 1 "$module"

  # CKV_UQ_AWS_1 replaces CKV_AWS_61, as in the landing zone.
  echo "checkov"
  in_docker "$CHECKOV_IMAGE" -d "$module" --framework terraform --quiet --compact \
    --external-checks-dir .github/checkov --skip-check CKV_AWS_61

  echo "terraform test"
  terraform -chdir="$module" init -backend=false -input=false
  terraform -chdir="$module" test

  echo "::endgroup::"
done

echo "Checked ${#modules[@]} AWS module(s)."
