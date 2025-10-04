extends Star
class_name PlayerStar

# Constants for movement tuning
@export var speed = 1000.0
@export var acceleration = 500.0 # Higher value means faster acceleration/deceleration


func _ready() -> void:
	self.mass = 10
	randomize_elements()

	print(contact_monitor)

	super._ready()

func _physics_process(delta):
	# 1. Get the player input direction
	var input_direction = Input.get_vector("A", "D", "W", "S").normalized()
	
	if input_direction.is_zero_approx():
		return
	
	# 2. Calculate the target velocity
	var target_velocity = input_direction * speed

	# 3. Smoothly accelerate/decsdselerate towards the target velocity using lerp
	# This is the key to smooth movement.
	# For RigidBody2D, we set the linear_velocity directly

	var diff=target_velocity-linear_velocity
	if not diff.is_zero_approx():
		var mag=diff.length()
		diff=diff.normalized()
		mag=clampf(mag,0,acceleration*delta)
		diff*=mag
		linear_velocity+=diff
	
	super(delta)
