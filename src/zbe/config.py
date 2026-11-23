"""Carga de la configuración de fases desde config/fases.yaml."""

from __future__ import annotations

import datetime as dt
from dataclasses import dataclass
from pathlib import Path

import yaml

RAIZ = Path(__file__).resolve().parents[2]
FICHERO_FASES = RAIZ / "config" / "fases.yaml"
ESTADOS = {"verificado", "aproximado", "pendiente"}


@dataclass(frozen=True)
class Fase:
    id: str
    nombre: str
    inicio: dt.date
    fuente: str
    estado: str
    fin: dt.date | None = None


def _a_fase(d: dict) -> Fase:
    if d["estado"] not in ESTADOS:
        raise ValueError(f"Estado desconocido en {d['id']}: {d['estado']}")
    return Fase(
        id=d["id"],
        nombre=d["nombre"],
        inicio=d["inicio"],
        fin=d.get("fin"),
        fuente=d["fuente"],
        estado=d["estado"],
    )


def cargar_fases(ruta: Path = FICHERO_FASES) -> tuple[list[Fase], list[Fase]]:
    """Devuelve (fases, exclusiones), cada lista ordenada por fecha de inicio."""
    with open(ruta, encoding="utf-8") as f:
        datos = yaml.safe_load(f)
    fases = sorted((_a_fase(d) for d in datos["fases"]), key=lambda f: f.inicio)
    exclusiones = sorted((_a_fase(d) for d in datos["exclusiones"]), key=lambda f: f.inicio)
    return fases, exclusiones


def main() -> None:
    fases, exclusiones = cargar_fases()
    print("Fases:")
    for f in fases:
        print(f"  {f.inicio}  {f.nombre}  [{f.estado}]")
    print("Exclusiones:")
    for f in exclusiones:
        print(f"  {f.inicio} a {f.fin}  {f.nombre}  [{f.estado}]")


if __name__ == "__main__":
    main()
