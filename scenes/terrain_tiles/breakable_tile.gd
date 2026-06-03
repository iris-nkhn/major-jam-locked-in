extends Node2D


@onready var area = $Sprite2D/StaticBody2D/Area2D
@onready var timer = $Timer
@onready var animated_sprite = $Sprite2D/AnimatedSprite2D
const MAX_BREAK_STATE = 2
var current_break_state = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area.area_entered.connect(_on_area_entered)
	timer.timeout.connect(_on_timer_timeout)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_entered() -> void:
	timer.start()

func _on_timer_timeout() -> void:
	advance_health()
	
func advance_health() -> void:
	current_break_state += 1
	if(current_break_state > MAX_BREAK_STATE):
		queue_free()
	else:
		advance_sprite()
		#Change break sprite
		

func advance_sprite() -> void:
	animated_sprite.frame = animated_sprite.frame + 1

	
	
