# GYM Pro

Aplicación Flutter para gestionar alumnos, rutinas y seguimiento de un gimnasio.

Actualmente incluye:

- Login por RUT y contraseña, con roles de alumno y administrador.
- Registro local de alumnos y perfiles.
- Importación de planificaciones desde Excel.
- Asignación de rutinas a alumnos específicos.
- Avance de sesiones completadas u omitidas.
- Historial de entrenamientos con kg y repeticiones.
- Métricas de progreso y asistencia.
- Registro y visualización de evaluaciones corporales.

> [!IMPORTANT]
> La aplicación todavía usa almacenamiento temporal en memoria. Los alumnos,
> asignaciones, entrenamientos y evaluaciones creados durante una ejecución se
> pierden al reiniciar la app. Firebase aún no está conectado.

## Rama de desarrollo

El desarrollo activo se realiza en:

```text
refactor/ordenar-estructura
```

No hacer merge a `main` sin una validación y autorización previas.

## Requisitos en macOS

Para ejecutar la versión web en Chrome:

- Git.
- Xcode Command Line Tools.
- Flutter SDK (Flutter ya incluye Dart).
- Google Chrome.

Para desarrollar también para Android o iOS se necesitan herramientas
adicionales:

- Android Studio, Android SDK y un emulador para Android.
- Xcode completo para iOS.
- CocoaPods solo si la configuración de iOS lo requiere.
- Visual Studio Code es opcional.

Consulta las guías oficiales de [instalación de Flutter](https://docs.flutter.dev/get-started/install/macos),
[configuración de macOS/Xcode](https://docs.flutter.dev/platform-integration/macos/setup)
y [Homebrew](https://docs.brew.sh/Installation) para requisitos vigentes.

## Instalación manual en Mac

### 1. Herramientas de línea de comandos

```bash
xcode-select --install
```

### 2. Homebrew

Si Homebrew no está instalado, usa el comando publicado en
[brew.sh](https://brew.sh/):

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Sigue las instrucciones que entregue el instalador para añadir Homebrew al
`PATH`. Su ubicación predeterminada es `/opt/homebrew` en Apple Silicon y
`/usr/local` en Mac Intel.

```bash
brew --version
```

### 3. Flutter y Chrome

```bash
brew install --cask flutter
brew install --cask google-chrome
flutter --version
flutter doctor -v
```

Herramientas opcionales:

```bash
brew install --cask visual-studio-code
brew install --cask android-studio
```

Después de instalar Android Studio, ábrelo una vez y completa el asistente para
instalar Android SDK, Android SDK Platform, Android Emulator y Android SDK
Command-line Tools. Luego ejecuta:

```bash
flutter doctor --android-licenses
flutter doctor -v
```

Para iOS, instala Xcode desde App Store y completa su configuración:

```bash
sudo sh -c 'xcode-select -s /Applications/Xcode.app/Contents/Developer && xcodebuild -runFirstLaunch'
sudo xcodebuild -license
flutter doctor -v
```

Si Flutter indica que falta CocoaPods:

```bash
brew install cocoapods
pod --version
```

## Clonar y preparar el proyecto

```bash
git clone https://github.com/enunez98/GYM.git
cd GYM
git checkout refactor/ordenar-estructura
flutter clean
flutter pub get
```

## Setup automático opcional

El script comprueba macOS, Xcode Command Line Tools y Homebrew; instala con
Homebrew las aplicaciones que falten y prepara las dependencias del proyecto.
No acepta licencias ni ejecuta comandos con `sudo` automáticamente.

```bash
chmod +x scripts/setup_mac.sh
./scripts/setup_mac.sh
```

## Ejecutar la app

Comprobar dispositivos disponibles:

```bash
flutter devices
```

Ejecutar en Chrome:

```bash
flutter run -d chrome
```

Presiona `q` en esa terminal para detener `flutter run` y cerrar la sesión de
depuración.

## Validaciones

```bash
dart format lib test
flutter analyze
flutter test
```

Antes de publicar cambios, ejecuta las tres validaciones y comprueba también el
arranque con `flutter run -d chrome`.

El proyecto conserva algunos avisos informativos de APIs obsoletas en código
heredado; no deben existir errores ni advertencias nuevas.

## Usuarios demo

Alumno:

```text
RUT: 11.111.111-1
Contraseña: 1234
```

Administrador:

```text
RUT: 22.222.222-2
Contraseña: 1234
```

Los alumnos creados por el administrador durante la ejecución pueden iniciar
sesión con el RUT registrado y la contraseña temporal `1234`.

## Flujo básico de prueba

1. Iniciar sesión como administrador.
2. Registrar un alumno o abrir la ficha de Felipe Durán.
3. Cargar y validar una planificación Excel compatible con su plan.
4. Abrir la ficha del alumno y asignarle la rutina importada.
5. Cerrar sesión e iniciar como ese alumno.
6. Abrir Entreno, ingresar kg y repeticiones y guardar la sesión.
7. Revisar Inicio, Progreso y Evaluación corporal.
8. Volver al panel administrador para continuar la gestión.

## Estructura principal

```text
lib/
├── core/                         # Tema y widgets compartidos
├── features/
│   ├── auth/                     # Login
│   ├── student/screens/          # Experiencia del alumno
│   ├── teacher/screens/          # Gestión administrativa actual
│   └── admin/screens/            # Pantallas administrativas adicionales
├── models/                       # Entidades de dominio
├── services/                     # Stores y lógica local
└── main.dart                     # Entrada de la aplicación
test/                             # Pruebas unitarias y de widgets
scripts/setup_mac.sh              # Preparación opcional para macOS
```

## Formato de rutinas

La importación acepta archivos `.xlsx` con la hoja `PLANIFICACION` y la
estructura esperada por la pantalla de carga. La rutina importada debe coincidir
con el plan del alumno para poder asignarse.

## Problemas comunes

### `flutter: command not found`

Comprueba la instalación y el `PATH`:

```bash
flutter --version
which flutter
```

### Licencias de Android pendientes

```bash
flutter doctor --android-licenses
```

### No aparece un dispositivo Android

Abre Android Studio, instala los componentes del SDK y crea un emulador desde
Device Manager. Después ejecuta `flutter devices`.

### No compila para iOS

Abre Xcode una vez, acepta sus licencias y revisa:

```bash
flutter doctor -v
xcodebuild -version
```

### Error de dependencias

```bash
flutter clean
flutter pub get
```

### Chrome no aparece o la web no inicia

```bash
flutter devices
flutter run -d chrome
```

La descarga de fuentes externas puede fallar en redes restringidas; esto no
necesariamente indica un error en la lógica de la aplicación.

## Buenas prácticas de Git

Antes de trabajar:

```bash
git checkout refactor/ordenar-estructura
git pull origin refactor/ordenar-estructura
```

Después de realizar cambios:

```bash
dart format lib test
flutter analyze
flutter test
git status
git add .
git commit -m "mensaje del cambio"
git push origin refactor/ordenar-estructura
```

No subir archivos `.env`, claves privadas, tokens, credenciales reales ni
archivos de configuración que contengan secretos.

## Próximos pasos

- Mostrar el historial de entrenamientos de cada alumno en el panel admin.
- Editar los datos de alumnos registrados.
- Conectar Firebase Auth y Firestore.
- Persistir perfiles, rutinas, entrenamientos y evaluaciones.
- Preparar el despliegue web cuando la lógica local esté cerrada.
