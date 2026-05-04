.PHONY: dev clean create-configset create-snapshot restore-core delete-core list-snapshots swap-cores create-core reload-core traject backup dump restore list backup-help env


dev:
	@if [ ! -f .env ]; then \
		echo "==> .env not found — creating from .env.example"; \
		cp .env.example .env; \
		SECRET=$$(openssl rand -hex 64); \
		sed -i.bak "s|^SECRET_KEY_BASE=.*|SECRET_KEY_BASE=$$SECRET|" .env && rm -f .env.bak; \
		echo "==> Generated fresh SECRET_KEY_BASE in .env"; \
		echo "    For production, also update DB_PASSWORD in .env before continuing."; \
	fi
	docker compose up -d --build postgres solr blacklight
	docker compose run --rm --build etl

clean:
	docker compose down --rmi all --volumes --remove-orphans && \
	rm -rf ./solr_backend/data && \
	rm -rf ./etl/data/dumps && \
	rm -rf ./etl/data/cores

fetch:
	docker compose run --rm etl ./fetch.sh

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
