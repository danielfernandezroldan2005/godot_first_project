extends Node2D
class_name Main

var plant_scene: PackedScene = preload("res://scenes/entities/plant/Plant.tscn")
var harvested_count: int = 0

@onready var farm_grid: TileMapLayer = $FarmGrid
@onready var plants_container: Node2D = $PlantsContainer
@onready var harvest_label: Label = $UI/HarvestLabel

var active_plants: Dictionary = {}

func _ready() -> void:
	_update_ui()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos: Vector2 = get_global_mouse_position()
		var cell_pos: Vector2i = farm_grid.local_to_map(mouse_pos)
		try_plant_seed(cell_pos)

func try_plant_seed(cell_pos: Vector2i) -> void:
	if active_plants.has(cell_pos):
		return
	plant_seed(cell_pos)

func plant_seed(cell_pos: Vector2i) -> void:
	var new_plant: Plant = plant_scene.instantiate()
	plants_container.add_child(new_plant)
	
	var pixel_pos: Vector2 = farm_grid.map_to_local(cell_pos)
	new_plant.global_position = pixel_pos
	
	active_plants[cell_pos] = new_plant
	new_plant.harvested.connect(_on_plant_harvested.bind(cell_pos))

func _on_plant_harvested(cell_pos: Vector2i) -> void:
	harvested_count += 1
	_update_ui()
	active_plants.erase(cell_pos)

func _update_ui() -> void:
	harvest_label.text = "Cosechas: " + str(harvested_count)
