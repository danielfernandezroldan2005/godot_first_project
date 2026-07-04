extends Area2D
class_name Plant 

signal harvested

@export var grow_time: float = 3.0

enum PlantState { SEED, GROWING, ADULT }
var current_state: PlantState = PlantState.SEED

@onready var sprite: Sprite2D = $Sprite2D
@onready var grow_timer: Timer = $GrowTimer

func _ready() -> void:
	grow_timer.wait_time = grow_time
	grow_timer.one_shot = true
	
	# Conectamos las señales
	grow_timer.timeout.connect(_on_grow_timer_timeout)
	self.input_event.connect(_on_input_event)
	
	_update_visuals()
	grow_timer.start()

func _update_visuals() -> void:
	match current_state:
		PlantState.SEED:
			sprite.modulate = Color("saddlebrown") # Semilla (marrón)
		PlantState.GROWING:
			sprite.modulate = Color("yellowgreen") # Brote (verde claro)
		PlantState.ADULT:
			sprite.modulate = Color("forestgreen") # Adulta (verde oscuro)

func _on_grow_timer_timeout() -> void:
	if current_state == PlantState.SEED:
		current_state = PlantState.GROWING
		_update_visuals()
		grow_timer.start()
	elif current_state == PlantState.GROWING:
		current_state = PlantState.ADULT
		_update_visuals()

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if current_state == PlantState.ADULT:
			harvest()

func harvest() -> void:
	harvested.emit()
	queue_free()
