import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mywatchlist/modelos/elemento.dart';
import 'package:mywatchlist/servicios/almacen.dart';

/// Verifica el almacenamiento sin leer ni modificar preferencias reales.
void main() {
  // Cada prueba empieza con preferencias simuladas vacías e independientes.
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('Sin datos carga una lista vacía', () async {
    expect(await Almacen().cargar(), isEmpty);
  });
  // Comprueba el formato persistido, su recuperación y el guardado de lista vacía.
  test('Guarda toda la lista como un único texto JSON', () async {
    final elemento = Elemento(
      id: '1',
      titulo: 'The Bear',
      tipo: Tipo.serie,
      estado: Estado.enCurso,
      fechaAlta: DateTime(2026),
      valoracion: 5,
    );
    await Almacen().guardar([elemento]);
    final preferencias = await SharedPreferences.getInstance();
    expect(jsonDecode(preferencias.getString('watchlist')!), [
      elemento.toJson(),
    ]);
    expect((await Almacen().cargar()).single.toJson(), elemento.toJson());
    await Almacen().guardar([]);
    expect(await Almacen().cargar(), isEmpty);
  });
  // Incluye JSON ilegible, estructura incorrecta y elementos incompletos.
  for (final texto in ['{roto', '{}', '[null]', '[{"id":"1"}]']) {
    test('Recupera JSON dañado: $texto', () async {
      SharedPreferences.setMockInitialValues({'watchlist': texto});
      expect(await Almacen().cargar(), isEmpty);
    });
  }
}
