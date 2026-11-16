# Verificación de la implementación

## Rediseño del 13/11/2026

Se ha aplicado el diseño oscuro violeta de referencia a las pantallas Flutter: barra lateral en escritorio y menú desplegable en móvil, lista con tarjeta seleccionada, estado vacío, formulario, detalle y estadísticas. La paleta se centraliza en `lib/tema.dart` y la navegación visual en `lib/widgets/marco_pagina.dart`. Las miniaturas son ilustraciones locales por tipo; no se incluyen carteles externos ni se precargan los datos de demostración.

Validación del rediseño: `dart format lib test`, `flutter analyze --no-pub` sin incidencias y `flutter test --no-pub` con 25 pruebas superadas. La compilación `flutter build web --no-pub --no-web-resources-cdn` termina correctamente en `build/web`. Se han renovado las capturas en Chrome a 1280×900 y 390×844, sin errores JavaScript durante el recorrido visual de lista, formulario, estadísticas y detalle. Las dos nuevas pruebas recorren la barra lateral y el menú móvil, comprueban la cancelación de datos sin guardar y la selección al volver del detalle. Las comprobaciones de compilación nativa de la sesión anterior siguen indicadas más abajo.


Fecha: 12/11/2026. Entorno: Windows, Flutter 3.47.9 y Dart 3.13.7.

## Comprobaciones realizadas

| Comprobación | Resultado |
| --- | --- |
| `dart format lib test` | Correcto |
| `flutter analyze --no-pub` | Sin incidencias |
| `flutter test --no-pub` | 23 pruebas superadas |
| `flutter build web --no-pub --no-web-resources-cdn` | Compilación generada en `build/web` |
| `flutter build apk --debug --no-pub` | Bloqueada por instalación incompleta del NDK 28.2.13676358 |
| `flutter build windows --no-pub` | CMake no localiza el compilador C++; falta un SDK de Windows en la instalación detectada |

Las pruebas cubren JSON y `copyWith`, notas ausentes, valoración inválida, almacenamiento vacío y corrupto, validación del título, identidad en edición, cancelación del formulario, alta/edición/borrado con persistencia, cancelación del borrado, filtros y búsqueda combinados, reintento de un guardado fallido, estadísticas vacías, media sin ceros, empates, estrellas y adaptación del estado vacío a ventana pequeña con teclado.

La compilación web emite un aviso de fuente Cupertino desde el framework pese a que la aplicación utiliza únicamente iconos Material. La compilación termina correctamente; no se añadió un paquete de iconos adicional.

## Comprobación en navegador

Se utilizó Chrome en modo headless con Playwright y un servidor HTTP local, con almacenamiento aislado de los perfiles habituales del usuario. Las capturas muestran datos introducidos para la comprobación, no datos iniciales de la app.

El recorrido completo terminó correctamente y se registró en `capturas/comprobacion_chrome.txt`: altas de los tres tipos, estados, valoración, búsqueda y filtros combinados, edición, cancelación, confirmación, borrado, estadísticas y persistencia tras recargar. Se capturaron vistas de 1280×900 y 390×844, sin errores JavaScript detectados. No representa una comprobación manual en un teléfono Android o en la aplicación nativa de Windows.

## Android: desbloquear la compilación

La carpeta del NDK requerido contenía únicamente archivos de una instalación incompleta. El comando automático de Flutter no consiguió instalarlo; se intentó instalar expresamente `ndk/28.2.13676358` con las herramientas del SDK. La descarga de unos 713 MB avanzaba con una estimación de varias horas y se interrumpió.

1. En Android Studio, abrir SDK Manager y la pestaña SDK Tools.
2. Activar la visualización de versiones y completar **NDK (Side by side) 28.2.13676358**.
3. Ejecutar `flutter doctor -v` y `flutter build apk --debug`.
4. Iniciar el emulador disponible o conectar un teléfono y recorrer las comprobaciones funcionales.

No se generó ni se incluye un APK ficticio.

## Windows: desbloquear la compilación

Visual Studio Community está instalado, pero `flutter doctor -v` no localiza un Windows SDK y la compilación falla con `No CMAKE_CXX_COMPILER could be found`. No se modificó la instalación global de Visual Studio.

1. Abrir Visual Studio Installer y modificar la instalación de Community.
2. Completar **Desarrollo para el escritorio con C++**, con compilador MSVC, herramientas CMake y un SDK de Windows compatible.
3. Abrir una terminal nueva y comprobar `flutter doctor -v`.
4. Ejecutar `flutter build windows` y probar la app nativa.
5. Distribuir toda la carpeta `build/windows/x64/runner/Release`, no únicamente el ejecutable.

## Comprobaciones personales pendientes

- [ ] Recorrido manual en un teléfono o emulador Android tras completar el NDK.
- [ ] Recorrido manual en Windows tras completar las herramientas nativas.
- [ ] Cerrar y volver a abrir las aplicaciones nativas y comprobar persistencia.
- [ ] Revisar con el alumno la legibilidad, el teclado y el tamaño de ventanas.
- [ ] Añadir el boceto original, comentarios personales y respuestas de comprensión.

No hay un repositorio Git inicializado en la carpeta de trabajo; no se han simulado commits de fases.
