extends CharacterBody2D

#Tweakable variables in editor.
@export var SPEED = 100.0
@export var JUMP_VELOCITY = -400.0
@export var heatIncreaseOnJump = 10
@export var heatIncreaseRateOnMove = 0.1
@export var heatDecreaseRate = 5

var currentHeat = 0.0
var lockedIn = false
var lastDirectionPressed
var framesSinceLastDecrease = 0

@onready var animation_tree : AnimationTree = $AnimationTree
signal heatChange

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func heatIncrease(heatToIncrease):
	currentHeat += heatToIncrease
	emit_signal("heatChange", heatToIncrease)
	if currentHeat >= 100 and !lockedIn:
		lockedIn = true
		
func heatDecrease():
	framesSinceLastDecrease += 1
	if framesSinceLastDecrease == 6:
		currentHeat -= heatDecreaseRate
		emit_signal("heatChange", (heatDecreaseRate*-1))
		framesSinceLastDecrease = 0
		if currentHeat<=0:
			lockedIn = false;
		
func jump():
	# Jump.
	velocity.y = JUMP_VELOCITY
		
	# Heat management.
	if !lockedIn:
		heatIncrease(heatIncreaseOnJump)
				
func move():
	var direction
	if !lockedIn:
		direction = Input.get_axis("ui_left", "ui_right")
		lastDirectionPressed = direction	
	else:
		direction = lastDirectionPressed
		
	if direction:
		velocity.x = direction * SPEED
		if !lockedIn:
			heatIncrease(heatIncreaseRateOnMove)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	move_and_slide()
			
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		jump()

	# Get the input direction and handle the movement/deceleration.
	move()
	
	if lockedIn:
		heatDecrease()	
	
	# Animation handling
	"""
	if direction != Vector2.ZERO:
		animation_tree["parameters/conditions/is_moving"] = true
		animation_tree["parameters/conditions/not_moving"] = false
	else:
		animation_tree["parameters/conditions/is_moving"] = false
		animation_tree["parameters/conditions/not_moving"] = true
	"""
		
		
	
