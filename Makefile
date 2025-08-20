dev:
	docker compose up -d

clean:
	 docker compose down --rmi all --volumes --remove-orphans
