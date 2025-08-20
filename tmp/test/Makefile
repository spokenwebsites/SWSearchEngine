build:
	docker compose run --rm --build test

run:
	docker compose run --rm test ruby update.rb

dev:
	docker compose run --rm --remove-orphans --build test && \
	docker compose watch
