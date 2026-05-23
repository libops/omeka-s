.PHONY: build deps init init-if-needed up down rollout test lint

deps:
	docker compose pull --ignore-buildable

build: deps
	docker compose build --pull

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

test:
	./scripts/test.sh

lint:
	./scripts/lint.sh
