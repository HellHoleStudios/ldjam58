extends RigidBody2D

const MOVE_IMPULSE = 5.0 #TODO Magic Number

# TODO
func _input(event: InputEvent) -> void:
	var direction = Vector2.ZERO
	
	# Check for discrete "just pressed" events
	if Input.is_action_pressed("D"):
		direction.x += 1
	if Input.is_action_pressed("A"):
		direction.x -= 1
	if Input.is_action_pressed("W"):
		direction.y -= 1
	if Input.is_action_pressed("S"):
		direction.y += 1
		
	# Apply the impulse on the frame the key is pressed
	if direction != Vector2.ZERO:
		# Normalize to prevent faster diagonal impulse
		direction = direction.normalized()
		# Apply the central impulse
		apply_central_impulse(direction * MOVE_IMPULSE)
