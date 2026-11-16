# Bitácora de uso de IA

Fecha de la sesión: 12/11/2026. Herramienta: Codex.

El usuario solicitó inicialmente un plan basado en `enunciado.md` y después pidió «PLEASE IMPLEMENT THIS PLAN:», seguido del plan completo de la conversación. La implementación técnica se realizó agrupada en esta sesión; las fases siguientes organizan sus resultados y no certifican que el alumno haya realizado cada fase, revisado el código o respondido sus preguntas.

No se utilizaron subagentes. No se han inventado prompts independientes ni reflexiones del alumno. El detalle de las comprobaciones está en `verificacion.md`.

## Fase 0 · Preparación y diseño

**Herramienta usada:** Codex para inspeccionar el proyecto y preparar carpetas.

**Prompt principal:** solicitud de implementación indicada al inicio de este documento.

**Qué dio la IA y qué hizo:** conservó el proyecto Flutter existente, sustituyó la demostración del contador y preparó la estructura obligatoria. No creó un boceto atribuido al alumno.

**Trabajo personal pendiente:** dibujar las cuatro pantallas y sus flechas de navegación; añadir `docs/boceto.png`.

## Fase 1 · Modelo de datos

**Herramienta y prompt:** Codex; solicitud general de implementación.

**Resultado técnico:** modelo inmutable, enums, JSON y `copyWith`. `borrarNotas` permite diferenciar conservar las notas de eliminarlas. Los datos de ejemplo se usan en pruebas y capturas, sin dejar una carga ficticia en producción.

**Acepté / modifiqué / descarté:** pendiente de revisión del alumno.

**Errores detectados:** consultar las correcciones técnicas de la fase 8.

**Lo que he aprendido:** pendiente de escribir por el alumno.

**Preguntas, para responder sin IA:**
1. ¿Por qué los campos son `final`? ¿Cómo cambias el estado?
   `final` impide reasignar cada campo después de crear el objeto. Para cambiar el estado se crea otro `Elemento` con `copyWith(estado: Estado.terminado)` y se sustituye el anterior en la lista, conservando su `id` y los demás datos.
2. ¿Cómo se guarda y recupera un enum en JSON?
   `toJson()` guarda su nombre como texto mediante `tipo.name` y `estado.name`. `fromJson()` recupera el valor con `Tipo.values.byName(...)` o `Estado.values.byName(...)`. Se guarda el nombre del enum, no su etiqueta visible.
3. ¿Qué ocurre si faltan las notas en el JSON?
   Al consultar una clave ausente, `json['notas']` devuelve `null`. Como se convierte a `String?`, se acepta ese valor y el elemento se crea sin notas.

## Fase 2 · Lista y tarjeta

**Herramienta y prompt:** Codex; solicitud general de implementación.

**Resultado técnico:** lista con construcción bajo demanda, tarjeta con callback, estrellas de lectura y estado vacío con acceso al formulario.

**Acepté / modifiqué / descarté:** pendiente de revisión del alumno.

**Lo que he aprendido:** pendiente de escribir por el alumno.

**Preguntas, para responder sin IA:**
1. ¿Cuándo conviene `ListView.builder` frente a `ListView`?
   `ListView.builder` crea los hijos según se necesitan al desplazarse y conviene para listas grandes o de longitud variable. `ListView(children: [...])` recibe los widgets ya construidos y resulta sencillo para pocos elementos fijos, como los campos de un formulario.
2. ¿Por qué la tarjeta recibe una función en vez de navegar ella misma?
   Así la tarjeta solo muestra los datos y avisa de la pulsación mediante `onTap`. La pantalla que la utiliza decide qué hacer, por lo que puede reutilizarse sin depender de una pantalla de destino.
3. ¿Por qué la tarjeta utiliza ese tipo de widget?
   `TarjetaElemento` es un `StatelessWidget` porque recibe los datos y callbacks desde fuera y no mantiene un estado propio que deba cambiar con `setState`. Cuando cambia la selección o el elemento, su pantalla padre la reconstruye con los nuevos valores.

## Fase 3 · Formulario de alta

**Herramienta y prompt:** Codex; solicitud general de implementación.

**Resultado técnico:** formulario validado, controladores liberados, desplegables, estrellas interactivas, notas opcionales y devolución del resultado por navegación.

**Acepté / modifiqué / descarté:** pendiente de revisión del alumno.

**Lo que he aprendido:** pendiente de escribir por el alumno.

