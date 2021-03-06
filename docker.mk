include .env

.PHONY: up down stop prune ps shell drush logs

default: up

DRUPAL_ROOT ?= /var/www/html/web
DOCKER_COMPOSE_FILES ?= -f docker-compose.yml -f docker-compose.ports.yml -f docker-compose.win.yml -f docker-compose.xdebug.yml

up:
	@echo "Starting up containers for $(PROJECT_NAME)..."
	docker-compose $(DOCKER_COMPOSE_FILES) pull --parallel
	docker-compose $(DOCKER_COMPOSE_FILES) up -d --remove-orphans

down: stop

stop:
	@echo "Stopping containers for $(PROJECT_NAME)..."
	@docker-compose stop

prune:
	@echo "Removing containers for $(PROJECT_NAME)..."
	@docker-compose down -v

ps:
	@docker ps --filter name='$(PROJECT_NAME)*'

shell:
	docker exec -ti -e COLUMNS=$(shell tput cols) -e LINES=$(shell tput lines) $(shell docker ps --filter name='$(PROJECT_NAME)_php' --format "{{ .ID }}") sh

drush:
	docker exec $(shell docker ps --filter name='$(PROJECT_NAME)_php' --format "{{ .ID }}") drush -r $(DRUPAL_ROOT) $(filter-out $@,$(MAKECMDGOALS))

logs:
	@docker-compose $(DOCKER_COMPOSE_FILES) logs -f $(filter-out $@,$(MAKECMDGOALS))

# https://stackoverflow.com/a/6273809/1826109
%:
	@:
