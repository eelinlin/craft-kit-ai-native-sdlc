# One command per check so every Claude session can verify its own work.
# /craft:init replaces each placeholder with your stack's real command (or a stack pack's Makefile).
.PHONY: build test lint screens verify evals

build:
	@echo "TODO: build command" && exit 1

test:
	@echo "TODO: test command" && exit 1

lint:
	@echo "TODO: lint command" && exit 1

screens:
	@echo "TODO: screenshot command (or delete this target if there is no UI)" && exit 1

verify: build lint test
	@echo "verify: all checks passed"

evals:
	./evals/run.sh
