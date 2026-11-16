import 'package:flutter/material.dart';

import '../modelos/elemento.dart';
import '../servicios/almacen.dart';
import '../widgets/tarjeta_elemento.dart';
import '../widgets/marco_pagina.dart';
import 'pantalla_detalle.dart';
import 'pantalla_estadisticas.dart';
import 'pantalla_formulario.dart';

/// Pantalla principal y propietaria de la lista completa de elementos.
class PantallaLista extends StatefulWidget {
  const PantallaLista({super.key, this.almacen});
  // Permite inyectar otro almacén en pruebas, por ejemplo uno que simule fallos.
  final Almacen? almacen;
  @override
  State<PantallaLista> createState() => _PantallaListaState();
}

/// Mantiene datos, filtros y operaciones de carga y guardado entre reconstrucciones.
class _PantallaListaState extends State<PantallaLista> {
  // La lista completa se conserva; los filtros solo afectan a la vista calculada.
  final _busqueda = TextEditingController();
  late final Almacen _almacen;
  List<Elemento> _elementos = [];
  Estado? _filtro;
  Tipo? _filtroTipo;
  // Estas banderas controlan los indicadores y evitan acciones incompatibles.
  bool _cargando = true;
  bool _guardando = false;
  bool _errorCarga = false;
  String? _seleccionado;

  /// Prepara el almacén y lanza la lectura asíncrona al crear la pantalla.
  @override
  void initState() {
    super.initState();
    _almacen = widget.almacen ?? Almacen();
    _cargar();
  }

