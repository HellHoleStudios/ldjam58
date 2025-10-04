extends RigidBody2D

# Constants for movement tuning
@export var SPEED = 300.0
@export var ACCELERATION = 5.0 # Higher value means faster acceleration/deceleration

var data: BaseStarData

func get_data() -> BaseStarData:
	return data

func _ready() -> void:
	data = BaseStarData.new()
	data.set_sprite($Sprite2D)
	data.set_collision_shape($CollisionShape2D)
	data.set_rigidbody(self)
	data.set_mass(10)

	print(contact_monitor)
	contact_monitor = true
	max_contacts_reported = 4

func _physics_process(delta):
	# 1. Get the player input direction
	var input_direction = Input.get_vector("A", "D", "W", "S").normalized()
	
	# 2. Calculate the target velocity
	var target_velocity = input_direction * SPEED

	# 3. Smoothly accelerate/decsdselerate towards the target velocity using lerp
	# This is the key to smooth movement.
	# For RigidBody2D, we set the linear_velocity directly
	linear_velocity = linear_velocity.lerp(target_velocity, ACCELERATION * delta)
	
func _on_body_entered(body: Node) -> void:
	print("collide!")
	if body is StarDisplayer:
		var star: StarDisplayer = body
		if star.data.get_mass() < data.get_mass():
			data.set_mass(star.data.get_mass() + data.get_mass())
			star.queue_free()
			print("Sucked!!! New mass:", data.get_mass())
