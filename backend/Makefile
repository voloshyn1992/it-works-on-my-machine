build:
	docker compose -f docker-compose.yml build --no-cache --force-rm --parallel
	docker compose up --remove-orphans --force-recreate -d
exec:
	docker exec -it app-go sh
retrieve-data:
	./dump.sh