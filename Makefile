.PHONY: list sync

list:
	@jq -r '.projects | keys[]' sync.json

sync:
	@if [ -z "$(PROJECT)" ]; then \
		echo "❌ Usage: make sync PROJECT=project-a"; \
		exit 1; \
	fi
	@./sync.sh $(PROJECT)

