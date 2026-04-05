## Devcontainer tooling

_DEVCONTAINER_TOOLING_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

.PHONY: devcontainer.setup devc.up devc.down devc.restart devc.rebuild devc.logs devc.shell devc.exec devc.ps devc.clean devc.install-toolings

devcontainer.setup: ## Setup devcontainer.json in .devcontainer/ directory
	@echo "Setting up devcontainer.json from template..."
	@mkdir -p .devcontainer
	@cp $(_DEVCONTAINER_TOOLING_DIR)devcontainer/devcontainer.json.template .devcontainer/devcontainer.json
	@echo "✓ Created .devcontainer/devcontainer.json"
	@echo "  You can now customize it for your project needs."

# Devcontainer orchestration tasks
# These require variables from commons.mk: DOCKER_COMPOSE, DEVC_SERVICE, _ensure-tooling-env

devc.up: _ensure-tooling-env ## Start the devcontainer
	$(DOCKER_COMPOSE) up -d --build

devc.down: ## Stop the devcontainer
	$(DOCKER_COMPOSE) down

devc.restart: devc.down devc.up ## Restart the devcontainer (uses cached image)

devc.rebuild: devc.down ## Rebuild and restart the devcontainer (forces full rebuild, no cache)
	@echo "Rebuilding image from scratch (no cache)..."
	$(DOCKER_COMPOSE) build --no-cache
	$(DOCKER_COMPOSE) up -d

devc.logs: _ensure-tooling-env ## Show devcontainer logs
	$(DOCKER_COMPOSE) logs -f

devc.shell: _ensure-tooling-env ## Open a shell in the devcontainer
	$(DOCKER_COMPOSE) exec $(DEVC_SERVICE) bash

devc.exec: _ensure-tooling-env ## Execute a command in the devcontainer: make devc.exec CMD="command here"
	@if [ -z "$(CMD)" ]; then \
		echo "Usage: make devc.exec CMD=\"command here\""; \
		exit 1; \
	fi
	$(DOCKER_COMPOSE) exec $(DEVC_SERVICE) bash -c "$(CMD)"

devc.ps: ## Show status of devcontainers
	$(DOCKER_COMPOSE) ps

devc.clean: devc.down ## Clean up containers, networks, and volumes
	$(DOCKER_COMPOSE) down -v --remove-orphans

devc.install-toolings: _ensure-tooling-env ## Install/reinstall tooling extensions in the devcontainer
	$(DOCKER_COMPOSE) exec $(DEVC_SERVICE) bash /workspace/tooling/devcontainer-tooling/devcontainer/install-toolings.sh
