#!/usr/bin/env python3
"""Compare exercise names stored in Firebase routines with the local catalog."""

import json
import re
import subprocess
import unicodedata
import urllib.parse
import urllib.request
from difflib import SequenceMatcher
from pathlib import Path

PROJECT_ID = "nexfit-gym"
CATALOG_PATH = Path("assets/data/exercises.json")
REPORT_PATH = Path("assets/data/firebase_exercise_audit.json")


def normalize(value: str) -> str:
    value = unicodedata.normalize("NFD", value.lower())
    value = "".join(char for char in value if unicodedata.category(char) != "Mn")
    return re.sub(r"[^a-z0-9]+", " ", value).strip()


def firestore_value(value):
    if "stringValue" in value:
        return value["stringValue"]
    if "integerValue" in value:
        return int(value["integerValue"])
    if "doubleValue" in value:
        return float(value["doubleValue"])
    if "booleanValue" in value:
        return value["booleanValue"]
    if "arrayValue" in value:
        return [firestore_value(item) for item in value["arrayValue"].get("values", [])]
    if "mapValue" in value:
        return {
            key: firestore_value(item)
            for key, item in value["mapValue"].get("fields", {}).items()
        }
    return None


def access_token() -> str:
    result = subprocess.run(
        ["firebase", "login:list", "--json"],
        check=True,
        capture_output=True,
        text=True,
    )
    payload = json.loads(result.stdout)
    return payload["result"][0]["tokens"]["access_token"]


def load_routines(token: str) -> list[dict]:
    documents = []
    page_token = ""
    while True:
        query = {"pageSize": "100"}
        if page_token:
            query["pageToken"] = page_token
        url = (
            "https://firestore.googleapis.com/v1/projects/"
            f"{PROJECT_ID}/databases/(default)/documents/routines?"
            f"{urllib.parse.urlencode(query)}"
        )
        request = urllib.request.Request(
            url, headers={"Authorization": f"Bearer {token}"}
        )
        with urllib.request.urlopen(request) as response:
            payload = json.load(response)
        for document in payload.get("documents", []):
            documents.append(
                {
                    key: firestore_value(value)
                    for key, value in document.get("fields", {}).items()
                }
            )
        page_token = payload.get("nextPageToken", "")
        if not page_token:
            return documents


def main() -> None:
    routines = load_routines(access_token())
    imported_names = sorted(
        {
            exercise.get("name", "").strip()
            for routine in routines
            for session in routine.get("sessions", [])
            for exercise in session.get("exercises", [])
            if exercise.get("name", "").strip()
        },
        key=normalize,
    )
    catalog = json.loads(CATALOG_PATH.read_text())
    catalog_by_normalized = {normalize(item["nombre"]): item for item in catalog}

    matches = []
    missing = []
    for name in imported_names:
        key = normalize(name)
        exact = catalog_by_normalized.get(key)
        if exact:
            matches.append(
                {"excel": name, "catalogo": exact["nombre"], "tipo": "exacta"}
            )
            continue
        candidates = []
        for catalog_name, item in catalog_by_normalized.items():
            score = SequenceMatcher(None, key, catalog_name).ratio()
            if key in catalog_name or catalog_name in key:
                score = max(score, 0.9)
            candidates.append((score, item))
        score, candidate = max(candidates, key=lambda value: value[0])
        if score >= 0.82:
            matches.append(
                {
                    "excel": name,
                    "catalogo": candidate["nombre"],
                    "tipo": "aproximada",
                    "similitud": round(score, 3),
                }
            )
        else:
            missing.append(
                {
                    "excel": name,
                    "sugerencia": candidate["nombre"],
                    "similitud": round(score, 3),
                }
            )

    report = {
        "rutinasFirebase": len(routines),
        "ejerciciosUnicosFirebase": len(imported_names),
        "coincidencias": matches,
        "faltantes": missing,
    }
    REPORT_PATH.write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n"
    )
    print(
        json.dumps(
            {
                "rutinas": len(routines),
                "ejercicios": len(imported_names),
                "coincidencias": len(matches),
                "faltantes": len(missing),
                "reporte": str(REPORT_PATH),
            },
            ensure_ascii=False,
        )
    )


if __name__ == "__main__":
    main()
