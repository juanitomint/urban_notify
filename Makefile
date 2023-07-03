IMAGE_REPOSITORY  ?= juanitomint/urban_notify
CURRENT_DIR = $(shell pwd)
GIT_LAST_TAG=$(shell git tag --sort=committerdate|tail -n 1)
GIT_COMMIT=$(shell git rev-parse --short HEAD)
GIT_TAG         ?=$(or ${CI_COMMIT_TAG},$(or ${GIT_LAST_TAG}, ${GIT_COMMIT} ) )
IMAGE_TAG         ?= ${GIT_TAG}
help:
	@grep -E '^[\/a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'	
.PHONY: docker-build
docker-build: ## Build docker image using latest as cache
	echo "building: ${IMAGE_REPOSITORY}:${IMAGE_TAG}"
	# docker pull ${IMAGE_REPOSITORY}:latest || true
	DOCKER_BUILDKIT=1 docker build  -t ${IMAGE_REPOSITORY}:latest . --build-arg IMAGE_TAG=${IMAGE_TAG}
	docker tag ${IMAGE_REPOSITORY}:latest ${IMAGE_REPOSITORY}:${IMAGE_TAG}
  
.PHONY: docker-push 
docker-push: ## Push docker image to remote ${IMAGE_REPOSITORY}
	docker push ${IMAGE_REPOSITORY}:${IMAGE_TAG}
	docker push ${IMAGE_REPOSITORY}:latest

.PHONY: docker-test
docker-test: ## test file using docker image and .env variables
	docker run -it --rm -v \${CURRENT_DIR}:/workspace --env-file .env -p 5000:5000	${IMAGE_REPOSITORY}:latest

.PHONY: docker-test-bash
docker-test-bash: ## test the docker image but gives yuou a shell
	docker run -it --rm -v \${CURRENT_DIR}:/workspace --env-file .env	${IMAGE_REPOSITORY}:latest bash

.PHONY: deps
deps:  ## config virtual env and install dependencies using poetry
	pip install poetry
	poetry config virtualenvs.in-project true
	poetry config virtualenvs.create true
	poetry install
.PHONY: local
local: ## installs pre-commit hook (WIP)
	poetry run pre-commit install

.PHONY: lint 
lint: ## Show code lints using black flake8 and isort
	poetry run flake8 ./
	poetry run black ./ --check
	poetry run isort ./ --check

.PHONY: fix
fix: ## Fix code lints using black flake8 and isort
	poetry run black ./ 
	poetry run flake8 ./
	poetry run isort ./ 



.PHONY: openapi
openapi: ## update openapi definitions
	
	FLASK_APP=main flask openapi update

.PHONY: cover
cover: ## runs tests
	poetry run coverage run -m unittest discover

.PHONY: cover/report
cover/report: ## Shows coverage Report
	poetry run coverage report

.PHONY: cover/xml
cover/xml: ## Creates coverage Report
	poetry run coverage xml

.PHONY: clean
clean: ## Clean up local environment and caches
	rm -rf ./.venv
	rm -rf ./.pytest_cache
	rm -rf ./__pycache__
	rm -rf tests/__pycache__
	rm -rf api/__pycache__
.PHONY: printvars
printvars: ## Prints make variables
	$(foreach V, $(sort $(.VARIABLES)), \
	$(if $(filter-out environment% default automatic, $(origin $V)),$(warning $V=$($V) ($(value $V)))) \
	)