import 'package:flutter/material.dart';

/// Muestra cinco estrellas; con onChanged permite cambiar o quitar la nota.
class SelectorEstrellas extends StatelessWidget {
  const SelectorEstrellas({super.key, required this.valor, this.onChanged});
  final int valor;
  final ValueChanged<int>? onChanged;

  /// Añade una descripción accesible y construye las estrellas según valor.
  @override
  Widget build(BuildContext context) => Semantics(
    label: '$valor de 5 estrellas${valor == 0 ? ', sin valorar' : ''}',
    child: Row(
      mainAxisSize: MainAxisSize.min,
      // El índice empieza en cero, pero cada estrella representa de 1 a 5.
      children: List.generate(5, (i) {
        final icono = Icon(
          i < valor ? Icons.star_rounded : Icons.star_border_rounded,
          color: Theme.of(context).colorScheme.primary,
          size: onChanged == null ? 21 : 28,
        );
        // Sin callback es de lectura; repetir la selección devuelve cero.
        return onChanged == null
            ? icono
            : IconButton(
                tooltip: valor == i + 1
                    ? 'Quitar valoración'
                    : '${i + 1} estrellas',
                onPressed: () => onChanged!(valor == i + 1 ? 0 : i + 1),
                icon: icono,
              );
      }),
    ),
  );
}
