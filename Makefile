.PHONY: dev clean backup list dump restore delete recreate traject

dev:
	docker compose up -d --build solr && \
	docker compose run --rm --build etl && \
	docker compose up -d --build blacklight

clean:
	docker compose down --rmi all --volumes --remove-orphans && \
	rm -rf ./solr_backend/data && \
	rm -rf ./etl/data/dumps && \
	rm -rf ./etl/data/cores

backup-core restore-core delete-core recreate-core list-cores swap-cores create-core reload-core backup dump restore list:
	docker compose run --rm etl python3 ./fetch/backup.py $@ $(filter-out $@,$(MAKECMDGOALS))

traject:
	docker compose run --rm etl

# Swallow extra args so make doesn’t error out
%:
	@:
