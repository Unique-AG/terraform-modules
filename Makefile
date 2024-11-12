.PHONY: quality examples

.DEFAULT_GOAL := quality

quality:
	@echo "Running quality checks..."
	@./scripts/tf-docs.sh
	@./scripts/tf-fmt.sh
	@./scripts/tf-sec.sh
	@./scripts/examples.sh
	@echo "Quality checks completed."

examples:
	@echo "Testing examples..."
	@./scripts/examples.sh
	@echo "Examples completed."
