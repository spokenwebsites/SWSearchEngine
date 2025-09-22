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

create-snapshot restore-core delete-core list-snapshots swap-cores create-core reload-core traject backup dump restore list backup-help env:
	docker compose run --rm etl python3 ./fetch/backup.py $@ $(filter-out $@,$(MAKECMDGOALS))

create-configset:
	zip -r etl/configsets/$(filter-out $@,$(MAKECMDGOALS)).zip ./solr_backend/conf

# Swallow extra args so make doesn’t error out
%:
	@:
