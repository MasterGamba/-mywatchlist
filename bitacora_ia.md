# Bitácora de uso de IA

Fecha de la sesión: 12/11/2026. Herramienta: Codex.

El usuario solicitó inicialmente un plan basado en `enunciado.md` y después pidió «PLEASE IMPLEMENT THIS PLAN:», seguido del plan completo de la conversación. La implementación técnica se realizó agrupada en esta sesión; las fases siguientes organizan sus resultados y no certifican que el alumno haya realizado cada fase, revisado el código o respondido sus preguntas.

No se utilizaron subagentes. No se han inventado prompts independientes. El detalle de las comprobaciones está en `mywatchlist/verificacion.md`.

Actualización del 16/11/2026: los apartados de decisiones y aprendizaje se han completado con ayuda de Codex a partir del código y de la documentación disponibles. Describen las soluciones del proyecto y los conceptos de cada fase.

## Fase 0 · Preparación y diseño

**Herramienta usada:** Codex para inspeccionar el proyecto y preparar carpetas.

**Prompt principal:** solicitud de implementación indicada al inicio de este documento.

**Qué dio la IA y qué hizo:** conservó el proyecto Flutter existente, sustituyó la demostración del contador y preparó la estructura obligatoria. No creó un boceto atribuido al alumno.

**Boceto disponible:** `Capturas/boceto.png`.

**Acepté / modifiqué / descarté:** se aprovechó la estructura del proyecto Flutter y se sustituyó la pantalla del contador por las pantallas de la watchlist. La interfaz final utiliza una paleta oscura violeta y adapta la navegación al ancho disponible.

**Lo que he aprendido:** definir las pantallas antes de programar ayuda a decidir qué datos necesita cada una y cómo se conectan. Separar modelos, servicios, pantallas y widgets permite localizar mejor cada responsabilidad.

## Fase 1 · Modelo de datos

**Herramienta y prompt:** Codex; solicitud general de implementación.

**Resultado técnico:** modelo inmutable, enums, JSON y `copyWith`. `borrarNotas` permite diferenciar conservar las notas de eliminarlas. Los datos de ejemplo se usan en pruebas y capturas, sin dejar una carga ficticia en producción.

**Acepté / modifiqué / descarté:** se incorporaron el modelo inmutable, los enums y los métodos de conversión JSON. Se añadió `borrarNotas` para poder eliminar las notas al editar, ya que un parámetro nulo normalmente conserva el valor anterior. Los ejemplos quedaron en pruebas y capturas, sin introducir datos ficticios en la lista de producción.

**Errores detectados:** consultar las correcciones técnicas de la fase 8.

**Lo que he aprendido:** un objeto con campos `final` se actualiza creando una copia con los cambios, en lugar de reasignar sus propiedades. JSON no guarda directamente enums ni fechas: hay que convertirlos a texto y reconstruirlos al cargar.

**Preguntas de comprensión:**
1. ¿Por qué los campos son `final`? ¿Cómo cambias el estado?
   `final` impide reasignar cada campo después de crear el objeto. Para cambiar el estado se crea otro `Elemento` con `copyWith(estado: Estado.terminado)` y se sustituye el anterior en la lista, conservando su `id` y los demás datos.
2. ¿Cómo se guarda y recupera un enum en JSON?
   `toJson()` guarda su nombre como texto mediante `tipo.name` y `estado.name`. `fromJson()` recupera el valor con `Tipo.values.byName(...)` o `Estado.values.byName(...)`. Se guarda el nombre del enum, no su etiqueta visible.
3. ¿Qué ocurre si faltan las notas en el JSON?
   Al consultar una clave ausente, `json['notas']` devuelve `null`. Como se convierte a `String?`, se acepta ese valor y el elemento se crea sin notas.

## Fase 2 · Lista y tarjeta

**Herramienta y prompt:** Codex; solicitud general de implementación.

**Resultado técnico:** lista con construcción bajo demanda, tarjeta con callback, estrellas de lectura y estado vacío con acceso al formulario.

**Acepté / modifiqué / descarté:** se incorporaron `ListView.builder`, `TarjetaElemento` y las estrellas como componentes separados. La navegación se mantiene en la pantalla mediante callbacks. También se incluyó un estado vacío con un botón de alta para que la aplicación siga siendo útil sin elementos.

**Lo que he aprendido:** `ListView.builder` construye las filas según se necesitan al desplazarse. Un widget puede recibir una función para avisar de una pulsación sin decidir la navegación, lo que facilita reutilizarlo en otras pantallas.

**Preguntas de comprensión:**
1. ¿Cuándo conviene `ListView.builder` frente a `ListView`?
   `ListView.builder` crea los hijos según se necesitan al desplazarse y conviene para listas grandes o de longitud variable. `ListView(children: [...])` recibe los widgets ya construidos y resulta sencillo para pocos elementos fijos, como los campos de un formulario.
