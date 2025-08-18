#!/bin/bash
# SPDX-SnippetBegin
# SPDX-License-Identifier: Proprietary
# SPDX-SnippetCopyrightText: 2025 © Unique AG
# SPDX-SnippetEnd
## Reference: https://github.com/norwoodj/helm-docs
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
echo "Repo root: $REPO_ROOT"

echo "Linting modules for their changes syntax."

# Script to validate changes field in all module.yaml files
# Validates that all 'kind' values are one of: added, changed, deprecated, removed, fixed, security
#
# Usage:
#   ./scripts/validate-changes.sh                    # Validate all module.yaml files recursively
#   ./scripts/validate-changes.sh file1.yaml         # Validate specific file(s)
#   ./scripts/validate-changes.sh file1.yaml file2.yaml
#
# Exit codes:
#   0 - All files have valid change kinds
#   1 - One or more files have invalid change kinds

set -euo pipefail

# Valid change kinds
VALID_KINDS=("added" "changed" "deprecated" "removed" "fixed" "security")

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if a kind is valid
is_valid_kind() {
    local kind="$1"
    for valid_kind in "${VALID_KINDS[@]}"; do
        if [[ "$kind" == "$valid_kind" ]]; then
            return 0
        fi
    done
    return 1
}

# Function to validate a single module.yaml file
validate_module_yaml() {
    local file="$1"
    local has_errors=false
    
    echo -e "${YELLOW}Validating: $file${NC}"
    
    # Check if file has changes field
    if ! yq eval '.changes' "$file" >/dev/null 2>&1; then
        echo -e "${RED}  ERROR: No 'changes' field found${NC}"
        return 1
    fi
    
    # Get all kind values from changes array
    local kinds
    kinds=$(yq eval '.changes[].kind' "$file" 2>/dev/null || true)
    
    if [[ -z "$kinds" ]]; then
        echo -e "${RED}  ERROR: No 'kind' values found in changes array${NC}"
        return 1
    fi
    
    # Check each kind
    while IFS= read -r kind; do
        if [[ -n "$kind" ]]; then
            if ! is_valid_kind "$kind"; then
                echo -e "${RED}  ERROR: Invalid kind '$kind' found${NC}"
                has_errors=true
            else
                echo -e "${GREEN}  ✓ Valid kind: $kind${NC}"
            fi
        fi
    done <<< "$kinds"
    
    if [[ "$has_errors" == "true" ]]; then
        return 1
    fi
    
    return 0
}

# Main script
main() {
    local files_to_check=()
    
    # If arguments provided, use them; otherwise find all module.yaml files
    if [[ $# -gt 0 ]]; then
        files_to_check=("$@")
    else
        echo "Validating changes field in all module.yaml files..."
        while IFS= read -r -d '' file; do
            files_to_check+=("$file")
        done < <(find . -name "module.yaml" -type f -print0)
    fi
    
    echo "Valid kinds: ${VALID_KINDS[*]}"
    echo "----------------------------------------"
    
    local exit_code=0
    local total_files=0
    local failed_files=0
    
    # Process each file
    for file in "${files_to_check[@]}"; do
        ((total_files++))
        if ! validate_module_yaml "$file"; then
            ((failed_files++))
            exit_code=1
        fi
        echo ""
    done
    
    echo "----------------------------------------"
    echo "Summary:"
    echo "  Total files processed: $total_files"
    echo "  Failed files: $failed_files"
    
    if [[ $exit_code -eq 0 ]]; then
        echo -e "${GREEN}✓ All module.yaml files have valid change kinds${NC}"
    else
        echo -e "${RED}✗ Some module.yaml files have invalid change kinds${NC}"
    fi
    
    exit $exit_code
}

# Run main function
main "$@"