**Preguntas, para responder sin IA:**
1. ¿Qué hace `validate()` y qué significa `!`?
   `validate()` ejecuta los validadores de los campos del `Form`, muestra sus errores y devuelve `true` si todos son válidos. En `_formKey.currentState!`, `!` afirma que el estado no es nulo; si lo fuera, se produciría un error en ejecución. Si la validación falla, `_guardar()` termina sin devolver un elemento.
2. ¿Por qué hay que llamar a `dispose()`?
   Los `TextEditingController` mantienen recursos y escuchas. Al destruir la pantalla se liberan con `_titulo.dispose()` y `_notas.dispose()`, y después se llama a `super.dispose()` para completar la limpieza del estado.
3. ¿Qué recorrido sigue el dato desde Guardar hasta la lista?
   `_guardar()` valida, lee los campos y crea un `Elemento`. `Navigator.pop(context, elemento)` lo devuelve a `_alta()`, que esperaba el resultado de `Navigator.push`. Si no es nulo, `_guardarAlta()` prepara una lista con el nuevo elemento y `_guardar()` espera a persistirla. Solo si el guardado funciona actualiza `_elementos` con `setState`, y la lista se reconstruye.

## Fase 4 · Detalle, edición y borrado

**Herramienta y prompt:** Codex; solicitud general de implementación.

**Resultado técnico:** detalle con todos los campos, reutilización del formulario, conservación de identidad y fecha, confirmación de borrado y aviso de resultado. Las escrituras fallidas permiten reintentar.

**Acepté / modifiqué / descarté:** pendiente de revisión del alumno.

**Lo que he aprendido:** pendiente de escribir por el alumno.

**Preguntas, para responder sin IA:**
1. ¿Cómo distingue el formulario creación y edición?
   Mediante el parámetro opcional `inicial`. Si es `null`, usa valores por defecto y crea un `id` y una fecha nuevos. Si contiene un elemento, rellena los campos con sus datos y conserva su `id` y `fechaAlta` al guardar. Cancelar devuelve `null` y no aplica cambios.
2. ¿Cómo encuentra la lista el elemento que debe reemplazar?
   El detalle envía el elemento editado al callback `onActualizar`. La lista recorre `_elementos` con `map` y compara cada `id` con `editado.id`: sustituye la coincidencia por el editado y conserva el resto. La lista propuesta se guarda antes de actualizar la pantalla.
3. ¿Qué devuelve `showDialog` y cómo se usa?
   `showDialog<bool>` devuelve un `Future<bool?>`. Tras `await`, el resultado es `true` al confirmar, `false` al pulsar Cancelar o puede ser `null` al cerrar sin una respuesta. El código solo llama a `_borrar()` si `confirmado == true` y la pantalla sigue montada.

## Fase 5 · Filtro y búsqueda

**Herramienta y prompt:** Codex; solicitud general de implementación.

**Resultado técnico:** filtros de estado y búsqueda sin distinguir mayúsculas aplicados simultáneamente a una lista calculada. Mensaje específico para resultados vacíos y opción de restablecer filtros.

**Acepté / modifiqué / descarté:** pendiente de revisión del alumno.

**Lo que he aprendido:** pendiente de escribir por el alumno.

**Preguntas, para responder sin IA:**
1. ¿Por qué no se modifica la lista original al filtrar?
   Filtrar solo debe cambiar qué elementos se ven, no eliminar datos. Se calcula `visibles` con `where(...).toList()` a partir de `_elementos`, de forma que al limpiar los filtros vuelven a aparecer los demás.
2. ¿Cómo puede «dune» encontrar «Dune»?
   Se convierte tanto el texto buscado como el título a minúsculas con `toLowerCase()` y después se utiliza `contains(texto)`. Así la comparación no distingue mayúsculas y minúsculas.
3. ¿Qué ocurre al buscar un pendiente con el filtro Terminado?
   Ese elemento no aparece porque las condiciones del filtro y de la búsqueda se unen con `&&`: debe cumplir ambas. Si ningún otro elemento coincide, se muestra el mensaje de que no hay resultados. Esto describe el comportamiento del código; no certifica una comprobación manual del alumno.

## Fase 6 · Persistencia

**Herramienta y prompt:** Codex; solicitud general de implementación.

**Resultado técnico:** almacenamiento local bajo la clave `watchlist`, carga con indicador, recuperación de JSON corrupto y guardado tras alta, edición y borrado. Se impiden escrituras simultáneas.

**Problemas de entorno:** la instalación de plugins encontró inicialmente restricciones de enlaces simbólicos de Windows; se prepararon junctions locales en carpetas efímeras para las comprobaciones.

