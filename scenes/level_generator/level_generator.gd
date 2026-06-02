class_name LevelGenerator extends Node2D

const FLOOR_COUNT = 10;


var floor_array : Array[Floor] = [];

var pickable_floors = [
	"res://scenes/levels/level_example.tscn"
]

class Floor:
	const SIZE = 16;
	var level_scene : PackedScene
	var node : Node2D
	
	func _init(_level_scene : PackedScene) -> void:
		level_scene = _level_scene;
		pass
		

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_floor_array();
	for i in floor_array.size():
		initialize_floor(i);


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func generate_floor_array() -> void:
	for i in FLOOR_COUNT:
		floor_array.append(Floor.new(get_random_floor()));

func initialize_floor(i : int) -> void:
	var floor_object : Floor = floor_array[i];
	var new_floor = floor_object.level_scene.instantiate();
	add_child(new_floor)
	floor_object.node = new_floor
	if i > 0:
		move_on_top(floor_object, floor_array[i-1])
	
func move_on_top(floor_to_move : Floor, last_floor : Floor) -> void:
	floor_to_move.node.position.y = last_floor.node.position.y + 16 * 8
	

func get_random_floor() -> PackedScene:
	var random_floor = pickable_floors.pick_random();
	var floor_scene = load(random_floor);
	return floor_scene;
	
