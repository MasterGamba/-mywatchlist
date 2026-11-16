import 'package:flutter/material.dart';

import '../datos/portadas.dart';
import '../modelos/elemento.dart';
import '../tema.dart';
import 'selector_estrellas.dart';

/// Elige el icono que representa cada categoría de contenido.
IconData iconoTipo(Tipo tipo) => switch (tipo) {
  Tipo.pelicula => Icons.movie_outlined,
  Tipo.serie => Icons.tv_rounded,
  Tipo.videojuego => Icons.sports_esports_outlined,
};

/// Portada remota con ilustración local si no hay URL o falla la carga.
class PortadaElemento extends StatelessWidget {
  const PortadaElemento({
    super.key,
    required this.elemento,
    this.width = 92,
    this.height = 78,
  });
  final Elemento elemento;
  final double width;
  final double height;

  /// Prioriza la URL del elemento y utiliza el mapa de títulos como alternativa.
  @override
  Widget build(BuildContext context) {
    final url = elemento.imagenUrl ?? portadasPorTitulo[elemento.titulo];
    // Esta ilustración evita dejar un hueco cuando no hay una imagen disponible.
    final portadaLocal = CustomPaint(
      painter: _PortadaPainter(elemento.tipo),
      child: Center(
        child: Icon(
          iconoTipo(elemento.tipo),
          size: width * .34,
          color: Colors.white.withValues(alpha: .85),
        ),
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: width,
        height: height,
        child: url == null || url.trim().isEmpty
            ? portadaLocal
            : Image.network(
                url,
                fit: BoxFit.cover,
                // Si la descarga falla, conserva una portada local visible.
                errorBuilder: (context, error, stackTrace) {
                  debugPrint(
                    'Error al cargar la portada de ${elemento.titulo}: $error',
                  );
                  return portadaLocal;
                },
              ),
      ),
    );
  }
}

/// Dibuja una portada decorativa local con colores distintos para cada tipo.
class _PortadaPainter extends CustomPainter {
  _PortadaPainter(this.tipo);
  final Tipo tipo;

  /// Pinta el degradado, un círculo de luz y tres formas curvas superpuestas.
  @override
  void paint(Canvas canvas, Size size) {
    final colores = switch (tipo) {
      Tipo.pelicula => [const Color(0xFFC75B16), const Color(0xFF30132A)],
      Tipo.serie => [const Color(0xFF3F8392), const Color(0xFF142238)],
      Tipo.videojuego => [const Color(0xFF8A72D8), const Color(0xFF28254C)],
    };
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colores,
        ).createShader(Offset.zero & size),
    );
    canvas.drawCircle(
      Offset(size.width * .7, size.height * .32),
      size.width * .29,
      Paint()..color = Colors.white.withValues(alpha: .14),
    );
    // Las coordenadas proporcionales adaptan el dibujo al tamaño de la portada.
    for (var i = 0; i < 3; i++) {
      final y = size.height * (.62 + i * .12);
      final path = Path()
        ..moveTo(0, y)
        ..quadraticBezierTo(
          size.width * .3,
          y - size.height * .4,
          size.width * .65,
          y,
        )
        ..quadraticBezierTo(
          size.width * .85,
          y + size.height * .15,
          size.width,
          y - size.height * .15,
        )
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(
        path,
        Paint()..color = colores.last.withValues(alpha: .35 + i * .2),
      );
    }
  }

  /// El dibujo solo necesita renovarse si cambia la categoría del elemento.
  @override
  bool shouldRepaint(covariant _PortadaPainter oldDelegate) =>
      tipo != oldDelegate.tipo;
}

/// Resume una entrada y comunica la pulsación a la pantalla mediante onTap.
class TarjetaElemento extends StatelessWidget {
  const TarjetaElemento({
    super.key,
    required this.elemento,
    required this.onTap,
    this.seleccionado = false,
  });
  final Elemento elemento;
  final VoidCallback onTap;
  final bool seleccionado;

  /// Resalta la selección y agrupa portada, título, estado y estrellas de lectura.
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    // La selección llega desde la lista y su cambio de aspecto se anima.
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: seleccionado
              ? [const Color(0xFF33204F), Colores.superficie]
              : [Colores.superficie, const Color(0xFF191628)],
        ),
        border: Border.all(
          color: seleccionado ? Colores.primario : const Color(0xFF282238),
        ),
        boxShadow: seleccionado
            ? [
                BoxShadow(
                  color: Colores.primario.withValues(alpha: .18),
                  blurRadius: 16,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                PortadaElemento(elemento: elemento),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        elemento.titulo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${elemento.tipo.etiqueta} · ${elemento.etiquetaEstado}',
                        style: const TextStyle(
                          color: Colores.secundario,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SelectorEstrellas(valor: elemento.valoracion),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.chevron_right, color: Colores.texto),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
