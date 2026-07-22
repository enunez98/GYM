#!/usr/bin/env bash

set -Eeuo pipefail

readonly PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

pause_if_interactive() {
  if [[ -t 0 ]]; then
    read -r -p "Presiona ENTER para cerrar..."
  fi
}

on_error() {
  local exit_code=$?
  echo
  echo "No se pudo iniciar GYM Pro (código $exit_code)." >&2
  pause_if_interactive
  exit "$exit_code"
}

trap on_error ERR

cd "$PROJECT_DIR"

echo "=========================================="
echo "GYM Pro - Ejecutar en Chrome"
echo "=========================================="
echo

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter no está disponible. Ejecuta primero scripts/setup_mac.command." >&2
  exit 1
fi

flutter pub get
flutter run -d chrome

pause_if_interactive