2. ¿Por qué la tarjeta recibe una función en vez de navegar ella misma?
   Así la tarjeta solo muestra los datos y avisa de la pulsación mediante `onTap`. La pantalla que la utiliza decide qué hacer, por lo que puede reutilizarse sin depender de una pantalla de destino.
3. ¿Por qué la tarjeta utiliza ese tipo de widget?
   `TarjetaElemento` es un `StatelessWidget` porque recibe los datos y callbacks desde fuera y no mantiene un estado propio que deba cambiar con `setState`. Cuando cambia la selección o el elemento, su pantalla padre la reconstruye con los nuevos valores.

## Fase 3 · Formulario de alta

**Herramienta y prompt:** Codex; solicitud general de implementación.

**Resultado técnico:** formulario validado, controladores liberados, desplegables, estrellas interactivas, notas opcionales y devolución del resultado por navegación.

**Acepté / modifiqué / descarté:** se incorporó un `Form` con validación, controladores de texto y selectores de tipo, estado y estrellas. El título se valida después de quitar espacios de los extremos. El formulario devuelve el elemento mediante `Navigator.pop` y la pantalla de lista se encarga de guardarlo.

**Lo que he aprendido:** validar el formulario antes de crear el elemento evita guardar títulos vacíos o demasiado largos. Los controladores deben liberarse con `dispose()`, y el resultado de una pantalla puede recuperarse esperando el `Future` de `Navigator.push`.

**Preguntas de comprensión:**
1. ¿Qué hace `validate()` y qué significa `!`?
   `validate()` ejecuta los validadores de los campos del `Form`, muestra sus errores y devuelve `true` si todos son válidos. En `_formKey.currentState!`, `!` afirma que el estado no es nulo; si lo fuera, se produciría un error en ejecución. Si la validación falla, `_guardar()` termina sin devolver un elemento.
2. ¿Por qué hay que llamar a `dispose()`?
   Los `TextEditingController` mantienen recursos y escuchas. Al destruir la pantalla se liberan con `_titulo.dispose()` y `_notas.dispose()`, y después se llama a `super.dispose()` para completar la limpieza del estado.
3. ¿Qué recorrido sigue el dato desde Guardar hasta la lista?
   `_guardar()` valida, lee los campos y crea un `Elemento`. `Navigator.pop(context, elemento)` lo devuelve a `_alta()`, que esperaba el resultado de `Navigator.push`. Si no es nulo, `_guardarAlta()` prepara una lista con el nuevo elemento y `_guardar()` espera a persistirla. Solo si el guardado funciona actualiza `_elementos` con `setState`, y la lista se reconstruye.

## Fase 4 · Detalle, edición y borrado

**Herramienta y prompt:** Codex; solicitud general de implementación.

**Resultado técnico:** detalle con todos los campos, reutilización del formulario, conservación de identidad y fecha, confirmación de borrado y aviso de resultado. Las escrituras fallidas permiten reintentar.

**Acepté / modifiqué / descarté:** se reutilizó el formulario de alta para editar mediante el parámetro `inicial`, conservando el identificador y la fecha de alta. Se incluyó confirmación antes de borrar y se espera el resultado del guardado antes de reflejar los cambios. Cancelar la edición conserva el elemento original.

**Lo que he aprendido:** el identificador permite encontrar un elemento aunque cambie su título. `showDialog<bool>` devuelve una respuesta asíncrona que puede ser nula; por eso el borrado solo continúa cuando el resultado es exactamente `true`.

**Preguntas de comprensión:**
1. ¿Cómo distingue el formulario creación y edición?
   Mediante el parámetro opcional `inicial`. Si es `null`, usa valores por defecto y crea un `id` y una fecha nuevos. Si contiene un elemento, rellena los campos con sus datos y conserva su `id` y `fechaAlta` al guardar. Cancelar devuelve `null` y no aplica cambios.
2. ¿Cómo encuentra la lista el elemento que debe reemplazar?
   El detalle envía el elemento editado al callback `onActualizar`. La lista recorre `_elementos` con `map` y compara cada `id` con `editado.id`: sustituye la coincidencia por el editado y conserva el resto. La lista propuesta se guarda antes de actualizar la pantalla.
3. ¿Qué devuelve `showDialog` y cómo se usa?
   `showDialog<bool>` devuelve un `Future<bool?>`. Tras `await`, el resultado es `true` al confirmar, `false` al pulsar Cancelar o puede ser `null` al cerrar sin una respuesta. El código solo llama a `_borrar()` si `confirmado == true` y la pantalla sigue montada.

## Fase 5 · Filtro y búsqueda

**Herramienta y prompt:** Codex; solicitud general de implementación.

**Resultado técnico:** filtros de estado y búsqueda sin distinguir mayúsculas aplicados simultáneamente a una lista calculada. Mensaje específico para resultados vacíos y opción de restablecer filtros.

