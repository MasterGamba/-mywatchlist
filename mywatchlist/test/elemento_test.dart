import 'package:flutter_test/flutter_test.dart';
import 'package:mywatchlist/modelos/elemento.dart';

/// Comprueba la conversión JSON, la compatibilidad y las copias del modelo.
void main() {
  // Entrada de referencia con la que se comparan las conversiones y las copias.
  final original = Elemento(
    id: '1',
    titulo: 'Dune',
    tipo: Tipo.pelicula,
    estado: Estado.pendiente,
    valoracion: 4,
    notas: 'En casa',
    imagenUrl: 'https://example.com/dune.jpg',
    fechaAlta: DateTime(2026, 11, 12),
  );
  // Guardar y recuperar debe conservar los datos, incluso los campos opcionales.
  test('JSON conserva todos los datos', () {
    expect(Elemento.fromJson(original.toJson()).toJson(), original.toJson());
  });
  test('JSON admite notas ausentes', () {
    final json = original.toJson()..remove('notas');
    expect(Elemento.fromJson(json).notas, isNull);
  });
  test('JSON antiguo admite imagen ausente', () {
    final json = original.toJson()..remove('imagenUrl');
    expect(Elemento.fromJson(json).imagenUrl, isNull);
  });
  // Las copias deben cambiar solo lo solicitado y dejar intacto el original.
  test('copyWith permite cambiar la URL de imagen', () {
    final copia = original.copyWith(imagenUrl: 'https://example.com/otra.jpg');
    expect(copia.imagenUrl, 'https://example.com/otra.jpg');
    expect(original.imagenUrl, 'https://example.com/dune.jpg');
  });
  test('copyWith cambia solo lo indicado sin modificar el original', () {
    final copia = original.copyWith(estado: Estado.terminado);
    expect(copia.toJson(), {...original.toJson(), 'estado': 'terminado'});
    expect(original.estado, Estado.pendiente);
    expect(original.copyWith().toJson(), original.toJson());
  });
  test('copyWith permite vaciar notas', () {
    expect(original.copyWith(borrarNotas: true).notas, isNull);
  });
  // La lectura también aplica las restricciones de valoración del modelo.
  test('JSON rechaza valoración fuera del intervalo', () {
    expect(
      () => Elemento.fromJson({...original.toJson(), 'valoracion': 6}),
      throwsFormatException,
    );
  });
}
