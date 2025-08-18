#!/bin/bash
# SPDX-SnippetBegin
# SPDX-License-Identifier: Proprietary
# SPDX-SnippetCopyrightText: 2025 © Unique AG
# SPDX-SnippetEnd
## Reference: https://github.com/norwoodj/helm-docs

# Fixed version of yq to install if not present
YQ_VERSION="v4.47.1"

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

set -uo pipefail
set -x   # <-- this prints each command before running

# Valid change kinds
VALID_KINDS=("added" "changed" "deprecated" "removed" "fixed" "security")

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to check if yq is installed and install if needed
ensure_yq_installed() {
    if ! command -v yq &> /dev/null; then
        echo -e "${YELLOW}yq is not installed. Installing version $YQ_VERSION...${NC}"
        
        # Detect OS and architecture
        OS=$(uname -s | tr '[:upper:]' '[:lower:]')
        ARCH=$(uname -m)
        
        # Map architecture to yq format
        case $ARCH in
            x86_64) ARCH="amd64" ;;
            aarch64|arm64) ARCH="arm64" ;;
            *) echo -e "${RED}Unsupported architecture: $ARCH${NC}" && exit 1 ;;
        esac
        
        # Download and install yq
        YQ_URL="https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_${OS}_${ARCH}"
        YQ_BINARY="/usr/local/bin/yq"
        
        echo -e "${BLUE}Downloading yq from: $YQ_URL${NC}"
        
        # Download yq
        if curl -L -o "$YQ_BINARY" "$YQ_URL"; then
            chmod +x "$YQ_BINARY"
            echo -e "${GREEN}✓ yq $YQ_VERSION installed successfully${NC}"
        else
            echo -e "${RED}Failed to download yq${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}✓ yq is already installed${NC}"
    fi
}

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
    echo "Debug: Starting validation for file: $file"
    
    # Check if file exists
    if [[ ! -f "$file" ]]; then
        echo -e "${RED}  ERROR: File does not exist${NC}"
        return 1
    fi
    echo "Debug: File exists, checking changes field..."
    
    # Check if file has changes field
    echo "Debug: Running yq eval '.changes' on $file"
    if ! yq eval '.changes' "$file" >/dev/null 2>&1; then
        echo -e "${RED}  ERROR: No 'changes' field found${NC}"
        echo -e "${BLUE}  Debug: yq eval '.changes' output:${NC}"
        yq eval '.changes' "$file" 2>&1 || true
        return 1
    fi
    echo "Debug: Changes field found, proceeding with validation..."
    
    # Get all kind values from changes array
    local kinds
    echo -e "${BLUE}  Debug: Running yq eval '.changes[].kind' on $file${NC}"
    echo "Debug: About to run yq eval '.changes[].kind' on $file"
    
    # Run yq command and capture both stdout and stderr
    kinds=$(yq eval '.changes[].kind' "$file" 2>&1)
    local yq_exit_code=$?
    echo "Debug: yq command completed with exit code $yq_exit_code, result: '$kinds'"
    
    if [[ $yq_exit_code -ne 0 ]]; then
        echo -e "${RED}  ERROR: yq command failed to extract kind values (exit code: $yq_exit_code)${NC}"
        echo -e "${BLUE}  Debug: Full yq output:${NC}"
        echo "$kinds"
        return 1
    fi
    
    if [[ -z "$kinds" ]]; then
        echo -e "${RED}  ERROR: No 'kind' values found in changes array${NC}"
        echo -e "${BLUE}  Debug: Empty output from yq, checking file structure:${NC}"
        yq eval '.' "$file" 2>&1 || true
        return 1
    fi
    
    echo -e "${BLUE}  Debug: Found kinds:${NC}"
    echo "$kinds" | while IFS= read -r kind; do
        echo -e "${BLUE}    '$kind'${NC}"
    done
    
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
    # Ensure yq is installed before proceeding
    ensure_yq_installed
    
    # Debug: Check yq version
    echo "Debug: yq version: $(yq --version)"
    echo "Debug: bash version: $(bash --version | head -1)"
    
    # Test yq functionality
    echo "Debug: Testing yq with a simple YAML..."
    echo "name: test" | yq eval '.name' - || echo "ERROR: yq test failed"
    
    local files_to_check=()
    
    # If arguments provided, use them; otherwise find all module.yaml files
    if [[ $# -gt 0 ]]; then
        files_to_check=("$@")
    else
        echo "Validating changes field in all module.yaml files..."
        echo "Debug: Current directory: $(pwd)"
        echo "Debug: Running find command..."
        
        # Use a simple while loop to populate array
        echo "Debug: Using while loop to populate array..."
        while IFS= read -r file; do
            if [[ -n "$file" ]]; then
                echo "Debug: Found file: $file"
                files_to_check+=("$file")
            fi
        done < <(find . -name "module.yaml" -type f)
        
        echo "Debug: Found ${#files_to_check[@]} files using while loop"
        for i in "${!files_to_check[@]}"; do
            echo "Debug: files_to_check[$i]='${files_to_check[$i]}'"
        done
        
        # Check if any files were found
        if [[ ${#files_to_check[@]} -eq 0 ]]; then
            echo -e "${RED}ERROR: No module.yaml files found in current directory${NC}"
            echo "Current directory: $(pwd)"
            echo "Available files:"
            find . -name "*.yaml" -type f | head -10
            exit 1
        fi
    fi
    
    echo "Valid kinds: ${VALID_KINDS[*]}"
    echo "----------------------------------------"
    echo "Debug: Found ${#files_to_check[@]} files to check"
    echo "Debug: files_to_check array contents:"
    printf "  '%s'\n" "${files_to_check[@]}"
    echo "----------------------------------------"
    
    local exit_code=0
    local total_files=0
    local failed_files=0
    
    # Process each file
    echo "Debug: About to start processing loop with ${#files_to_check[@]} files"
    echo "Debug: Array contents before loop:"
    for i in "${!files_to_check[@]}"; do
        echo "  [$i]: '${files_to_check[$i]}'"
    done
    
    for file in "${files_to_check[@]}"; do
        echo "Debug: Loop iteration - file='$file'"
        ((total_files++))
        echo "Processing file $total_files of ${#files_to_check[@]}: $file"
        
        # Validate the file and capture the result
        if validate_module_yaml "$file"; then
            echo -e "${GREEN}Successfully validated: $file${NC}"
        else
            ((failed_files++))
            exit_code=1
            echo -e "${RED}Failed to validate: $file${NC}"
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
