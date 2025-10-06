extends Sprite2D
@export var camera:Camera2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if camera:
		var camera_pos=camera.get_screen_center_position()
		position=camera_pos
		#var noise_texture=texture as NoiseTexture2D
		#var noise=noise_texture.noise as FastNoiseLite
		#noise.offset=Vector3(camera_pos.x,camera_pos.y,0)
		var sz=DisplayServer.window_get_size()/camera.zoom.x/scale.x
		region_rect=Rect2(camera_pos/scale.x-sz/2+Vector2(1000,1000),sz)
