.PHONY: quality examples --all

.DEFAULT_GOAL := quality

QUALITY_ALL := $(filter --all,$(MAKECMDGOALS))
QUALITY_MODULES := $(shell git diff --name-only --diff-filter=ACMRTUXB HEAD -- modules | awk -F/ 'NF >= 2 { print $$1 "/" $$2 }' | sort -u)

quality:
	@set -e; \
	if [ -n "$(QUALITY_ALL)" ]; then \
		echo "Running quality checks for all modules..."; \
		./scripts/tf-docs.sh --all; \
		./scripts/tf-fmt.sh --all; \
		./scripts/examples.sh --all; \
		./scripts/trivy.sh --all; \
	else \
		modules="$(QUALITY_MODULES)"; \
		if [ -z "$$modules" ]; then \
			echo "No changed module folders found."; \
			exit 0; \
		fi; \
		echo "Running quality checks for changed modules:"; \
		printf '  %s\n' $$modules; \
		./scripts/tf-docs.sh $$modules; \
		./scripts/tf-fmt.sh $$modules; \
		./scripts/examples.sh $$modules; \
		./scripts/trivy.sh $$modules; \
	fi
	@echo "Quality checks completed."

examples:
	@echo "Testing examples..."
	@./scripts/examples.sh
	@echo "Examples completed."

--all:
	@:
