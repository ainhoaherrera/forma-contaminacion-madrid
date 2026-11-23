# syntax=docker/dockerfile:1
#
# Imagen del proyecto. Cada instrucción crea una "capa"; Docker reutiliza
# (cachea) una capa si ni la instrucción ni los ficheros que copia cambiaron.
# Por eso el orden importa: primero lo que cambia poco (dependencias),
# después lo que cambia mucho (tu código).

# ---------------------------------------------------------------------------
# Etapa 1: "builder". Instala dependencias en un entorno virtual.
# ---------------------------------------------------------------------------
FROM python:3.12-slim AS builder

# uv es un gestor de paquetes rápido. Lo instalamos con pip, versión fijada.
RUN pip install --no-cache-dir uv==0.5.11

# Compilar a bytecode y copiar (no enlazar) archivos: arranque más rápido
# y un entorno que se puede mover entre etapas.
ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_PROJECT_ENVIRONMENT=/opt/venv

WORKDIR /app

# EXTRAS permite elegir qué grupos de librerías entran en la imagen.
# Por defecto ninguno; más adelante: docker compose build --build-arg EXTRAS="--extra causal"
ARG EXTRAS=""

# 1) Solo los ficheros de dependencias. Si no tocas pyproject.toml ni uv.lock,
#    esta capa sale de la caché y el build tarda segundos.
COPY pyproject.toml uv.lock ./
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-install-project $EXTRAS

# 2) Ahora el código, que es lo que cambia a menudo.
COPY README.md ./
COPY src ./src
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen $EXTRAS

# ---------------------------------------------------------------------------
# Etapa "test": parte de builder y añade pytest y ruff. No llega a la imagen final.
# ---------------------------------------------------------------------------
FROM builder AS test
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --group dev $EXTRAS
ENV PATH="/opt/venv/bin:$PATH"
COPY tests ./tests
COPY config ./config
CMD ["pytest", "-q"]

# ---------------------------------------------------------------------------
# Etapa 2: "runtime". Solo lo necesario para ejecutar: sin uv ni cachés.
# ---------------------------------------------------------------------------
FROM python:3.12-slim AS runtime

# Usuario sin privilegios: buena práctica, el contenedor no corre como root.
RUN useradd --create-home --uid 1000 analista

COPY --from=builder /opt/venv /opt/venv
COPY --chown=analista:analista . /app

ENV PATH="/opt/venv/bin:$PATH" \
    PYTHONUNBUFFERED=1 \
    PYTHONHASHSEED=0

WORKDIR /app
USER analista

# Orden por defecto si haces "docker run" sin argumentos.
CMD ["python", "-m", "zbe.config"]
