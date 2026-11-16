import 'package:flutter/material.dart';

import 'pantallas/pantalla_lista.dart';
import 'tema.dart';

/// Punto de entrada: monta el widget raíz y pone en marcha la aplicación.
void main() => runApp(const MyApp());

/// Configura el nombre, el tema común y la pantalla que se abre al arrancar.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// MaterialApp proporciona la navegación y los estilos a las pantallas hijas.
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Mi Watchlist',
    debugShowCheckedModeBanner: false,
    theme: crearTema(),
    home: const PantallaLista(),
  );
}
