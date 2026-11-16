import 'package:flutter/material.dart';

import '../modelos/elemento.dart';
import '../widgets/selector_estrellas.dart';
import '../widgets/tarjeta_elemento.dart';
import '../widgets/marco_pagina.dart';
import '../tema.dart';
import 'pantalla_formulario.dart';

/// Muestra una entrada y pide a la lista principal que guarde sus cambios.
class PantallaDetalle extends StatefulWidget {
  const PantallaDetalle({
    super.key,
    required this.elemento,
    required this.onActualizar,
    required this.onBorrar,
    this.onNuevo,
    this.onEstadisticas,
  });
  final Elemento elemento;
  final VoidCallback? onNuevo;
  final VoidCallback? onEstadisticas;
  // Los callbacks informan del éxito para no mostrar cambios que no se guardaron.
  final Future<bool> Function(Elemento) onActualizar;
  final Future<bool> Function() onBorrar;
  @override
  State<PantallaDetalle> createState() => _PantallaDetalleState();
}

/// Mantiene el elemento mostrado y bloquea acciones durante una escritura.
class _PantallaDetalleState extends State<PantallaDetalle> {
  late Elemento _elemento;
  bool _ocupado = false;

  /// Copia la referencia inicial para poder sustituirla tras una edición guardada.
  @override
  void initState() {
    super.initState();
    _elemento = widget.elemento;
  }

  /// Reutiliza el formulario con los datos actuales y descarta una cancelación.
  Future<void> _editar() async {
    final editado = await Navigator.push<Elemento>(
      context,
      MaterialPageRoute(
        builder: (_) => PantallaFormulario(
          inicial: _elemento,
          onNuevo: widget.onNuevo,
          onEstadisticas: widget.onEstadisticas,
        ),
      ),
    );
    if (editado == null || !mounted) return;
    await _actualizar(editado);
  }

  /// Solicita guardar la edición y actualiza el detalle solo si tiene éxito.
  Future<void> _actualizar(Elemento editado) async {
    if (!mounted || _ocupado) return;
    setState(() => _ocupado = true);
    final exito = await widget.onActualizar(editado);
    if (!mounted) return;
    setState(() {
      _ocupado = false;
      if (exito) _elemento = editado;
    });
    if (!exito) _error(() => _actualizar(editado));
  }

  /// Muestra el fallo y recibe la operación concreta que debe poder reintentarse.
  void _error(VoidCallback reintentar) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'No se pudo guardar. Tus datos anteriores se conservan.',
        ),
        action: SnackBarAction(label: 'Reintentar', onPressed: reintentar),
      ),
    );
  }

  /// Espera la respuesta del diálogo y borra únicamente al recibir true.
  Future<void> _confirmarBorrado() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Borrar elemento?'),
        content: Text('Se eliminará «${_elemento.titulo}» de tu lista.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (confirmado != true || !mounted) return;
    await _borrar();
  }

  /// Solicita el borrado, vuelve a la lista si funciona y ofrece reintento si falla.
  Future<void> _borrar() async {
    if (!mounted || _ocupado) return;
    setState(() => _ocupado = true);
    final exito = await widget.onBorrar();
    if (!mounted) return;
    setState(() => _ocupado = false);
    if (exito) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Elemento borrado')));
      Navigator.pop(context);
    } else {
      _error(_borrar);
    }
  }

  /// Presenta portada, datos, fecha y notas junto a las acciones del elemento.
  @override
  Widget build(BuildContext context) {
    final fecha = _elemento.fechaAlta.toLocal();
    // Evita abandonar el detalle con el botón Atrás durante una escritura.
    return PopScope(
      canPop: !_ocupado,
      child: MarcoPagina(
        titulo: 'Detalle',
        volver: true,
        onNuevo: _ocupado ? null : widget.onNuevo,
        onEstadisticas: _ocupado ? null : widget.onEstadisticas,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // Cabecera del elemento: portada, título, tipo, estado y valoración.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PortadaElemento(
                      elemento: _elemento,
                      width: 110,
                      height: 148,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SelectableText(
                            _elemento.titulo,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_elemento.tipo.etiqueta} · ${_elemento.etiquetaEstado}',
                            style: const TextStyle(color: Colores.secundario),
                          ),
                          const SizedBox(height: 12),
                          SelectorEstrellas(valor: _elemento.valoracion),
                          if (_elemento.valoracion == 0)
                            const Text('Sin valorar'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: Colores.hover,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        'Fecha de alta: ${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // El texto alternativo hace explícito que no se escribieron notas.
                Text('Notas', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(minHeight: 100),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colores.superficie,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colores.borde),
                  ),
                  child: SelectableText(_elemento.notas ?? 'Sin notas'),
                ),
                // Los botones quedan deshabilitados mientras responde el almacén.
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _ocupado ? null : _editar,
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Editar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _ocupado ? null : _confirmarBorrado,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Borrar'),
                      ),
                    ),
                  ],
                ),
                if (_ocupado)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
