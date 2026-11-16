import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mywatchlist/modelos/elemento.dart';
import 'package:mywatchlist/pantallas/pantalla_formulario.dart';

/// Localiza Guardar, lo hace visible y espera a que termine la reacción del widget.
Future<void> guardar(WidgetTester tester) async {
  final boton = find.widgetWithText(FilledButton, 'Guardar');
  await tester.ensureVisible(boton);
  await tester.tap(boton);
  await tester.pumpAndSettle();
}

/// Verifica validación, identidad en edición y cancelación del formulario.
void main() {
  // Repite la misma comprobación con vacío, espacios y exceso de longitud.
  for (final titulo in ['', '   ', 'a' * 61]) {
    testWidgets('Rechaza título de longitud ${titulo.length}', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: PantallaFormulario()));
      await tester.enterText(find.byType(TextFormField).first, titulo);
      await guardar(tester);
      expect(
        find.text(
          titulo.trim().isEmpty
              ? 'Escribe un título'
              : 'El título admite un máximo de 60 caracteres',
        ),
        findsOneWidget,
      );
    });
  }
  // Una ruta real permite comprobar el Elemento devuelto por Navigator.pop.
  testWidgets('Acepta 60 caracteres y conserva identidad al editar', (
    tester,
  ) async {
    final inicial = Elemento(
      id: '1',
      titulo: 'Dune',
      tipo: Tipo.pelicula,
      estado: Estado.pendiente,
      notas: 'Borrar estas notas',
      imagenUrl: 'https://example.com/dune.jpg',
      fechaAlta: DateTime(2026),
    );
    Elemento? resultado;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                resultado = await Navigator.push<Elemento>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PantallaFormulario(inicial: inicial),
                  ),
                );
              },
              child: const Text('Abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '  ${'a' * 60}  ');
    await tester.enterText(find.byType(TextFormField).last, '  ');
    await guardar(tester);
    expect(resultado?.titulo.length, 60);
    expect(resultado?.id, inicial.id);
    expect(resultado?.fechaAlta, inicial.fechaAlta);
    expect(resultado?.notas, isNull);
    expect(resultado?.imagenUrl, inicial.imagenUrl);
  });
  // Escribir y cancelar debe cerrar el formulario sin devolver un Elemento.
  testWidgets('Cancelar no devuelve cambios', (tester) async {
    Elemento? resultado;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                resultado = await Navigator.push<Elemento>(
                  context,
                  MaterialPageRoute(builder: (_) => const PantallaFormulario()),
                );
              },
              child: const Text('Abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'No guardar');
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Cancelar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(resultado, isNull);
    expect(find.text('Abrir'), findsOneWidget);
  });
}
