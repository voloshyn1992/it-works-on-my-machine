DOCKER_COMPOSE=docker compose

up:
	$(DOCKER_COMPOSE) up -d
down:
	$(DOCKER_COMPOSE) down
