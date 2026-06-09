.PHONY: quality examples

.DEFAULT_GOAL := quality

quality:
	@echo "Running quality checks..."
	@./scripts/tf-docs.sh
	@./scripts/tf-fmt.sh
	@./scripts/examples.sh
	@./scripts/trivy.sh
	@echo "Quality checks completed."

examples:
	@echo "Testing examples..."
	@./scripts/examples.sh
	@echo "Examples completed."
