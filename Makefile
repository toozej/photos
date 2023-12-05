# Set sane defaults for Make
SHELL = bash
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

# Set default goal such that `make` runs `make help`
.DEFAULT_GOAL := help

.PHONY: pre-reqs build serve docker help

pre-reqs: ## Install vite
	@go install -v github.com/toozej/go-vite@latest

build: ## Run vite build
	@go-vite build

serve: pre-reqs ## Run vite serve and auto-rebuild on changes
	-@killall go-vite
	@go-vite serve &
	@find pages/ static/ templates/ | entr go-vite build
	@trap SIGINT

docker: ## Build Docker image
	@docker build -t toozej/slapsandsnaps .

help: ## Display help text
	@grep -E '^[a-zA-Z_-]+ ?:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
