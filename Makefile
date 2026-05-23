.PHONY: build deps init init-if-needed up down rollout test lint

deps:
	docker compose pull --ignore-buildable

build: deps
	docker compose build

init: build
	docker compose run --rm init

init-if-needed: build
	./scripts/init-if-needed.sh

up: init-if-needed
	docker compose up --remove-orphans -d

down:
	docker compose down

rollout:
	./scripts/rollout.sh

test: up
	./scripts/test.sh

lint:
	@docker compose config --format json | jq -e '.services["omeka-s"].image' | grep libops
	@if command -v json5 > /dev/null 2>&1; then json5 --validate renovate.json5 > /dev/null; fi
