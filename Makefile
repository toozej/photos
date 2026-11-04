# Set sane defaults for Make
SHELL = bash
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

# Set default goal such that `make` runs `make help`
.DEFAULT_GOAL := help

# Allow users to set environment variables to customize behavior, e.g. `make serve OPEN=true` to automatically open in browser
OPEN ?=

# Helper functions
OS = $(shell uname -s)
ifeq ($(OS), Linux)
	OPENER = $(shell command -v xdg-open && xdg-open || echo "echo")
	BIND_ADDRESS = $(shell ip addr | grep 192 | awk '{print $$2}' | cut -d '/' -f 1)
	HOSTNAME = $(shell hostname -f)
else ifeq ($(OS), Darwin)
	OPENER = open
	BIND_ADDRESS = 0.0.0.0
	HOSTNAME = $(shell hostname -f)
else
	OPENER = open
	BIND_ADDRESS = localhost
	HOSTNAME = localhost
endif

.PHONY: all pre-reqs update-hugo-version pre-commit pre-commit-install pre-commit-run build deploy serve serve-docker run debug clean test help

all: pre-reqs update-hugo-version pre-commit clean build serve ## Default workflow

pre-reqs: #pre-commit-install ## Install pre-commit hooks and necessary binaries
	command -v hugo || (command -v ports && sudo ports install -y hugo) || (command -v brew && brew install hugo) || curl --silent https://api.github.com/repos/gohugoio/hugo/releases/latest | grep "browser_download_url.*Linux-64bit.tar.gz" | grep "extended" | cut -d '"' -f 4 | wget -qO- -i - | tar -xz hugo && sudo mv hugo /usr/local/bin/hugo && sudo chmod +x /usr/local/bin/hugo && rm -f hugo_extended_*_Linux-64bit.tar.gz

update-hugo-version: ## Updates Hugo version used throughout repo to latest
	@OLD_VERSION="0.168.0" && \
	VERSION=`curl -s https://api.github.com/repos/gohugoio/hugo/releases/latest | jq -r '.html_url' | cut -d "/" -f 8 | tr -d "v"`; \
	if [[ "$$OLD_VERSION" != "$$VERSION" ]]; then \
		echo "Updating Hugo from $$OLD_VERSION to $$VERSION"; \
		echo "$(CURDIR)/docker-compose.yml $(CURDIR)/.devcontainer/devcontainer.json $(CURDIR)/Makefile" | xargs sed -i "" -e "s/$$OLD_VERSION/$$VERSION/g"; \
	else \
		echo "Already on current Hugo version $$VERSION"; \
	fi

build: ## Build website to "public" output directory
	hugo --gc --minify --cleanDestinationDir -d $(CURDIR)/public/

serve:  ## Run local web server (usage: `make serve OPEN=true` to automatically open in browser)
	@if [ "$(OPEN)" = "true" ]; then \
		$(OPENER) http://$(HOSTNAME):1313/ || echo "Open the following URL in a web browser: http://$(HOSTNAME):1313/"; \
	else \
		echo "Running local web server at http://$(HOSTNAME):1313/"; \
	fi
	rm -rf $(CURDIR)/public/*
	@hugo server --gc --minify --disableFastRender --bind=$(BIND_ADDRESS) --baseURL=http://$(HOSTNAME)/ --port=1313 --watch

serve-docker: ## Run Hugo server via Docker
	docker run --rm --name photos-hugo -p 1313:1313 --env-file $(CURDIR)/hugo.env -v $(CURDIR):/src --user $$(id -u):$$(id -g) floryn90/hugo:0.168.0-ext-alpine-onbuild server --gc --minify -p 1313 --watch

run: serve ## Run local web server

debug:  ## Run local web server
	hugo server --logLevel debug --disableFastRender --gc --ignoreCache --minify --bind=$(BIND_ADDRESS) --baseURL=http://$(HOSTNAME)/ --port=1313 --watch

pre-commit: pre-commit-install pre-commit-run ## Install and run pre-commit hooks

pre-commit-install: ## Install pre-commit hooks and necessary binaries
	# shellcheck
	command -v shellcheck || sudo dnf install -y ShellCheck || sudo apt install -y shellcheck || brew install shellcheck
	# checkmake
	go install github.com/checkmake/checkmake/cmd/checkmake@latest
	# syft
	command -v syft || curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin
	# pre-commit
	command -v pre-commit || brew install pre-commit || sudo dnf install -y pre-commit || sudo apt install -y pre-commit
	# install and update pre-commits
	pre-commit install
	pre-commit autoupdate

pre-commit-run: ## Run pre-commit hooks against all files
	pre-commit run --all-files
	# manually run the following checks since their pre-commits aren't working or don't exist

clean: ## Remove any locally built files
	rm -rf $(CURDIR)/public/*

help: ## Display help text
	@grep -E '^[a-zA-Z_-]+ ?:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
