build:
	docker compose -f docker-compose.yml build --no-cache --force-rm --parallel
	docker compose up --remove-orphans --force-recreate -d
build-prod:
	docker network create app-network
	docker compose -f docker-compose-prod.yml -p app-go-prod build --no-cache --force-rm --parallel
	docker compose up --remove-orphans --force-recreate -d
exec:
	docker exec -it app-go sh
retrieve-data:
	./dump.sh
up:
	docker compose up -d
down:
	docker compose down