extends CharacterBody2D

# Constants for movement tuning
@export var SPEED = 300.0
@export var ACCELERATION = 5.0 # Higher value means faster acceleration/deceleration

var mass: float

func _ready() -> void:
	set_mass(10)
	
func set_mass(mass: float):
	self.mass=mass
	$Sprite2D.scale=Vector2(mass,mass)/32
	$CollisionShape2D.shape.radius=mass

func _physics_process(delta):
	# 1. Get the player input direction
	var input_direction = Input.get_vector("A", "D", "W", "S").normalized()
	
	# 2. Calculate the target velocity
	var target_velocity = input_direction * SPEED
	
	# 3. Smoothly accelerate/decsdselerate towards the target velocity using lerp
	# This is the key to smooth movement.
	velocity = velocity.lerp(target_velocity, ACCELERATION * delta)
	
	# 4. Apply movement
	var collider:KinematicCollision2D=move_and_collide(velocity * delta)
	if collider:
		var star:StarDisplayer=collider.get_collider()
		#var star:StarDisplayer=target.get_parent()
		
		if star.mass<self.mass:
			set_mass(star.mass+self.mass)
			star.queue_free()
			print("Sucked!!! New mass:",mass)
