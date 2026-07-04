extends Node2D
class_name Main

# --- PRELOAD DE ESCENAS ---
# preload() carga la escena Plant en la RAM al iniciar el juego.
# Devuelve un PackedScene (un molde reutilizable de la escena).
var plant_scene: PackedScene = preload("res://scenes/entities/plant/Plant.tscn")

var harvested_count: int = 0

# --- REFERENCIAS A NODOS ---
@onready var farm_grid: TileMapLayer = $FarmGrid
@onready var plants_container: Node2D = $PlantsContainer
@onready var harvest_label: Label = $UI/HarvestLabel

# Diccionario para llevar el registro de qué celdas tienen planta.
# Clave: Vector2i (coordenadas de cuadrícula), Valor: Referencia a la planta instanciada.
var active_plants: Dictionary = {}

func _ready() -> void:
	_update_ui()

# Captura eventos de entrada que no hayan sido consumidos por elementos GUI (Control/Botones).
func _unhandled_input(event: InputEvent) -> void:
	# Verificamos si es un clic del ratón izquierdo y fue presionado.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# get_global_mouse_position() obtiene la posición real del cursor en píxeles del mundo 2D.
		var mouse_pos: Vector2 = get_global_mouse_position()
		
		# local_to_map() toma la posición en píxeles y nos da la coordenada entera (Vector2i)
		# de la celda de la cuadrícula.
		var cell_pos: Vector2i = farm_grid.local_to_map(mouse_pos)
		
		try_plant_seed(cell_pos)

# Comprobación de seguridad antes de sembrar.
func try_plant_seed(cell_pos: Vector2i) -> void:
	# Si ya existe una planta registrada en esa coordenada de la cuadrícula, salimos.
	if active_plants.has(cell_pos):
		return
		
	# Si está vacío, sembramos la semilla.
	plant_seed(cell_pos)

# Creación de la planta e instanciación.
func plant_seed(cell_pos: Vector2i) -> void:
	# instantiate() crea una copia en memoria (instancia) del molde PackedScene.
	var new_plant: Plant = plant_scene.instantiate()
	
	# add_child() introduce la instancia en el árbol de escenas activo como hijo de 'PlantsContainer'.
	# Esto hace que empiece a existir en el mundo de juego y se llame a su _ready().
	plants_container.add_child(new_plant)
	
	# map_to_local() toma las coordenadas de celda (Vector2i) y nos devuelve
	# el centro en píxeles (Vector2) de esa celda para colocar la planta exactamente ahí.
	var pixel_pos: Vector2 = farm_grid.map_to_local(cell_pos)
	new_plant.global_position = pixel_pos
	
	# Guardamos la planta en el diccionario en su coordenada correspondiente.
	active_plants[cell_pos] = new_plant
	
	# CONEXIÓN DE SEÑAL DINÁMICA
	# Conectamos la señal personalizada 'harvested' de la planta a nuestra función local.
	# Usamos bind(cell_pos) para asociarle la coordenada a la llamada. Así, cuando esa planta
	# emita la señal, sabremos con precisión qué celda acaba de quedar libre.
	new_plant.harvested.connect(_on_plant_harvested.bind(cell_pos))

# Se ejecuta cuando una planta emite la señal de haber sido cosechada.
func _on_plant_harvested(cell_pos: Vector2i) -> void:
	harvested_count += 1
	_update_ui()
	
	# Eliminamos el registro de la celda en nuestro diccionario.
	# La planta se destruye sola mediante queue_free() en su propio código.
	active_plants.erase(cell_pos)

# Actualiza el elemento de la interfaz.
func _update_ui() -> void:
	# str() convierte el entero harvested_count en una cadena de texto.
	harvest_label.text = "Cosechas: " + str(harvested_count)
