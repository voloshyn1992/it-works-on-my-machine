build:
	docker compose -f docker-compose.yml build --no-cache --force-rm --parallel
	docker compose up --remove-orphans --force-recreate -d
exec:
	docker exec -it app-js sh
up:
	docker compose up -d
down:
	docker compose down
