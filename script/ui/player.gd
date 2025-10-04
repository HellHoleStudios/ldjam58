extends Star
class_name PlayerStar

# Constants for movement tuning
@export var SPEED = 300.0
@export var ACCELERATION = 5.0 # Higher value means faster acceleration/deceleration


func _ready() -> void:
	self.mass = 10

	print(contact_monitor)

	super._ready()

func _physics_process(delta):
	# 1. Get the player input direction
	var input_direction = Input.get_vector("A", "D", "W", "S").normalized()
	
	# 2. Calculate the target velocity
	var target_velocity = input_direction * SPEED

	# 3. Smoothly accelerate/decsdselerate towards the target velocity using lerp
	# This is the key to smooth movement.
	# For RigidBody2D, we set the linear_velocity directly
	linear_velocity = linear_velocity.lerp(target_velocity, ACCELERATION * delta)