**Acepté / modifiqué / descarté:** pendiente de revisión del alumno.

**Lo que he aprendido:** pendiente de escribir por el alumno.

**Preguntas, para responder sin IA:**
1. ¿Por qué `cargar()` devuelve un `Future`?
   Obtener las preferencias es una operación asíncrona, por lo que la lista no está disponible inmediatamente. `Future<List<Elemento>>` representa su resultado futuro y permite esperarlo con `await`. Mientras llega, la pantalla muestra un indicador de carga en lugar de presentar la lista inicial vacía como si fuera definitiva.
2. ¿Cómo se inicia la carga desde `initState`?
   `initState()` debe seguir siendo un método síncrono que devuelve `void`, por lo que no se convierte en `async` para esperar la lectura. Inicializa `_almacen` y llama a `_cargar()`, que sí es asíncrona. Esta espera `_almacen.cargar()` y actualiza la pantalla con `setState` tras comprobar `mounted`.
3. ¿Dónde se guardan los datos y qué ocurre al desinstalar?
   `Almacen` convierte toda la lista en un texto JSON y lo guarda con la clave `watchlist` mediante `shared_preferences`. En una aplicación nativa está en el almacenamiento local de preferencias de esa instalación; en web, en el almacenamiento local del navegador para ese sitio. Desinstalar normalmente elimina los datos locales, aunque una copia de seguridad del sistema podría restaurarlos. En web también se pierden al borrar los datos del sitio; este proyecto no tiene sincronización propia.

## Fase 7 · Estadísticas y tema

**Herramienta y prompt:** Codex; solicitud general de implementación.

**Resultado técnico:** recuentos y barras por estado, media de valorados y tipo más frecuente con empates. Tema Material de semilla violeta.

**Acepté / modifiqué / descarté:** pendiente de revisión del alumno.

**Lo que he aprendido:** pendiente de escribir por el alumno.

**Preguntas, para responder sin IA:**
1. ¿Cómo se evita dividir entre cero?
   Primero se crea la lista `valorados` con los elementos cuya valoración es mayor que cero. Si está vacía, `media` toma el valor `null` y no se ejecuta ninguna división. Solo si tiene elementos se divide la suma de estrellas entre `valorados.length`.
2. ¿Por qué no cuentan las valoraciones de cero?
   En este modelo, cero significa «sin valorar», no una puntuación de cero estrellas. Incluirlo reduciría la media con elementos que todavía no tienen una valoración.
3. ¿Qué ventajas tiene centralizar los colores en el tema?
   Permite mantener una apariencia coherente y cambiar los colores compartidos desde un único lugar. `ThemeData` y el esquema de colores proporcionan valores comunes a los componentes, evitando repetir la misma configuración en cada pantalla.

## Fase 8 · Pruebas y documentación

**Herramienta y prompt:** Codex; solicitud general de implementación.

**Resultado técnico:** pruebas de modelo, formulario, almacenamiento, operaciones de la lista, filtros, estadísticas y errores de guardado; README, guía de defensa y registro de verificación.

**Errores de la IA detectados y corregidos:** un paréntesis adicional en estadísticas; dos condiciones sin llaves señaladas por el analizador; pruebas que no esperaban a reconstruir la búsqueda o a desplazar el botón Cancelar antes de pulsarlo. El primer parche se rechazó por intentar borrar y crear el mismo archivo en una sola operación; se corrigió sin perder archivos del usuario.

**Acepté / modifiqué / descarté:** pendiente de revisión del alumno.

**Lo que he aprendido:** pendiente de escribir por el alumno.

**Preguntas, para responder sin IA:**
1. ¿Qué diferencia hay entre una prueba unitaria y una de widget?
   Una prueba unitaria comprueba lógica aislada, como convertir un `Elemento` a JSON y recuperarlo o utilizar `copyWith`, sin montar una interfaz. Una prueba de widget monta widgets en el entorno de pruebas, simula acciones y comprueba lo que aparece, como el error al guardar un título vacío.
2. ¿Qué hace `tester.pump()` y cuándo hace falta?
   Procesa un fotograma del entorno de pruebas y permite aplicar las reconstrucciones pendientes. Después de una pulsación que cambia el estado, se utiliza para que la interfaz refleje el cambio antes de comprobarla. `pumpAndSettle()` procesa fotogramas hasta que dejan de programarse, por lo que resulta útil para transiciones, pero puede agotar el tiempo si hay una animación continua.

