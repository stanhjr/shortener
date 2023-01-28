.PHONY: all \
		help \
		build \
		up \
		down \
		logs \
		clean \
		reload \
		format \
		verify_format \
		lint \
		test \
		run \
		bash \
		makemigrations \
		static

RUN_IN_DEVTOOLS_CONTAINER=docker-compose run --rm -u `id -u`:`id -u` api
RUN_IN_DEVTOOLS_CONTAINER_PYTEST=docker-compose run --rm -u `id -u`:`id -u` -e "TEST_RUNNER=pytest" api

# target: all - Default target. Does nothing.
all:
	@echo "Hello $(LOGNAME), nothing to do by default"
	@echo "Try 'make help'"

# target: help - Display callable targets.
help:
	@egrep "^# target:" [Mm]akefile

# Docker commands
# target: build - build images.
build:
	COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker-compose build

# target: up - up services.
up:
	docker-compose up -d

# target: down - destroy services.
down:
	docker-compose down

# target: logs - show logs from services.
logs:
	docker-compose logs -f

# target: clean - remove all dangling images and old volumes data.
clean:
	docker system prune -f

# target: stop - stop some services services.
stop:
	docker-compose stop

# target: reload - restart api service.
reload:
	docker-compose restart api

# Linting and formatting
# target: format - run black and isort for style formatting on project python code.
format:
	$(RUN_IN_DEVTOOLS_CONTAINER) black .
	$(RUN_IN_DEVTOOLS_CONTAINER) isort .

# target: verify_format - check formatting
verify_format:
	$(RUN_IN_DEVTOOLS_CONTAINER) black --check .

# target: lint - run flake8 linter for validation.
lint:
	$(RUN_IN_DEVTOOLS_CONTAINER) flake8 --show-source

unittest:
	$(RUN_IN_DEVTOOLS_CONTAINER_PYTEST) coverage run --source='.' manage.py test
	$(RUN_IN_DEVTOOLS_CONTAINER_PYTEST) coverage html
	$(RUN_IN_DEVTOOLS_CONTAINER_PYTEST) coverage report
# target: test - run verify_format, lint and unittest commands.

test: verify_format lint unittest

ifeq (run,$(firstword $(MAKECMDGOALS)))
  # use the rest as arguments for "run"
  RUN_COMMAND_IN_DJANGO := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # ...and turn them into do-nothing targets
  $(eval $(RUN_COMMAND_IN_DJANGO):;@:)
endif

# target: bash - run bash in container
bash:
	$(RUN_IN_DEVTOOLS_CONTAINER) bash

# Django Commands
# target: makemigrations - run django makemigrations command.
makemigrations:
	$(RUN_IN_DEVTOOLS_CONTAINER) ./manage.py makemigrations

# target: static - run django collect static command.
static:
	$(RUN_IN_DEVTOOLS_CONTAINER) ./manage.py collectstatic --noinput


# target: migrate - run django migrate
migrate:
	$(RUN_IN_DEVTOOLS_CONTAINER) ./manage.py migrate

# target: run - runs ./manage.py args in dev container. Example: make run shell
run:
	$(RUN_IN_DEVTOOLS_CONTAINER) ./manage.py $(RUN_COMMAND_IN_DJANGO)
