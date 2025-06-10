DOCKER_COMPOSE=docker compose

.PHONY: up-all front-back monitoring

up-all:
	$(DOCKER_COMPOSE) -f ./backend/docker-compose.yml -f ./frontend/docker-compose.yml -f ./monitoring/docker-compose.yml up -d

up-front-back:
	$(DOCKER_COMPOSE) -f ./backend/docker-compose.yml -f ./frontend/docker-compose.yml up -d

down-front-back:
	$(DOCKER_COMPOSE) -f ./backend/docker-compose.yml -f ./frontend/docker-compose.yml down

up-monitoring:
	$(DOCKER_COMPOSE) -f ./monitoring/docker-compose.yml up -d

down-monitoring:
	$(DOCKER_COMPOSE) -f ./monitoring/docker-compose.yml down

down-all:
	$(DOCKER_COMPOSE) -f ./backend/docker-compose.yml -f ./frontend/docker-compose.yml -f ./monitoring/docker-compose.yml down

create-app-network:
	docker network create app-network

