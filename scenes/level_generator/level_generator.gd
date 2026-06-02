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
	move_to_top(floor_object.node)
	
func move_to_top(floor : Node2D) -> void:
	var last_floor = floor_array[-2].node
	floor.position.y = last_floor.position.y + 16
	

func get_random_floor() -> PackedScene:
	var random_floor = pickable_floors.pick_random();
	var floor_scene = load(random_floor);
	return floor_scene;
	
