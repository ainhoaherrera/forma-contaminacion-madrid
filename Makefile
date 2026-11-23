# Atajos. "make <objetivo>" ejecuta las órdenes de debajo.
.PHONY: build test run lint clean

build:   ## Construye las imágenes
	docker compose build

test:    ## Ejecuta los tests dentro del contenedor
	docker compose run --rm tests

run:     ## Ejecuta el pipeline (por ahora: muestra las fases)
	docker compose run --rm pipeline

lint:    ## Revisa estilo en local (sin Docker)
	uv run --group dev ruff check src tests

clean:   ## Borra contenedores parados e imágenes sin usar
	docker compose down --remove-orphans
	docker image prune -f
