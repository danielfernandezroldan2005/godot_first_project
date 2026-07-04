extends Area2D
class_name Plant 
# class_name registra este script globalmente en Godot. 
# Esto nos permite usar 'Plant' como un tipo de dato en otros scripts.

# --- SEÑALES (SIGNALS) ---
# Las señales son el corazón de la comunicación en Godot.
# Permiten que este nodo avise: "¡Eh, me han cosechado!" sin importarle quién escuche,
# manteniendo el código modular y desacoplado.
signal harvested

# --- VARIABLES EXPORTADAS ---
# @export hace que esta variable aparezca en el panel "Inspector" de Godot.
# Así puedes cambiar el tiempo de crecimiento desde el editor.
@export var grow_time: float = 3.0

# --- ESTADOS ---
# Un enum es perfecto para definir estados simples como en una máquina de estados.
enum PlantState { SEED, GROWING, ADULT }
var current_state: PlantState = PlantState.SEED

# --- REFERENCIAS A NODOS HIJOS ---
# @onready asegura que las variables se inicialicen una vez que los nodos hijos
# ya han entrado al árbol y están listos.
@onready var sprite: Sprite2D = $Sprite2D
@onready var grow_timer: Timer = $GrowTimer

# La función _ready() se ejecuta automáticamente cuando el nodo entra en escena.
func _ready() -> void:
	# Configuramos las propiedades de nuestro temporizador por código.
	grow_timer.wait_time = grow_time
	grow_timer.one_shot = true # Solo queremos que cuente una vez por ciclo.
	
	# CONEXIÓN DE SEÑALES POR CÓDIGO
	# Conectamos la señal 'timeout' del Timer a nuestra función de crecimiento.
	grow_timer.timeout.connect(_on_grow_timer_timeout)
	
	# Conectamos la señal 'input_event' de este Area2D para detectar clics.
	self.input_event.connect(_on_input_event)
	
	# Actualizamos la apariencia visual inicial.
	_update_visuals()
	
	# Iniciamos la cuenta atrás del temporizador.
	grow_timer.start()

# Función didáctica para actualizar el color del Sprite.
func _update_visuals() -> void:
	# En un proyecto real, aquí cambiarías la propiedad texture del Sprite2D:
	# sprite.texture = load("res://assets/sprites/...)
	# Para este ejemplo práctico, cambiaremos la modulación de color.
	match current_state:
		PlantState.SEED:
			sprite.modulate = Color("saddlebrown") # Color marrón arcilla para la semilla
		PlantState.GROWING:
			sprite.modulate = Color("yellowgreen") # Color verde claro/brote
		PlantState.ADULT:
			sprite.modulate = Color("forestgreen") # Verde oscuro, lista para cosechar

# Se activa cuando el Timer finaliza su cuenta atrás.
func _on_grow_timer_timeout() -> void:
	if current_state == PlantState.SEED:
		current_state = PlantState.GROWING
		_update_visuals()
		grow_timer.start() # Iniciamos de nuevo el Timer para crecer a adulta.
	elif current_state == PlantState.GROWING:
		current_state = PlantState.ADULT
		_update_visuals()
		# Al llegar a adulta no reiniciamos el Timer, se queda esperando cosecha.

# Se ejecuta al interactuar con el área física de colisión (clics, toques, movimiento).
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	# Comprobamos si el evento es un clic izquierdo del ratón que se acaba de pulsar.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# Solo permitimos la cosecha si está en su fase adulta.
		if current_state == PlantState.ADULT:
			harvest()

# Función de cosecha.
func harvest() -> void:
	# Emitimos la señal para avisarle a la escena principal.
	harvested.emit()
	
	# queue_free() elimina este nodo del juego de forma segura al final de este frame.
	queue_free()
