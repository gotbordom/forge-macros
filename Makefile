SHELL := /bin/bash
.DEFAULT_GOAL := help

# -----------------------------
# Config (override as needed)
# -----------------------------
PROJECT_NAME ?= forge-macros
WORKDIR ?= /work

# Images
DEV_IMAGE ?= $(PROJECT_NAME)-dev
CI_IMAGE  ?= $(PROJECT_NAME)-ci

# Container
DEV_CONTAINER ?= $(PROJECT_NAME)-dev
PNPM_STORE_VOL ?= $(PROJECT_NAME)-pnpm-store

# Dockerfiles
DOCKERFILE_DEV ?= docker/Dockerfile.dev
DOCKERFILE_CI  ?= docker/Dockerfile.ci

# Forge token passthrough (optional; used only when you run forge commands)
# export FORGE_API_TOKEN=...
FORGE_ENV_VARS := -e FORGE_API_TOKEN

# Mount the repo + use a named volume for pnpm store to speed installs
DOCKER_RUN_MOUNTS := -v "$(CURDIR)":$(WORKDIR) -v "$(PNPM_STORE_VOL)":/root/.pnpm-store
DOCKER_RUN_COMMON := docker run --rm -it $(FORGE_ENV_VARS) $(DOCKER_RUN_MOUNTS) -w $(WORKDIR) $(DEV_IMAGE)

# -----------------------------
# Helpers
# -----------------------------
define ensure_container_running
	@if ! docker ps --format '{{.Names}}' | grep -q '^$(DEV_CONTAINER)$$'; then \
		echo ">>> Container '$(DEV_CONTAINER)' is not running. Starting it..."; \
		$(MAKE) restart; \
	fi
endef

# -----------------------------
# Help
# -----------------------------
help:
	@echo "Forge Macro Development Commands"
	@echo "================================="
	@echo ""
	@echo "Setup Commands:"
	@echo "  make build          - Build all Docker images (base + dev)"
	@echo "  make build-dev      - Build only the dev image"
	@echo "  make build-ci       - Build only the CI image"
	@echo ""
	@echo "Container Management:"
	@echo "  make shell          - Open a shell in the container"
	@echo "  make stop           - Stop the container"
	@echo "  make restart        - Restart the container"
	@echo "  make clean          - Remove container (keeps image)"
	@echo ""
	@echo "Testing & Quality:"
	@echo "  make lint           - Run ESLint"
	@echo "  make lint-fix       - Run ESLint and auto-fix issues"
	@echo "  make test           - Run unit tests"
	@echo ""

# -----------------------------
# Setup Commands
# -----------------------------
build: build-dev build-ci

build-dev:
	@echo ">>> Building dev image: $(DEV_IMAGE)"
	DOCKER_BUILDKIT=1 docker build -f "$(DOCKERFILE_DEV)" -t "$(DEV_IMAGE)" .

build-ci:
	@echo ">>> Building CI image: $(CI_IMAGE)"
	DOCKER_BUILDKIT=1 docker build -f "$(DOCKERFILE_CI)" -t "$(CI_IMAGE)" .

# -----------------------------
# Container Management
# -----------------------------
restart:
	@echo ">>> Restarting container: $(DEV_CONTAINER)"
	-@docker rm -f "$(DEV_CONTAINER)" >/dev/null 2>&1 || true
	@docker volume create "$(PNPM_STORE_VOL)" >/dev/null
	@docker run -d \
		--name "$(DEV_CONTAINER)" \
		$(FORGE_ENV_VARS) \
		$(DOCKER_RUN_MOUNTS) \
		-w "$(WORKDIR)" \
		"$(DEV_IMAGE)" \
		sh -c "while true; do sleep 3600; done" >/dev/null
	@echo ">>> Container started. Use 'make shell' to enter."

shell:
	@$(call ensure_container_running)
	@echo ">>> Opening shell in container: $(DEV_CONTAINER)"
	@docker exec -it "$(DEV_CONTAINER)" bash

stop:
	@echo ">>> Stopping container: $(DEV_CONTAINER)"
	-@docker stop "$(DEV_CONTAINER)" >/dev/null 2>&1 || true

clean:
	@echo ">>> Removing container (keeping images): $(DEV_CONTAINER)"
	-@docker rm -f "$(DEV_CONTAINER)" >/dev/null 2>&1 || true

# -----------------------------
# Testing & Quality
# -----------------------------
lint:
	@$(call ensure_container_running)
	@echo ">>> Running ESLint (container): $(DEV_CONTAINER)"
	@docker exec -it "$(DEV_CONTAINER)" sh -lc "pnpm -w -r run lint"

lint-fix:
	@$(call ensure_container_running)
	@echo ">>> Running ESLint --fix (container): $(DEV_CONTAINER)"
	@docker exec -it "$(DEV_CONTAINER)" sh -lc "pnpm -w -r run lint -- --fix || pnpm -w -r run lint:fix || true"

test:
	@$(call ensure_container_running)
	@echo ">>> Running unit tests (container): $(DEV_CONTAINER)"
	@docker exec -it "$(DEV_CONTAINER)" sh -lc "pnpm -w -r run test"

# -----------------------------
# Optional convenience targets (not shown in help)
# -----------------------------
install:
	@$(call ensure_container_running)
	@echo ">>> Installing dependencies (container): $(DEV_CONTAINER)"
	@docker exec -it "$(DEV_CONTAINER)" sh -lc "pnpm install --frozen-lockfile"

build-workspace:
	@$(call ensure_container_running)
	@echo ">>> Building workspace (container): $(DEV_CONTAINER)"
	@docker exec -it "$(DEV_CONTAINER)" sh -lc "pnpm -w -r run build"
