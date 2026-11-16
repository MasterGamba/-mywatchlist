import 'package:flutter/material.dart';

import '../modelos/elemento.dart';
import '../widgets/selector_estrellas.dart';
import '../widgets/marco_pagina.dart';
import '../widgets/tarjeta_elemento.dart';
import '../tema.dart';

/// Formulario compartido para crear una entrada o editar la recibida en inicial.
class PantallaFormulario extends StatefulWidget {
  const PantallaFormulario({
    super.key,
    this.inicial,
    this.onNuevo,
    this.onEstadisticas,
  });
  final Elemento? inicial;
  final VoidCallback? onNuevo;
  final VoidCallback? onEstadisticas;
  @override
  State<PantallaFormulario> createState() => _PantallaFormularioState();
}

/// Conserva los textos y selecciones mientras el usuario rellena los campos.
class _PantallaFormularioState extends State<PantallaFormulario> {
  // Una clave permite validar el formulario y la otra localizar el título con error.
  final _formKey = GlobalKey<FormState>();
  final _tituloKey = GlobalKey();
  late final TextEditingController _titulo;
  late final TextEditingController _notas;
  late Tipo _tipo;
  late Estado _estado;
  late int _valoracion;

  /// Rellena los controles con el elemento inicial o con valores por defecto.
  @override
  void initState() {
    super.initState();
    _titulo = TextEditingController(text: widget.inicial?.titulo ?? '');
    _notas = TextEditingController(text: widget.inicial?.notas ?? '');
    _tipo = widget.inicial?.tipo ?? Tipo.pelicula;
    _estado = widget.inicial?.estado ?? Estado.pendiente;
    _valoracion = widget.inicial?.valoracion ?? 0;
  }

  /// Libera ambos controladores al salir para no mantener recursos innecesarios.
  @override
  void dispose() {
    _titulo.dispose();
    _notas.dispose();
    super.dispose();
  }

  /// Valida y devuelve el resultado a la pantalla que abrió el formulario.
  void _guardar() {
    if (!_formKey.currentState!.validate()) {
      // Espera a mostrar el error antes de desplazar la vista al campo del título.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Scrollable.ensureVisible(
            _tituloKey.currentContext!,
            duration: const Duration(milliseconds: 180),
          );
        }
      });
      return;
    }
    // Normaliza espacios y conserva identidad y fecha cuando se está editando.
    final ahora = DateTime.now();
    final notas = _notas.text.trim();
    final elemento = Elemento(
      id: widget.inicial?.id ?? ahora.microsecondsSinceEpoch.toString(),
      titulo: _titulo.text.trim(),
      tipo: _tipo,
      estado: _estado,
      valoracion: _valoracion,
      notas: notas.isEmpty ? null : notas,
      imagenUrl: widget.inicial?.imagenUrl,
      fechaAlta: widget.inicial?.fechaAlta ?? ahora,
    );
    // El formulario entrega datos; la pantalla principal se encarga de guardarlos.
    Navigator.pop(context, elemento);
  }

  /// Organiza los campos desplazables y las acciones de guardar o cancelar.
  @override
  Widget build(BuildContext context) => MarcoPagina(
    titulo: widget.inicial == null ? 'Nuevo elemento' : 'Editar elemento',
    seccion: Seccion.nuevo,
    volver: widget.inicial != null,
    onNuevo: widget.onNuevo,
    onEstadisticas: widget.onEstadisticas,
    child: Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  children: [
                    // Se valida el texto sin espacios de los extremos, entre 1 y 60 caracteres.
                    TextFormField(
                      key: _tituloKey,
                      controller: _titulo,
                      decoration: const InputDecoration(
                        labelText: 'Título',
                        helperText: 'Entre 1 y 60 caracteres',
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      validator: (valor) {
                        if (valor == null || valor.trim().isEmpty) {
                          return 'Escribe un título';
                        }
                        if (valor.trim().length > 60) {
                          return 'El título admite un máximo de 60 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Los desplegables obtienen sus opciones de los enums del modelo.
                    DropdownButtonFormField<Tipo>(
                      initialValue: _tipo,
                      decoration: InputDecoration(
                        labelText: 'Tipo',
                        prefixIcon: Icon(
                          iconoTipo(_tipo),
                          color: Colores.hover,
                        ),
                      ),
                      items: Tipo.values
                          .map(
                            (tipo) => DropdownMenuItem(
                              value: tipo,
                              child: Text(tipo.etiqueta),
                            ),
                          )
                          .toList(),
                      onChanged: (tipo) => setState(() => _tipo = tipo!),
                    ),
                    const SizedBox(height: 20),
                    // La etiqueta en curso depende de si se está viendo o jugando.
                    DropdownButtonFormField<Estado>(
                      initialValue: _estado,
                      decoration: const InputDecoration(
                        labelText: 'Estado',
                        prefixIcon: Icon(
                          Icons.hourglass_empty_rounded,
                          color: Colores.hover,
                        ),
                      ),
                      items: Estado.values
                          .map(
                            (estado) => DropdownMenuItem(
                              value: estado,
                              child: Text(
                                estado == Estado.enCurso
                                    ? (_tipo == Tipo.videojuego
                                          ? 'Jugando'
                                          : 'Viendo')
                                    : estado.etiqueta,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (estado) => setState(() => _estado = estado!),
                    ),
                    const SizedBox(height: 24),
                    const Text('Valoración'),
                    Align(
                      alignment: Alignment.centerLeft,
                      // El selector avisa del cambio y el formulario conserva la valoración.
                      child: SelectorEstrellas(
                        valor: _valoracion,
                        onChanged: (valor) =>
                            setState(() => _valoracion = valor),
                      ),
                    ),
                    Text(
                      _valoracion == 0
                          ? 'Sin valorar'
                          : '$_valoracion de 5 estrellas',
                      style: const TextStyle(
                        color: Colores.secundario,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Las notas son opcionales y admiten varias líneas.
                    TextFormField(
                      controller: _notas,
                      minLines: 3,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        labelText: 'Notas (opcional)',
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),
              // Las acciones quedan fuera de la lista desplazable de campos.
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: FilledButton.icon(
                        onPressed: _guardar,
                        icon: const Icon(Icons.check),
                        label: const Text('Guardar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