  /// Libera el controlador de búsqueda cuando la pantalla deja de existir.
  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  /// Recupera los datos y distingue la espera, el éxito y un error de lectura.
  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _errorCarga = false;
    });
    try {
      final datos = await _almacen.cargar();
      // Después de await, mounted evita actualizar una pantalla ya destruida.
      if (mounted) setState(() => _elementos = datos);
    } catch (_) {
      if (mounted) setState(() => _errorCarga = true);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  /// Persiste una lista propuesta y solo la muestra si la escritura termina bien.
  Future<bool> _guardar(List<Elemento> propuesta) async {
    // Impide solapar escrituras que podrían guardar versiones distintas.
    if (_guardando) return false;
    setState(() => _guardando = true);
    try {
      await _almacen.guardar(propuesta);
      if (!mounted) return false;
      setState(() => _elementos = propuesta);
      return true;
    } catch (_) {
      return false;
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  /// Abre el formulario y recoge el elemento devuelto; cancelar devuelve null.
  Future<void> _alta() async {
    final nuevo = await Navigator.push<Elemento>(
      context,
      MaterialPageRoute(
        builder: (_) => PantallaFormulario(
          onNuevo: _irNuevo,
          onEstadisticas: _irEstadisticas,
        ),
      ),
    );
    if (nuevo != null && mounted) await _guardarAlta(nuevo);
  }

  /// Añade sin duplicar el id y ofrece reintentar cuando falla el guardado.
  Future<void> _guardarAlta(Elemento nuevo) async {
    if (_elementos.any((e) => e.id == nuevo.id)) return;
    // El operador ... copia las entradas existentes a la nueva lista propuesta.
    final exito = await _guardar([..._elementos, nuevo]);
    if (!mounted || exito) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('No se pudo guardar el elemento.'),
        action: SnackBarAction(
          label: 'Reintentar',
          onPressed: () => _guardarAlta(nuevo),
        ),
      ),
    );
  }

  /// Vuelve a la ruta inicial antes de abrir otro formulario desde el menú.
  void _irNuevo() {
    Navigator.of(context).popUntil((r) => r.isFirst);
    _alta();
  }

  /// Abre estadísticas con una copia de la lista y evita acumular rutas del menú.
  void _irEstadisticas() {
    Navigator.of(context).popUntil((r) => r.isFirst);
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => PantallaEstadisticas(
          elementos: List.of(_elementos),
          onNuevo: _irNuevo,
          onEstadisticas: _irEstadisticas,
        ),
      ),
    );
  }

  /// Abre el detalle y le proporciona las operaciones de actualizar y borrar.
  void _detalle(Elemento elemento) {
    setState(() => _seleccionado = elemento.id);
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => PantallaDetalle(
          elemento: elemento,
          onNuevo: _irNuevo,
          onEstadisticas: _irEstadisticas,
          // El id permite reemplazar la entrada aunque su título haya cambiado.
          onActualizar: (editado) => _guardar(
            _elementos.map((e) => e.id == editado.id ? editado : e).toList(),
          ),
          // Se propone una lista nueva que excluye únicamente el id borrado.
          onBorrar: () =>
              _guardar(_elementos.where((e) => e.id != elemento.id).toList()),
        ),
      ),
    );
  }

  /// Restablece ambos filtros y el texto de búsqueda en una reconstrucción.
  void _limpiar() {
    setState(() {
      _filtro = null;
      _filtroTipo = null;
      _busqueda.clear();
    });
  }

  /// Calcula los resultados visibles y muestra carga, error, vacío o tarjetas.
  @override
  Widget build(BuildContext context) {
    final disponible = !_cargando && !_guardando && !_errorCarga;
    final texto = _busqueda.text.trim().toLowerCase();
    // Las condiciones se combinan con &&: cada resultado debe cumplirlas todas.
    final visibles = _elementos
        .where(
          (e) =>
              (_filtro == null || e.estado == _filtro) &&
              (_filtroTipo == null || e.tipo == _filtroTipo) &&
              e.titulo.toLowerCase().contains(texto),
        )
        .toList();
    // Durante una carga o un guardado se deshabilitan las acciones principales.
    return MarcoPagina(
      titulo: 'Mi Watchlist',
      onNuevo: disponible ? _alta : null,
      onEstadisticas: disponible ? _irEstadisticas : null,
      floatingActionButton: FloatingActionButton(
        onPressed: disponible ? _alta : null,
        tooltip: 'Añadir elemento',
        child: const Icon(Icons.add),
      ),

      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            // La carga y el error se resuelven antes de presentar el contenido.
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : _errorCarga
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('No se pudo cargar tu lista.'),
                        TextButton(
                          onPressed: _cargar,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      if (_guardando) const LinearProgressIndicator(),
                      // Cada cambio de texto reconstruye la vista con la búsqueda actual.
                      if (_elementos.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: TextField(
                            controller: _busqueda,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Buscar por título...',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: texto.isEmpty
                                  ? null
                                  : IconButton(
                                      tooltip: 'Limpiar búsqueda',
                                      onPressed: () =>
                                          setState(() => _busqueda.clear()),
                                      icon: const Icon(Icons.close),
                                    ),
                            ),
                          ),
                        ),
                      if (_elementos.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ChoiceChip(
                                  label: const Text('Todos'),
                                  selected: _filtro == null,
                                  onSelected: (_) =>
                                      setState(() => _filtro = null),
                                ),
                                // null representa «Todos»; los enums crean el resto de opciones.
                                for (final estado in Estado.values)
                                  ChoiceChip(
                                    label: Text(estado.etiqueta),
                                    selected: _filtro == estado,
                                    onSelected: (_) =>
                                        setState(() => _filtro = estado),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      if (_elementos.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ChoiceChip(
                                  label: const Text('Todos los tipos'),
                                  selected: _filtroTipo == null,
                                  onSelected: (_) =>
                                      setState(() => _filtroTipo = null),
                                ),
                                // Este filtro se combina con el estado y con el título buscado.
                                for (final tipo in Tipo.values)
                                  ChoiceChip(
                                    label: Text(tipo.etiqueta),
                                    selected: _filtroTipo == tipo,
                                    onSelected: (_) =>
                                        setState(() => _filtroTipo = tipo),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      // Distingue una lista sin entradas de una búsqueda sin coincidencias.
                      Expanded(
                        child: visibles.isEmpty
                            ? Center(
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _elementos.isEmpty
                                            ? Icons.movie_creation_outlined
                                            : Icons.search_off,
                                        size: 96,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        _elementos.isEmpty
                                            ? 'Tu lista está vacía'
                                            : 'No hay resultados',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _elementos.isEmpty
                                            ? 'Guarda tu próxima película, serie o videojuego.'
                                            : 'Prueba otro título o cambia los filtros.',
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 20),
                                      FilledButton.icon(
                                        icon: const Icon(Icons.add, size: 20),
                                        onPressed: _elementos.isEmpty
                                            ? (disponible ? _alta : null)
                                            : _limpiar,
                                        label: Text(
                                          _elementos.isEmpty
                                              ? 'Añadir el primero'
                                              : 'Limpiar búsqueda y filtros',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            // Las tarjetas se construyen según se necesitan al desplazarse.
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  0,
                                  12,
                                  96,
                                ),
                                itemCount: visibles.length,
                                itemBuilder: (_, i) => TarjetaElemento(
                                  elemento: visibles[i],
                                  seleccionado: _seleccionado == visibles[i].id,
                                  onTap: () {
                                    if (!_guardando) _detalle(visibles[i]);
                                  },
                                ),
                              ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
