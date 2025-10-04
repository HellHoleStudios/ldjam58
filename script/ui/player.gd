extends CharacterBody2D

# Constants for movement tuning
@export var SPEED = 300.0
@export var ACCELERATION = 5.0 # Higher value means faster acceleration/deceleration

func _physics_process(delta):
	# 1. Get the player input direction
	var input_direction = Input.get_vector("A", "D", "W", "S").normalized()
	
	# 2. Calculate the target velocity
	var target_velocity = input_direction * SPEED
	
	# 3. Smoothly accelerate/decsdselerate towards the target velocity using lerp
	# This is the key to smooth movement.
	velocity = velocity.lerp(target_velocity, ACCELERATION * delta)
	
	# 4. Apply movement
	move_and_slide()
	
