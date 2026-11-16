import 'package:flutter/material.dart';

/// Paleta compartida: cambiar una constante actualiza todos sus usos.
abstract final class Colores {
  static const fondo = Color(0xFF0F0B1E);
  static const superficie = Color(0xFF1E1B34);
  static const primario = Color(0xFF8B5CF6);
  static const hover = Color(0xFFA78BFA);
  static const texto = Color(0xFFE5E7EB);
  static const secundario = Color(0xFF9CA3AF);
  static const borde = Color(0xFF48405F);
}

/// Construye el tema oscuro y los estilos comunes de los controles Material.
ThemeData crearTema() {
  // Base del tema: tipografía, fondo y colores para superficies y texto.
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Segoe UI',
    scaffoldBackgroundColor: Colores.fondo,
    colorScheme: const ColorScheme.dark(
      primary: Colores.primario,
      onPrimary: Colors.white,
      secondary: Colores.hover,
      surface: Colores.superficie,
      onSurface: Colores.texto,
      outline: Colores.borde,
    ),
  );
  // Los campos reutilizan este borde y lo resaltan al recibir el foco.
  final borde = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: Colores.borde),
  );
  // Personaliza los componentes sin repetir sus estilos en cada pantalla.
  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: Colores.texto,
      displayColor: Colores.texto,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colores.superficie,
      border: borde,
      enabledBorder: borde,
      focusedBorder: borde.copyWith(
        borderSide: const BorderSide(color: Colores.hover, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      hintStyle: const TextStyle(color: Colores.secundario, fontSize: 14),
    ),
    // Botones de acción principal y secundaria con la misma altura y forma.
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 46),
        backgroundColor: Colores.primario,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 46),
        foregroundColor: Colores.texto,
        side: const BorderSide(color: Colores.borde),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    // Estilos del botón de alta, los filtros y los indicadores de progreso.
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colores.primario,
      foregroundColor: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: Colores.superficie,
      selectedColor: Colores.primario,
      checkmarkColor: Colors.white,
      labelStyle: const TextStyle(color: Colores.texto, fontSize: 13),
      side: const BorderSide(color: Colores.borde),
      shape: const StadiumBorder(),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Colores.primario,
      linearTrackColor: Colores.superficie,
    ),
  );
}
