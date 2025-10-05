extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var r=%player.get_radius()
	var target_z=50/r
	target_z=clampf(target_z,0.5,3)
	var current_z=zoom.x
	var z=lerp(current_z,target_z,delta*3)
	zoom=Vector2(z,z)
