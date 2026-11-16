/// Categorías permitidas y sus etiquetas para mostrarlas en la interfaz.
enum Tipo {
  pelicula('Película'),
  serie('Serie'),
  videojuego('Videojuego');

  const Tipo(this.etiqueta);
  final String etiqueta;
}

/// Etapas de seguimiento; el estado en curso adapta su etiqueta al tipo.
enum Estado {
  pendiente('Pendiente'),
  enCurso('Viendo/Jugando'),
  terminado('Terminado');

  const Estado(this.etiqueta);
  final String etiqueta;
}

/// Datos de una entrada de la watchlist; sus campos no se reasignan al editar.
class Elemento {
  const Elemento({
    required this.id,
    required this.titulo,
    required this.tipo,
    required this.estado,
    required this.fechaAlta,
    this.valoracion = 0,
    this.notas,
    this.imagenUrl,
  }) : assert(valoracion >= 0 && valoracion <= 5);
  // El id identifica la entrada aunque cambien su título, estado o valoración.
  final String id;
  final String titulo;
  final Tipo tipo;
  final Estado estado;
  final int valoracion;
  final String? notas;
  final String? imagenUrl;
  final DateTime fechaAlta;

  /// Muestra «Jugando» para videojuegos y «Viendo» para películas y series.
  String get etiquetaEstado => estado == Estado.enCurso
      ? (tipo == Tipo.videojuego ? 'Jugando' : 'Viendo')
      : estado.etiqueta;

  /// Prepara datos compatibles con JSON: enums por nombre y fecha como texto.
  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': titulo,
    'tipo': tipo.name,
    'estado': estado.name,
    'valoracion': valoracion,
    'notas': notas,
    'imagenUrl': imagenUrl,
    'fechaAlta': fechaAlta.toIso8601String(),
  };

  /// Reconstruye un elemento y rechaza datos obligatorios con valores inválidos.
  factory Elemento.fromJson(Map<String, dynamic> json) {
    final titulo = json['titulo'] as String;
    final id = json['id'] as String;
    final valoracion = json['valoracion'] as int;
    // Esta validación protege también la carga de datos ajenos al formulario.
    if (id.isEmpty ||
        titulo.trim().isEmpty ||
        titulo.trim().length > 60 ||
        valoracion < 0 ||
        valoracion > 5) {
      throw const FormatException('Elemento no válido');
    }
    // Las notas y la imagen pueden faltar en datos guardados anteriormente.
    return Elemento(
      id: id,
      titulo: titulo,
      tipo: Tipo.values.byName(json['tipo'] as String),
      estado: Estado.values.byName(json['estado'] as String),
      valoracion: valoracion,
      notas: json['notas'] as String?,
      imagenUrl: json['imagenUrl'] as String?,
      fechaAlta: DateTime.parse(json['fechaAlta'] as String),
    );
  }

  /// Crea una copia con los cambios pedidos conservando el id y la fecha.
  /// borrarNotas distingue eliminar las notas de conservar las que ya había.
  Elemento copyWith({
    String? titulo,
    Tipo? tipo,
    Estado? estado,
    int? valoracion,
    String? notas,
    String? imagenUrl,
    bool borrarNotas = false,
  }) => Elemento(
    id: id,
    titulo: titulo ?? this.titulo,
    tipo: tipo ?? this.tipo,
    estado: estado ?? this.estado,
    valoracion: valoracion ?? this.valoracion,
    notas: borrarNotas ? null : (notas ?? this.notas),
    imagenUrl: imagenUrl ?? this.imagenUrl,
    fechaAlta: fechaAlta,
  );
}
