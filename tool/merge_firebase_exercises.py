#!/usr/bin/env python3
"""Append missing Firebase exercise names to the local image catalog."""

import json
import re
import unicodedata
from pathlib import Path

CATALOG = Path("assets/data/exercises.json")
AUDIT = Path("assets/data/firebase_exercise_audit.json")


def normalize(value: str) -> str:
    value = unicodedata.normalize("NFD", value.lower())
    value = "".join(char for char in value if unicodedata.category(char) != "Mn")
    return re.sub(r"[^a-z0-9]+", " ", value).strip()


def slug(value: str) -> str:
    return normalize(value).replace(" ", "_")


def muscle(name: str) -> str:
    key = normalize(name)
    if any(word in key for word in ("chest", "cross", "press banca", "press inclinado")):
        return "Pecho"
    if any(
        word in key
        for word in (
            "estocada",
            "hip thrust",
            "leg ",
            "abduccion",
            "aductor",
            "prensa",
            "sentadilla",
            "rodillo",
            "hiit",
        )
    ):
        return "Piernas"
    if any(
        word in key
        for word in (
            "biceps",
            "triceps",
            "hombro",
            "shoulder",
            "vuelo",
            "vuelos",
            "patada",
            "scott",
        )
    ):
        return "Hombro"
    return "Espalda"


def main() -> None:
    catalog = json.loads(CATALOG.read_text())
    report = json.loads(AUDIT.read_text())
    by_name = {normalize(item["nombre"]): item for item in catalog}
    next_id = max(item["id"] for item in catalog) + 1
    added = []

    firebase_names = [
        item["excel"]
        for item in report["faltantes"]
    ] + [
        item["excel"]
        for item in report["coincidencias"]
        if item["tipo"] != "exacta"
    ]
    for firebase_name in firebase_names:
        name = firebase_name.strip()
        key = normalize(name)
        if key in by_name:
            continue
        file_slug = slug(name)
        item = {
            "id": next_id,
            "nombre": name,
            "musculo": muscle(name),
            "imagen": f"{file_slug}_inicio.webp",
            "imagenes": {
                "inicio": f"{file_slug}_inicio.webp",
                "bajada": f"{file_slug}_bajada.webp",
                "subida": f"{file_slug}_subida.webp",
            },
            "series": "4",
            "repeticiones": "8-12",
            "origen": "Firebase",
        }
        catalog.append(item)
        by_name[key] = item
        added.append(item)
        next_id += 1

    CATALOG.write_text(json.dumps(catalog, ensure_ascii=False, indent=2) + "\n")
    print(json.dumps({"agregados": len(added), "total": len(catalog)}, ensure_ascii=False))


if __name__ == "__main__":
    main()
