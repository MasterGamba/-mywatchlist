# Mi Watchlist

Aplicación Flutter para organizar películas, series y videojuegos pendientes, en curso o terminados. Incluye alta, detalle, edición, borrado con confirmación, valoración de 0 a 5 estrellas, notas, búsqueda, filtros y estadísticas.

## Diseño

Interfaz oscura con la paleta violeta del boceto: navegación lateral en escritorio, menú en móvil, búsqueda, filtros, tarjetas con selección, formulario, detalle y estadísticas. El tema se define en `lib/tema.dart` y la estructura común en `lib/widgets/marco_pagina.dart`. Las portadas ilustradas se dibujan localmente por tipo de contenido y funcionan sin conexión.

## Ejecutar

Desde esta carpeta, con Flutter instalado:

```sh
flutter pub get
flutter run -d chrome --web-port 8765
flutter run -d windows
flutter devices
flutter run -d <identificador-android>
```

Los comandos `flutter run` son alternativas según la plataforma. Para Android hace falta un dispositivo conectado o un emulador iniciado. Windows requiere Visual Studio con la carga «Desarrollo para el escritorio con C++» y un SDK de Windows compatible. Activar el modo de desarrollador de Windows permite a Flutter crear enlaces de plugins; esta sesión preparó junctions locales en las carpetas efímeras como alternativa.

## Uso

- Pulsa **+** o **Añadir el primero** para crear un elemento.
- Escribe un título de entre 1 y 60 caracteres, sin contar espacios iniciales y finales.
- Elige tipo, estado, valoración y notas. Pulsar de nuevo la estrella seleccionada quita la valoración.
- Toca una tarjeta para ver el detalle, editar o borrar. Cancelar conserva los datos.
- Combina la búsqueda por título con los filtros de estado. **Limpiar búsqueda y filtros** recupera todos los resultados.
- Abre las estadísticas con el icono de barras. La media excluye los elementos sin valorar y el tipo más frecuente admite empates.

La lista se guarda tras cada cambio en `shared_preferences`, como un texto JSON con la clave `watchlist`. Las escrituras se esperan antes de actualizar la lista; ante un fallo se conservan los datos anteriores en pantalla y se ofrece reintentar. Un JSON inválido se interpreta como una lista vacía y no se reescribe automáticamente durante la carga.

Cada instalación mantiene sus propios datos. En web se guardan en el almacenamiento local del navegador: usa el mismo navegador, perfil, dirección y puerto para recuperarlos. Borrar los datos del sitio, desinstalar la app o utilizar una sesión privada puede hacer que se pierdan. No hay cuentas ni sincronización.

## Estructura

```text
lib/
  main.dart
  modelos/elemento.dart
  servicios/almacen.dart
  pantallas/
    pantalla_lista.dart
    pantalla_formulario.dart
    pantalla_detalle.dart
    pantalla_estadisticas.dart
  widgets/
    tarjeta_elemento.dart
    selector_estrellas.dart
test/
  elemento_test.dart
  formulario_test.dart
  almacen_test.dart
  app_test.dart
docs/
  bitacora_ia.md
  verificacion.md
  guia_defensa.md
  capturas/
```

La pantalla principal posee la lista completa. El formulario devuelve un `Elemento` por navegación y el detalle solicita los cambios mediante callbacks. `Almacen` se ocupa exclusivamente de la persistencia. El estado utiliza `StatefulWidget` y `setState`.

Dependencias directas: Flutter y `shared_preferences`. Para desarrollo: `flutter_test` y `flutter_lints`. No se utilizan gestores de estado externos ni servicios remotos.

## Comprobar y compilar

```sh
dart format lib test
flutter analyze
flutter test
flutter build web --no-web-resources-cdn
flutter build apk --debug
flutter build windows
```

La compilación web incluye CanvasKit local para evitar descargar el motor gráfico de una CDN al arrancar. Sirve `build/web` mediante HTTP; no abras `index.html` directamente como archivo.

Resultados esperados de compilación:

| Plataforma | Salida |
| --- | --- |
| Web | `build/web/` completa |
| Android | `build/app/outputs/flutter-apk/app-debug.apk` |
| Windows | `build/windows/x64/runner/Release/` completa, incluidos DLL y `data/` |

El estado real de las verificaciones y los bloqueos del entorno están en [verificacion.md](docs/verificacion.md). Los paquetes disponibles de esta sesión se guardan en `../entregables/`.

## Capturas

Las capturas de `docs/capturas/` se realizan sobre la app en Chrome con datos de demostración; estos datos no vienen precargados en la aplicación.

| Lista | Formulario |
| --- | --- |
| ![Lista](docs/capturas/Lista.jpeg) | ![Formulario](docs/capturas/formulario.jpeg) |

| Detalle | Estadísticas |
| --- | --- |
| ![Detalle](docs/capturas/Detalle.jpeg) | ![Estadísticas](docs/capturas/Estadísticas.jpeg) |

![Lista vacía](docs/capturas/vacia.jpeg)

## Preparar la entrega académica

El boceto está incluido en `docs/capturas/boceto.png`. Antes de entregar, el alumno debe revisar y comentar con `///` las clases y funciones importantes con sus palabras, completar las reflexiones y las preguntas de la bitácora sin IA y realizar las comprobaciones manuales pendientes. Estos trabajos personales no se presentan como realizados por el alumno.

No se han creado commits porque la carpeta de partida no es un repositorio Git. La bitácora distingue el trabajo técnico de esta sesión del trabajo personal pendiente.
