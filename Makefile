DOCKER_COMPOSE=docker compose

.PHONY: up-all front-back monitoring

up-all:
	$(DOCKER_COMPOSE) -f ./backend/docker-compose.yml -f ./frontend/docker-compose.yml -f ./monitoring/docker-compose.yml up -d

front-back:
	$(DOCKER_COMPOSE) -f ./backend/docker-compose.yml -f ./frontend/docker-compose.yml up -d

monitoring:
	$(DOCKER_COMPOSE) -f ./monitoring/docker-compose.yml up -d

down:
	$(DOCKER_COMPOSE) down
