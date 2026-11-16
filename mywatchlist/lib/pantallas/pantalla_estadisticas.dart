import 'package:flutter/material.dart';

import '../modelos/elemento.dart';
import '../tema.dart';
import '../widgets/marco_pagina.dart';

/// Resume los elementos recibidos y permite limitar los cálculos a un tipo.
class PantallaEstadisticas extends StatefulWidget {
  const PantallaEstadisticas({
    super.key,
    required this.elementos,
    this.onNuevo,
    this.onEstadisticas,
  });
  final List<Elemento> elementos;
  final VoidCallback? onNuevo;
  final VoidCallback? onEstadisticas;

  @override
  State<PantallaEstadisticas> createState() => _PantallaEstadisticasState();
}

/// Conserva el filtro local sin modificar la lista original de la aplicación.
class _PantallaEstadisticasState extends State<PantallaEstadisticas> {
  Tipo? _filtroTipo;

  /// Construye una tarjeta de resumen con icono, etiqueta y valor destacado.
  Widget _resumen(
    BuildContext context,
    IconData icono,
    String titulo,
    String valor,
  ) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colores.superficie,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        Icon(icono, size: 32, color: Colores.hover),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(fontSize: 12, color: Colores.secundario),
              ),
              const SizedBox(height: 4),
              Text(
                valor.contains(': ') ? valor.split(': ').last : valor,
                semanticsLabel: valor,
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  /// Calcula los indicadores y organiza tarjetas, barras y tipo más frecuente.
  @override
  Widget build(BuildContext context) {
    // Todos los cálculos parten de los elementos incluidos por el filtro local.
    final elementos = widget.elementos
        .where((e) => _filtroTipo == null || e.tipo == _filtroTipo)
        .toList();
    // Cero significa «sin valorar»; la lista vacía evita dividir entre cero.
    final valorados = elementos.where((e) => e.valoracion > 0).toList();
    final media = valorados.isEmpty
        ? null
        : valorados.fold<int>(0, (suma, e) => suma + e.valoracion) /
              valorados.length;
    // Cuenta cada categoría y conserva todas las que empatan en el máximo.
    final porTipo = {
      for (final tipo in Tipo.values)
        tipo: elementos.where((e) => e.tipo == tipo).length,
    };
    final maximo = porTipo.values.reduce((a, b) => a > b ? a : b);
    final favoritos = porTipo.entries
        .where((e) => e.value == maximo)
        .map((e) => e.key.etiqueta)
        .join(', ');
    // La media se presenta con un decimal y coma; sin puntuaciones hay un mensaje.
    final valorMedia = media == null
        ? 'Sin valoraciones'
        : '${media.toStringAsFixed(1).replaceAll('.', ',')} / 5';
    return MarcoPagina(
      titulo: 'Estadísticas',
      seccion: Seccion.estadisticas,
      onNuevo: widget.onNuevo,
      onEstadisticas: widget.onEstadisticas,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            children: [
              // Al cambiar el chip se reconstruyen los cálculos con el nuevo tipo.
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Todos los tipos'),
                    selected: _filtroTipo == null,
                    onSelected: (_) => setState(() => _filtroTipo = null),
                  ),
                  for (final tipo in Tipo.values)
                    ChoiceChip(
                      label: Text(tipo.etiqueta),
                      selected: _filtroTipo == tipo,
                      onSelected: (_) => setState(() => _filtroTipo = tipo),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              // Las tarjetas se apilan en móvil y se alinean en una fila si caben.
              LayoutBuilder(
                builder: (context, constraints) {
                  final tarjetas = [
                    _resumen(
                      context,
                      Icons.layers_outlined,
                      'Total',
                      'Total: ${elementos.length}',
                    ),
                    _resumen(
                      context,
                      Icons.star_border_rounded,
                      'Valoración media',
                      media == null
                          ? valorMedia
                          : 'Valoración media: $valorMedia',
                    ),
                  ];
                  if (constraints.maxWidth < 600) {
                    return Column(
                      children: [
                        tarjetas[0],
                        const SizedBox(height: 12),
                        tarjetas[1],
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: tarjetas[0]),
                      const SizedBox(width: 16),
                      Expanded(child: tarjetas[1]),
                    ],
                  );
                },
              ),
              const SizedBox(height: 36),
              // Cada barra representa la proporción de un estado sobre el total filtrado.
              for (final estado in Estado.values) ...[
                Builder(
                  builder: (context) {
                    final cantidad = elementos
                        .where((e) => e.estado == estado)
                        .length;
                    // Una lista vacía produce barras al cero por ciento.
                    final proporcion = elementos.isEmpty
                        ? 0.0
                        : cantidad / elementos.length;
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${estado.etiqueta}: $cantidad'),
                            Text(
                              '${(proporcion * 100).round()}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: proporcion,
                          minHeight: 12,
                          borderRadius: BorderRadius.circular(8),
                          color: Colores.primario,
                          backgroundColor: Colores.superficie,
                          semanticsLabel: estado.etiqueta,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 28),
              ],
              const SizedBox(height: 8),
              // Evita anunciar un tipo favorito cuando no hay elementos.
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colores.superficie,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.sports_esports_outlined,
                      color: Colores.hover,
                      size: 28,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        elementos.isEmpty
                            ? 'Tipo más frecuente: sin datos'
                            : 'Tipo más frecuente: $favoritos',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
