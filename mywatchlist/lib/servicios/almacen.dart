import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../modelos/elemento.dart';

/// Separa el almacenamiento local de los widgets y de la navegación.
class Almacen {
  /// Lee el JSON de watchlist; si falta o está dañado devuelve una lista vacía.
  Future<List<Elemento>> cargar() async {
    final preferencias = await SharedPreferences.getInstance();
    final texto = preferencias.getString('watchlist');
    if (texto == null) return [];
    // Decodifica el texto y reconstruye cada modelo con su validación.
    try {
      final lista = jsonDecode(texto) as List<dynamic>;
      return lista
          .map((dato) => Elemento.fromJson(dato as Map<String, dynamic>))
          .toList();
      // Un formato, tipo o enum incorrecto no debe impedir arrancar la app.
    } on FormatException {
      return [];
    } on TypeError {
      return [];
    } on ArgumentError {
      return [];
    }
  }

  /// Guarda toda la lista como un único texto y avisa si la escritura falla.
  Future<void> guardar(List<Elemento> elementos) async {
    final preferencias = await SharedPreferences.getInstance();
    final guardado = await preferencias.setString(
      'watchlist',
      jsonEncode(elementos.map((elemento) => elemento.toJson()).toList()),
    );
    if (!guardado) throw StateError('No se ha podido guardar la lista');
  }
}
