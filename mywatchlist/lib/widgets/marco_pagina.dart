import 'package:flutter/material.dart';

import '../tema.dart';

/// Identifica la sección activa para resaltar la opción de navegación.
enum Seccion { inicio, nuevo, estadisticas }

/// Navegación común para escritorio y móvil, compartida por todas las pantallas.
class MarcoPagina extends StatelessWidget {
  const MarcoPagina({
    super.key,
    required this.titulo,
    required this.child,
    this.seccion = Seccion.inicio,
    this.onNuevo,
    this.onEstadisticas,
    this.floatingActionButton,
    this.volver = false,
  });

  // Cada pantalla aporta el contenido y las acciones que el marco puede ejecutar.
  final String titulo;
  final Widget child;
  final Seccion seccion;
  final VoidCallback? onNuevo;
  final VoidCallback? onEstadisticas;
  final Widget? floatingActionButton;
  final bool volver;

  /// Regresa a la primera ruta sin crear otra instancia de la lista principal.
  void _inicio(BuildContext context) =>
      Navigator.of(context).popUntil((r) => r.isFirst);

  /// Abre la información del tema y del guardado local de esta aplicación.
  void _ajustes(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajustes'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.dark_mode_outlined, color: Colores.hover),
              title: Text('Tema oscuro'),
              subtitle: Text('Diseño violeta de Mi Watchlist'),
            ),
            SizedBox(height: 12),
            Text(
              'Tus películas, series y videojuegos se guardan automáticamente en este dispositivo.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  /// Construye el menú compartido por la barra de escritorio y el cajón móvil.
  Widget _barra(BuildContext context, {bool cajon = false}) {
    /// Cierra primero el cajón móvil para que la acción navegue desde la página.
    void ejecutar(VoidCallback accion) {
      if (cajon) Navigator.pop(context);
      accion();
    }

    /// Crea una opción, resalta la activa y deshabilita las acciones no disponibles.
    Widget opcion(
      String texto,
      IconData icono,
      Seccion destino,
      VoidCallback? accion,
    ) {
      final seleccionada = seccion == destino;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            gradient: seleccionada
                ? const LinearGradient(
                    colors: [Color(0xFF7038CC), Color(0xFF5729A3)],
                  )
                : null,
          ),
          child: ListTile(
            dense: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            horizontalTitleGap: 10,
            leading: Icon(
              icono,
              size: 19,
              color: seleccionada ? Colors.white : Colores.texto,
            ),
            title: Text(
              texto,
              style: TextStyle(
                fontSize: 13,
                fontWeight: seleccionada ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            onTap: accion == null ? null : () => ejecutar(accion),
          ),
        ),
      );
    }

    // La marca encabeza el menú y Spacer mantiene los ajustes en la parte inferior.
    return Container(
      width: 208,
      decoration: const BoxDecoration(
        color: Color(0xFF141123),
        border: Border(right: BorderSide(color: Color(0xFF252036))),
      ),
      padding: const EdgeInsets.fromLTRB(14, 28, 14, 18),
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 10, bottom: 34),
              child: Row(
                children: [
                  Icon(
                    Icons.smart_display_outlined,
                    color: Colores.hover,
                    size: 25,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Watchlist',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            opcion(
              'Inicio',
              Icons.home_outlined,
              Seccion.inicio,
              () => _inicio(context),
            ),
            opcion(
              'Estadísticas',
              Icons.bar_chart_rounded,
              Seccion.estadisticas,
              onEstadisticas,
            ),
            const Spacer(),
            ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              leading: const Icon(Icons.settings_outlined, size: 19),
              horizontalTitleGap: 10,
              title: const Text('Ajustes', style: TextStyle(fontSize: 13)),
              onTap: () => ejecutar(() => _ajustes(context)),
            ),
          ],
        ),
      ),
    );
  }

  /// Adapta el marco al ancho y reserva el espacio restante para la pantalla hija.
  @override
  Widget build(BuildContext context) {
    // A partir de 760 píxeles lógicos el menú queda fijo; debajo usa un Drawer.
    final escritorio = MediaQuery.sizeOf(context).width >= 760;
    return Scaffold(
      drawer: escritorio
          ? null
          : Drawer(child: SafeArea(child: _barra(context, cajon: true))),
      body: SafeArea(
        child: Row(
          children: [
            if (escritorio) _barra(context),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topRight,
                    radius: 1.3,
                    colors: [Color(0xFF211735), Colores.fondo],
                  ),
                ),
                child: Stack(
                  children: [
                    // El adorno no intercepta pulsaciones ni lo lee el lector de pantalla.
                    const Positioned(
                      top: -24,
                      right: 12,
                      child: ExcludeSemantics(
                        child: IgnorePointer(
                          child: Opacity(
                            opacity: .08,
                            child: Icon(
                              Icons.movie_filter_outlined,
                              size: 180,
                              color: Colores.hover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            escritorio ? 32 : 12,
                            20,
                            24,
                            18,
                          ),
                          child: Row(
                            children: [
                              // Builder obtiene un contexto situado dentro del Scaffold.
                              if (!escritorio)
                                Builder(
                                  builder: (context) => IconButton(
                                    tooltip: 'Abrir menú',
                                    onPressed: () =>
                                        Scaffold.of(context).openDrawer(),
                                    icon: const Icon(Icons.menu),
                                  ),
                                ),
                              // Las pantallas de detalle y edición pueden mostrar Volver.
                              if (volver)
                                IconButton(
                                  tooltip: 'Volver',
                                  onPressed: () => Navigator.maybePop(context),
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    color: Colores.hover,
                                  ),
                                )
                              else
                                Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: Icon(
                                    seccion == Seccion.estadisticas
                                        ? Icons.bar_chart_rounded
                                        : Icons.movie_outlined,
                                    color: Colores.hover,
                                    size: 28,
                                  ),
                                ),
                              Expanded(
                                child: Text(
                                  titulo,
                                  style: const TextStyle(
                                    fontSize: 23,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // El contenido ocupa el alto libre bajo la cabecera común.
                        Expanded(child: child),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