**Acepté / modifiqué / descarté:** se aplicaron el filtro de estado y la búsqueda sobre una lista calculada con `where`, conservando la colección completa. Se normalizan los títulos y la búsqueda a minúsculas. Se añadió un mensaje para las búsquedas sin resultados y una acción para limpiar los filtros.

**Lo que he aprendido:** filtrar cambia la vista de los datos, por lo que no debe borrar elementos de la lista original. Al unir las condiciones con `&&`, un elemento solo aparece si cumple tanto el estado elegido como el texto buscado.

**Preguntas de comprensión:**
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

**Acepté / modifiqué / descarté:** se utilizó `shared_preferences` para guardar la lista como un único texto JSON bajo la clave `watchlist`. Se incorporaron el indicador de carga y la recuperación ante JSON inválido. Las operaciones esperan a que termine la escritura y conservan los datos anteriores en pantalla si falla.

**Lo que he aprendido:** `Future` y `await` permiten esperar la lectura y escritura sin convertir `initState` en un método asíncrono. Tras una espera se comprueba `mounted` antes de actualizar la pantalla. Separar el almacenamiento de los widgets permite probarlo de forma independiente.

**Preguntas de comprensión:**
1. ¿Por qué `cargar()` devuelve un `Future`?
   Obtener las preferencias es una operación asíncrona, por lo que la lista no está disponible inmediatamente. `Future<List<Elemento>>` representa su resultado futuro y permite esperarlo con `await`. Mientras llega, la pantalla muestra un indicador de carga en lugar de presentar la lista inicial vacía como si fuera definitiva.
2. ¿Cómo se inicia la carga desde `initState`?
   `initState()` debe seguir siendo un método síncrono que devuelve `void`, por lo que no se convierte en `async` para esperar la lectura. Inicializa `_almacen` y llama a `_cargar()`, que sí es asíncrona. Esta espera `_almacen.cargar()` y actualiza la pantalla con `setState` tras comprobar `mounted`.
3. ¿Dónde se guardan los datos y qué ocurre al desinstalar?
   `Almacen` convierte toda la lista en un texto JSON y lo guarda con la clave `watchlist` mediante `shared_preferences`. En una aplicación nativa está en el almacenamiento local de preferencias de esa instalación; en web, en el almacenamiento local del navegador para ese sitio. Desinstalar normalmente elimina los datos locales, aunque una copia de seguridad del sistema podría restaurarlos. En web también se pierden al borrar los datos del sitio; este proyecto no tiene sincronización propia.

## Fase 7 · Estadísticas y tema

**Herramienta y prompt:** Codex; solicitud general de implementación.

**Resultado técnico:** recuentos y barras por estado, media de valorados y tipo más frecuente con empates. Tema Material de semilla violeta.

**Acepté / modifiqué / descarté:** se incluyeron recuentos por estado, barras proporcionales, media de los elementos valorados y tipos más frecuentes con posibilidad de empate. La media excluye las valoraciones de cero. El tema se centralizó en `tema.dart` con una paleta violeta oscura para mantener una apariencia común.

**Lo que he aprendido:** antes de calcular una media hay que comprobar que existan datos válidos para evitar dividir entre cero. Una valoración de cero representa un dato ausente en este modelo. Definir un tema común permite cambiar la apariencia compartida sin editar cada pantalla.

**Preguntas de comprensión:**
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

**Acepté / modifiqué / descarté:** se incorporaron pruebas unitarias del modelo y pruebas de widgets para validar las acciones de la interfaz. La cobertura se amplió a almacenamiento, filtros, estadísticas y fallos de guardado. Se corrigieron los errores de sintaxis y de sincronización de las pruebas indicados arriba, y se documentaron los resultados reales de compilación y sus bloqueos.

**Lo que he aprendido:** las pruebas unitarias comprueban lógica aislada y las de widgets verifican la interfaz y sus interacciones. Después de una acción puede ser necesario ejecutar `pump()` para observar la reconstrucción. El análisis estático, las pruebas y la ejecución de la app comprueban aspectos distintos y se complementan.

**Preguntas de comprensión:**
1. ¿Qué diferencia hay entre una prueba unitaria y una de widget?
   Una prueba unitaria comprueba lógica aislada, como convertir un `Elemento` a JSON y recuperarlo o utilizar `copyWith`, sin montar una interfaz. Una prueba de widget monta widgets en el entorno de pruebas, simula acciones y comprueba lo que aparece, como el error al guardar un título vacío.
2. ¿Qué hace `tester.pump()` y cuándo hace falta?
   Procesa un fotograma del entorno de pruebas y permite aplicar las reconstrucciones pendientes. Después de una pulsación que cambia el estado, se utiliza para que la interfaz refleje el cambio antes de comprobarla. `pumpAndSettle()` procesa fotogramas hasta que dejan de programarse, por lo que resulta útil para transiciones, pero puede agotar el tiempo si hay una animación continua.

