# Docker paso a paso (Fase 0)

Esta guía explica lo que hay en este repositorio y cómo usarlo. Está pensada para leerla con el `Dockerfile` abierto al lado.

## 1. Las tres ideas que necesitas

- **Imagen:** una "foto" de un sistema con Python, tus librerías y tu código. Se construye una vez con `docker build` y es de solo lectura.
- **Contenedor:** una ejecución de esa imagen. Se crea con `docker run`, hace su trabajo y (con `--rm`) desaparece. Lo que escriba dentro se pierde, salvo en volúmenes.
- **Volumen:** una carpeta de tu ordenador montada dentro del contenedor. Aquí, `./data` se monta en `/app/data`, así que los datos descargados se quedan en tu disco y no viven en la imagen.

Analogía matemática: la imagen es la definición de una función, el contenedor es una evaluación, y los volúmenes son los argumentos y el valor de retorno.

## 2. Instalar y comprobar

1. Instala [Docker Desktop](https://docs.docker.com/get-docker/) (Mac o Windows) o Docker Engine (Linux).
2. Comprueba que funciona:

```bash
docker --version
docker run --rm hello-world
```

## 3. Construir y ejecutar este proyecto

```bash
cd forma-contaminacion-madrid
docker compose build              # construye las dos imágenes (dev y test)
docker compose run --rm tests     # 3 tests deberían pasar
docker compose run --rm pipeline  # imprime las fases leídas de config/fases.yaml
```

La primera vez tarda uno o dos minutos (descarga Python y dependencias). La segunda, segundos, gracias a la caché.

## 4. Leer el Dockerfile

El `Dockerfile` tiene tres **etapas** (multi-stage build):

| Etapa | Para qué | Llega a la imagen final |
| --- | --- | --- |
| `builder` | Instala `uv` y las dependencias en `/opt/venv` | No |
| `test` | Parte de `builder` y añade pytest y ruff | No (es otra imagen, la de tests) |
| `runtime` | Copia solo `/opt/venv` y tu código | Sí |

Así la imagen final no lleva herramientas de construcción ni de test.

**El orden de las capas.** Primero se copian `pyproject.toml` y `uv.lock` y se instalan dependencias; después se copia `src/`. Si solo cambias código, Docker reutiliza la capa de dependencias. Pruébalo:

```bash
echo "# cambio" >> src/zbe/__init__.py
docker compose build              # verás CACHED en la instalación de dependencias
git checkout src/zbe/__init__.py
```

**`.dockerignore`.** Evita mandar `data/`, `.git` y cachés al build. Sin él, cada build copiaría cientos de MB de datos.

**Usuario sin privilegios.** La imagen final ejecuta como `analista`, no como root. Compruébalo con `docker compose run --rm pipeline whoami`.

## 5. docker compose

`docker-compose.yml` define dos servicios:

- `pipeline`: la imagen final, con `./data` y `./config` montados.
- `tests`: la etapa `test` del Dockerfile, con `./tests` montado (puedes editar tests sin reconstruir).

`make build`, `make test` y `make run` son atajos de lo mismo.

## 6. Ejercicios para afianzarlo

1. Ejecuta una shell dentro del contenedor y explora: `docker compose run --rm pipeline bash`. Mira `/app`, `/opt/venv` y `ls -la /app/data`.
2. Crea un fichero en `/app/data` desde el contenedor (`touch /app/data/prueba.txt`), sal, y comprueba que aparece en tu carpeta `data/`. Crea otro en `/tmp` y comprueba que desaparece.
3. Mira el tamaño de las imágenes con `docker images | grep forma` y la historia de capas con `docker history forma-contaminacion-madrid:dev`.
4. Añade `scipy` a las dependencias, ejecuta `uv lock` y reconstruye: verás que ahora sí se reinstalan las dependencias.

## 7. Qué viene en las siguientes fases

- **Fase 1:** el servicio `pipeline` descargará los datos a `./data/raw`.
- **Fase 3:** construiremos con `--build-arg EXTRAS="--extra causal"` para meter PyMC y compañía solo cuando hagan falta, y fijaremos semillas para que los resultados bayesianos sean reproducibles.
- **Fase 5:** GitHub Actions (`.github/workflows/ci.yml`) ya construye la imagen y ejecuta los tests en cada push; añadiremos la publicación del informe.
