SHELL_FILES := $(shell find recipes \( -name "*.sh" -o -name "*.sh.tmpl" -o -name "*.bash" \) -not -path "*/private_dot_ai/agent-skills/*" 2>/dev/null | sort)
TS_FILES := $(shell find recipes home -name "*.ts" 2>/dev/null | sort)

.DEFAULT_GOAL := help

.PHONY: help shell-fmt shell-fmt-check shell-lint ts-fmt-check check prek prek-install check-versions init apply diff doctor

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | awk -F ':.*## ' '{printf "  make %-18s %s\n", $$1, $$2}'

init: ## Bootstrap: run overlay then chezmoi init (run once on a new machine)
	chezmoi-recipes overlay --recipes-dir recipes
	chezmoi init --source $(CURDIR)

apply: ## Run chezmoi apply
	chezmoi apply -v

diff: ## Run chezmoi diff
	chezmoi diff

doctor: ## Run chezmoi doctor
	chezmoi doctor

shell-fmt: ## Format shell scripts (shfmt -w)
	shfmt -w $(SHELL_FILES)

shell-fmt-check: ## Check shell formatting without modifying (shfmt -d)
	shfmt -d $(SHELL_FILES)

shell-lint: ## Lint shell scripts (shellcheck)
	shellcheck --severity=warning $(SHELL_FILES)

ts-fmt-check: ## Check TypeScript formatting (Prettier)
	bunx --bun prettier@3.6.2 --check $(TS_FILES)

check: shell-fmt-check shell-lint ts-fmt-check ## Run shell and TypeScript checks

prek: ## Run all pre-commit hooks
	prek run --all-files

prek-install: ## Install prek's Git hooks
	prek install

check-versions: ## Report stale pinned versions in .chezmoiexternals/*.toml files
	@./scripts/check-versions.sh ./recipes
