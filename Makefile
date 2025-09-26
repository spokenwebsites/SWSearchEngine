.PHONY: dev clean create-configset create-snapshot restore-core delete-core list-snapshots swap-cores create-core reload-core traject backup dump restore list backup-help env


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
	echo "\tZipping current configs set from ./solr_backend/conf"
	zip -r -j etl/data/configsets/$(filter-out $@,$(MAKECMDGOALS)).zip ./solr_backend/conf
	curl -X POST --header "Content-Type: application/octet-stream" \
		--data-binary etl/data/configsets/@$(filter-out $@,$(MAKECMDGOALS)).zip \
		"http://localhost:8983/solr/admin/configs?action=UPLOAD&name=$(filter-out $@,$(MAKECMDGOALS))" 

# Swallow extra args so make doesn’t error out
%:
	@:
