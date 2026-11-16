import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mywatchlist/main.dart';
import 'package:mywatchlist/modelos/elemento.dart';
import 'package:mywatchlist/pantallas/pantalla_lista.dart';
import 'package:mywatchlist/pantallas/pantalla_estadisticas.dart';
import 'package:mywatchlist/servicios/almacen.dart';
import 'package:mywatchlist/widgets/tarjeta_elemento.dart';
import 'package:mywatchlist/widgets/selector_estrellas.dart';
import 'package:mywatchlist/pantallas/pantalla_formulario.dart';

/// Almacén de prueba que permite provocar un fallo y habilitar después el reintento.
class AlmacenFallido extends Almacen {
  bool fallar = true;

  /// Simula el error mientras fallar sea true; después utiliza el guardado normal.
  @override
  Future<void> guardar(List<Elemento> elementos) async {
    if (fallar) throw StateError('Fallo simulado');
    await super.guardar(elementos);
  }
}

/// Recorre las funciones principales de la app con widgets y preferencias simuladas.
void main() {
  // Aísla los datos de cada prueba respecto a las demás y al usuario real.
  setUp(() => SharedPreferences.setMockInitialValues({}));
  // Simula una pantalla estrecha con teclado y restaura sus medidas al terminar.
  testWidgets('Estado vacío se adapta a una ventana pequeña y al teclado', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 640);
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
  // Recorre el ciclo de una entrada y contrasta la interfaz con lo almacenado.
  testWidgets('Alta, edición, cancelación, borrado y persistencia', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.text('Tu lista está vacía'), findsOneWidget);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Dune');
    await tester.ensureVisible(find.text('Guardar'));
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect((await Almacen().cargar()).single.titulo, 'Dune');
    await tester.tap(find.byType(TarjetaElemento));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Dune 2');
    await tester.ensureVisible(find.text('Guardar'));
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.text('Dune 2'), findsWidgets);
    expect((await Almacen().cargar()).single.titulo, 'Dune 2');
    await tester.tap(find.text('Borrar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect((await Almacen().cargar()).length, 1);
    await tester.tap(find.text('Borrar'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Borrar'));
    await tester.pumpAndSettle();
    expect(find.text('Tu lista está vacía'), findsOneWidget);
    expect(await Almacen().cargar(), isEmpty);
  });
  // Los filtros por tipo, estado y texto deben combinarse sin borrar entradas.
  testWidgets('Filtro y búsqueda combinados no eliminan datos', (tester) async {
    await Almacen().guardar([
      Elemento(
        id: '1',
        titulo: 'Dune',
        tipo: Tipo.pelicula,
        estado: Estado.pendiente,
        fechaAlta: DateTime(2026),
      ),
      Elemento(
        id: '2',
        titulo: 'Celeste',
        tipo: Tipo.videojuego,
        estado: Estado.terminado,
        fechaAlta: DateTime(2026),
      ),
      Elemento(
        id: '3',
        titulo: 'Dark',
        tipo: Tipo.serie,
        estado: Estado.pendiente,
        fechaAlta: DateTime(2026),
      ),
    ]);
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    for (final tipo in Tipo.values) {
      await tester.tap(find.widgetWithText(ChoiceChip, tipo.etiqueta));
      await tester.pumpAndSettle();
      expect(find.byType(TarjetaElemento), findsOneWidget);
      expect(
        tester
            .widget<TarjetaElemento>(find.byType(TarjetaElemento))
            .elemento
            .tipo,
        tipo,
      );
    }
    await tester.tap(find.widgetWithText(ChoiceChip, Tipo.pelicula.etiqueta));
    await tester.enterText(find.byType(TextField), 'DUNE');
    await tester.pump();
    expect(find.byType(TarjetaElemento), findsOneWidget);
    await tester.tap(find.text('Terminado'));
    await tester.pumpAndSettle();
    expect(find.text('No hay resultados'), findsOneWidget);
    await tester.ensureVisible(find.text('Limpiar búsqueda y filtros'));
    await tester.tap(find.text('Limpiar búsqueda y filtros'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<ListView>(find.byType(ListView))
          .childrenDelegate
          .estimatedChildCount,
      3,
    );
    expect(
      tester
          .widget<ChoiceChip>(
            find.widgetWithText(ChoiceChip, 'Todos los tipos'),
          )
          .selected,
      isTrue,
    );
    expect((await Almacen().cargar()).length, 3);
  });
  // Un guardado fallido conserva la lista previa y reintentar añade una sola entrada.
  testWidgets('Fallo de guardado permite reintentar sin duplicados', (
    tester,
  ) async {
    final almacen = AlmacenFallido();
    await tester.pumpWidget(MaterialApp(home: PantallaLista(almacen: almacen)));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Dune');
    await tester.ensureVisible(find.text('Guardar'));
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.text('No se pudo guardar el elemento.'), findsOneWidget);
    expect(await Almacen().cargar(), isEmpty);
    almacen.fallar = false;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect((await Almacen().cargar()).length, 1);
    expect(find.byType(TarjetaElemento), findsOneWidget);
  });
  // Sin datos, las estadísticas presentan mensajes y proporciones válidas.
  testWidgets('Estadísticas vacías no dividen entre cero', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: PantallaEstadisticas(elementos: [])),
    );
    expect(find.text('0'), findsOneWidget);
    expect(find.text('Sin valoraciones'), findsOneWidget);
    for (final barra in tester.widgetList<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    )) {
      expect(barra.value, 0);
    }
  });
  // Comprueba la media sin ceros, los empates y el recálculo al filtrar por tipo.
  testWidgets('Media excluye ceros y muestra tipos empatados', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PantallaEstadisticas(
          elementos: [
            Elemento(
              id: '1',
              titulo: 'Dune',
              tipo: Tipo.pelicula,
              estado: Estado.pendiente,
              fechaAlta: DateTime(2026),
              valoracion: 4,
            ),
            Elemento(
              id: '2',
              titulo: 'Celeste',
              tipo: Tipo.videojuego,
              estado: Estado.terminado,
              fechaAlta: DateTime(2026),
            ),
          ],
        ),
      ),
    );
    expect(find.text('4,0 / 5'), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Película'));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);
    expect(find.text('4,0 / 5'), findsOneWidget);
    expect(find.text('Pendiente: 1'), findsOneWidget);
    expect(find.text('Terminado: 0'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Videojuego'));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);
    expect(find.text('Sin valoraciones'), findsOneWidget);
    expect(find.text('Terminado: 1'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Serie'));
    await tester.pumpAndSettle();
    expect(find.text('0'), findsOneWidget);
    expect(find.text('Sin valoraciones'), findsOneWidget);
    for (final barra in tester.widgetList<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    )) {
      expect(barra.value, 0);
    }

    await tester.tap(find.widgetWithText(ChoiceChip, 'Todos los tipos'));
    await tester.pumpAndSettle();
    expect(find.text('2'), findsOneWidget);
    expect(find.text('4,0 / 5'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Tipo más frecuente: Película, Videojuego'),
      150,
    );
    expect(
      find.text('Tipo más frecuente: Película, Videojuego'),
      findsOneWidget,
    );
  });
  // La navegación de escritorio también debe descartar formularios sin guardar.
  testWidgets(
    'Botón + abre formulario y barra lateral navega a estadísticas e inicio',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(find.widgetWithText(ListTile, 'Nuevo elemento'), findsNothing);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(PantallaFormulario), findsOneWidget);
      await tester.enterText(find.byType(TextFormField).first, 'Sin guardar');
      await tester.tap(find.widgetWithText(ListTile, 'Estadísticas'));
      await tester.pumpAndSettle();
      expect(find.byType(PantallaEstadisticas), findsOneWidget);
      expect(await Almacen().cargar(), isEmpty);
      await tester.tap(find.widgetWithText(ListTile, 'Inicio'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(PantallaFormulario), findsOneWidget);
      await tester.tap(find.widgetWithText(ListTile, 'Inicio'));
      await tester.pumpAndSettle();
      expect(find.text('Tu lista está vacía'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  // Repite alta y navegación con cajón móvil y comprueba la tarjeta seleccionada.
  testWidgets('Botón + móvil permite crear y volver a inicio', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Abrir menú'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ListTile, 'Nuevo elemento'), findsNothing);
    await tester.tap(find.widgetWithText(ListTile, 'Inicio'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Celeste');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect((await Almacen().cargar()).single.titulo, 'Celeste');
    await tester.tap(find.byType(TarjetaElemento));
    await tester.pumpAndSettle();
    expect(find.text('Detalle'), findsOneWidget);
    await tester.tap(find.byTooltip('Volver'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TarjetaElemento>(find.byType(TarjetaElemento)).seleccionado,
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });
  // Un padre con estado recibe el callback; repetir la estrella activa devuelve 0.
  testWidgets('Estrellas permiten quitar valoración', (tester) async {
    var valor = 3;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: SelectorEstrellas(
              valor: valor,
              onChanged: (nuevo) => setState(() => valor = nuevo),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byTooltip('Quitar valoración'));
    await tester.pump();
    expect(valor, 0);
  });
}
