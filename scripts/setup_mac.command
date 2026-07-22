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
  echo "La instalación se detuvo por un error (código $exit_code)." >&2
  echo "Revisa el mensaje anterior, corrige el problema y vuelve a ejecutar el instalador." >&2
  pause_if_interactive
  exit "$exit_code"
}

trap on_error ERR

configure_brew_path() {
  local brew_binary="$1"
  local shellenv_line="eval \"\$($brew_binary shellenv)\""
  local profile_file="$HOME/.zprofile"

  touch "$profile_file"
  if ! grep -Fqx "$shellenv_line" "$profile_file"; then
    echo "$shellenv_line" >> "$profile_file"
  fi

  eval "$("$brew_binary" shellenv)"
}

install_cask_if_missing() {
  local cask="$1"
  local app_name="$2"
  local app_path="${3:-}"

  if brew list --cask "$cask" >/dev/null 2>&1 ||
    [[ -n "$app_path" && -d "$app_path" ]]; then
    echo "$app_name ya está instalado"
  else
    echo "Instalando $app_name..."
    brew install --cask "$cask"
  fi
}

echo "=========================================="
echo "GYM Pro - Instalador Mac"
echo "=========================================="
echo
echo "Proyecto detectado en:"
echo "$PROJECT_DIR"
echo

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Error: este instalador solo es compatible con macOS." >&2
  exit 1
fi

cd "$PROJECT_DIR"

echo "1. Verificando arquitectura del Mac..."
echo "Arquitectura: $(uname -m)"
echo

echo "2. Verificando Xcode Command Line Tools..."
if ! xcode-select -p >/dev/null 2>&1; then
  echo "No están instaladas las Command Line Tools."
  echo "Se abrirá el instalador de Apple."
  xcode-select --install || true
  echo
  echo "Cuando termine la instalación, vuelve a ejecutar este archivo."
  pause_if_interactive
  exit 0
fi
echo "Xcode Command Line Tools OK"
echo

echo "3. Verificando Homebrew..."
if ! command -v brew >/dev/null 2>&1; then
  if [[ -x /opt/homebrew/bin/brew ]]; then
    configure_brew_path /opt/homebrew/bin/brew
  elif [[ -x /usr/local/bin/brew ]]; then
    configure_brew_path /usr/local/bin/brew
  else
    echo "Homebrew no está instalado. Instalando Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [[ -x /opt/homebrew/bin/brew ]]; then
      configure_brew_path /opt/homebrew/bin/brew
    elif [[ -x /usr/local/bin/brew ]]; then
      configure_brew_path /usr/local/bin/brew
    else
      echo "Error: Homebrew terminó, pero no se encontró su ejecutable." >&2
      exit 1
    fi
  fi
fi
echo "Homebrew: $(brew --version | head -n 1)"
echo

echo "4. Actualizando Homebrew..."
brew update
echo

echo "5. Instalando Flutter..."
install_cask_if_missing flutter "Flutter"
echo

echo "6. Instalando Google Chrome..."
install_cask_if_missing google-chrome "Google Chrome" "/Applications/Google Chrome.app"
echo

echo "7. Instalando Visual Studio Code..."
install_cask_if_missing visual-studio-code "Visual Studio Code" "/Applications/Visual Studio Code.app"
echo

echo "8. Instalando Android Studio..."
install_cask_if_missing android-studio "Android Studio" "/Applications/Android Studio.app"
echo

echo "9. Instalando CocoaPods..."
if command -v pod >/dev/null 2>&1; then
  echo "CocoaPods ya está instalado"
else
  brew install cocoapods
fi
echo

if ! command -v flutter >/dev/null 2>&1; then
  echo "Error: Flutter no está disponible en PATH." >&2
  echo "Abre una terminal nueva o revisa la configuración de Homebrew." >&2
  exit 1
fi

echo "10. Verificando Xcode completo..."
if [[ -d /Applications/Xcode.app ]]; then
  echo "Xcode encontrado. Configurando sus herramientas..."
  sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
  sudo xcodebuild -runFirstLaunch
else
  echo "ADVERTENCIA: no se encontró Xcode completo en /Applications/Xcode.app."
  echo "Para compilar para iPhone/iOS, instálalo desde App Store."
  echo "Xcode completo no es obligatorio para ejecutar la app en Chrome."
fi
echo

echo "11. Instalando dependencias Flutter del proyecto..."
flutter clean
flutter pub get
echo

echo "12. Ejecutando Flutter Doctor..."
if ! flutter doctor -v; then
  echo "Flutter Doctor encontró tareas pendientes; revisa el informe anterior."
fi
echo

echo "13. Dispositivos disponibles..."
if ! flutter devices; then
  echo "No se pudieron consultar los dispositivos. Ejecuta 'flutter devices' manualmente."
fi
echo

echo "=========================================="
echo "Instalación terminada"
echo "=========================================="
echo
echo "Para correr la app en Chrome:"
echo "cd \"$PROJECT_DIR\""
echo "flutter run -d chrome"
echo
echo "Para analizar: flutter analyze"
echo "Para ejecutar pruebas: flutter test"
echo

pause_if_interactive
