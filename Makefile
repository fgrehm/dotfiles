# `.chezmoitemplates` holds fragments that are included into other templates
# and deployed inline, not standalone scripts, so they are excluded from the
# shell checks.
SHELL_FILES := $(shell find recipes home tests \( -name "*.sh" -o -name "*.sh.tmpl" -o -name "*.bash" \) -not -path "*/private_dot_ai/agent-skills/*" -not -path "*/.chezmoitemplates/*" 2>/dev/null | sort)

.DEFAULT_GOAL := help

.PHONY: help shell-fmt shell-fmt-check shell-lint test check prek prek-install check-versions init apply diff doctor

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

test: ## Run focused tests
	bash tests/whatsapp-extension.sh
	bash tests/chezmoi-target-paths.sh
	bash tests/omastats-install.sh
	bash tests/onepassword-ssh-keys.sh
	bash tests/preflight-1password.sh
	bash tests/ssh-agent-setup.sh

check: shell-fmt-check shell-lint test ## Run shell checks and focused tests

prek: ## Run all pre-commit hooks
	prek run --all-files

prek-install: ## Install prek's Git hooks
	prek install

check-versions: ## Report stale pinned versions in .chezmoiexternals/*.toml files
	@./scripts/check-versions.sh ./recipes
