.PHONY: bootstrap-claude

bootstrap-claude:
	@_bs="$$(dirname $(CURDIR))/contextus-claude/bootstrap.sh"; \
	[ -f "$$_bs" ] || _bs=".contextus/contextus-claude/bootstrap.sh"; \
	[ -f "$$_bs" ] || { echo "error: bootstrap.sh not found (contextus-claude sibling or .contextus/)" >&2; exit 1; }; \
	"$$_bs"
