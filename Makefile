SHELL_FILES := $(shell find recipes \( -name "*.sh" -o -name "*.sh.tmpl" -o -name "*.bash" \) 2>/dev/null | sort)

.DEFAULT_GOAL := help

.PHONY: help shell-fmt shell-fmt-check shell-lint check

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | awk -F ':.*## ' '{printf "  make %-18s %s\n", $$1, $$2}'

shell-fmt: ## Format shell scripts (shfmt -w)
	shfmt -w $(SHELL_FILES)

shell-fmt-check: ## Check shell formatting without modifying (shfmt -d)
	shfmt -d $(SHELL_FILES)

shell-lint: ## Lint shell scripts (shellcheck)
	shellcheck $(SHELL_FILES)

check: shell-fmt-check shell-lint ## Run shell formatting check and shellcheck
