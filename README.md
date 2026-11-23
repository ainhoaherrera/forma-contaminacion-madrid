# La forma de la contaminación en Madrid

> **Pregunta:** ¿qué cambió en el NO2 de Madrid con Madrid Central, la ZBE de Distrito Centro y la ZBE de toda la ciudad? ¿Bajó la contaminación o solo se movió a los barrios del borde?
>
> **Respuesta:** _pendiente (aquí irá la conclusión en una frase, con su número e intervalo)._

## Qué hace este proyecto

1. **Inferencia causal** con los datos horarios de las estaciones de calidad del aire del Ayuntamiento de Madrid: efecto de cada fase sobre el NO2, separado de la tendencia, la meteorología y el covid (diferencias en diferencias, control sintético, BSTS y un modelo bayesiano jerárquico).
2. **Homología persistente** sobre el campo de NO2 para ver si los focos se fragmentan o se desplazan hacia el borde, con pruebas de robustez frente a la interpolación.

## Cómo reproducirlo

Solo necesitas [Docker](https://docs.docker.com/get-docker/).

```bash
docker compose build              # construye la imagen
docker compose run --rm tests     # ejecuta los tests
docker compose run --rm pipeline  # ejecuta el pipeline
```

O con `make build`, `make test` y `make run`.

## Estructura

```
config/fases.yaml   fechas de cada fase, con fuente y estado de verificación
src/zbe/            código del pipeline (ingesta, deweathering, causal, tda)
tests/              tests
data/               datos descargados (no se suben al repositorio)
notebooks/          exploración
reports/            informe final
docs/               notas, incluida la guía de Docker
```

## Estado

- [x] Fase 0: esqueleto, Docker y CI
- [ ] Fase 1: ingesta y limpieza
- [ ] Fase 2: deweathering
- [ ] Fase 3: inferencia causal
- [ ] Fase 4: topología
- [ ] Fase 5: informe y comunicación

## Datos

- Calidad del aire: [Ayuntamiento de Madrid, datos horarios desde 2001](https://datos.madrid.es/dataset/201200-0-calidad-aire-horario) (CC BY 4.0).
- Meteorología: ERA5 vía [Open-Meteo](https://open-meteo.com/en/docs/historical-weather-api).
