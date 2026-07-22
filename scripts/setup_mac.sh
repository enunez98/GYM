#!/usr/bin/env bash

set -Eeuo pipefail

readonly PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "======================================"
echo "GYM Pro - Setup para macOS"
echo "======================================"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Error: este script solo es compatible con macOS." >&2
  exit 1
fi

echo
echo "1. Verificando Xcode Command Line Tools..."
if ! xcode-select -p >/dev/null 2>&1; then
  echo "Se abrirá el instalador de Xcode Command Line Tools."
  xcode-select --install
  echo "Completa la instalación y vuelve a ejecutar este script."
  exit 1
fi
echo "Xcode Command Line Tools: OK"

echo
echo "2. Verificando Homebrew..."
if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew no está instalado. Instálalo desde https://brew.sh/ con:"
  echo '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  echo "Después sigue las instrucciones para añadir brew al PATH y repite este script."
  exit 1
fi
echo "Homebrew: $(brew --version | head -n 1)"

install_cask_if_missing() {
  local cask="$1"
  local app_name="$2"

  if brew list --cask "$cask" >/dev/null 2>&1; then
    echo "$app_name: ya está instalado"
  else
    echo "Instalando $app_name..."
    brew install --cask "$cask"
  fi
}

echo
echo "3. Instalando herramientas que falten..."
install_cask_if_missing flutter "Flutter"
install_cask_if_missing google-chrome "Google Chrome"
install_cask_if_missing visual-studio-code "Visual Studio Code"
install_cask_if_missing android-studio "Android Studio"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Error: Flutter fue instalado, pero aún no está disponible en PATH." >&2
  echo "Abre una terminal nueva o revisa la configuración de Homebrew." >&2
  exit 1
fi

echo
echo "4. Instalando dependencias del proyecto..."
cd "$PROJECT_ROOT"
flutter clean
flutter pub get

echo
echo "5. Revisando el entorno Flutter..."
if ! flutter doctor -v; then
  echo "Flutter Doctor encontró tareas pendientes. Revísalas antes de compilar para Android o iOS."
fi

echo
echo "Setup terminado. Para iniciar la app en Chrome:"
echo "cd \"$PROJECT_ROOT\""
echo "flutter run -d chrome"
