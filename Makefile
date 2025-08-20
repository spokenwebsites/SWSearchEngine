dev:
	docker compose up -d --build solr && \
	docker compose run --rm --build etl && \
	docker compose up -d --build blacklight

clean:
	 docker compose down --rmi all --volumes --remove-orphans
