import datetime as dt

from zbe.config import cargar_fases


def test_fases_ordenadas_y_con_fuente():
    fases, _ = cargar_fases()
    assert len(fases) >= 5
    assert [f.inicio for f in fases] == sorted(f.inicio for f in fases)
    assert all(f.fuente.startswith("https://") for f in fases)


def test_madrid_central_empieza_el_30_de_noviembre_de_2018():
    fases, _ = cargar_fases()
    mc = next(f for f in fases if f.id == "madrid_central_aviso")
    assert mc.inicio == dt.date(2018, 11, 30)


def test_exclusiones_tienen_fin_posterior_al_inicio():
    _, exclusiones = cargar_fases()
    assert all(e.fin is not None and e.fin > e.inicio for e in exclusiones)
