extends Sprite2D

var final_scale: float = 1.0
var duration: float = 0.5
var elapsed: float = 0.0

func init(_final_scale: float = 1.0):
	final_scale = _final_scale / (texture.get_height() / 2)
	scale = Vector2.ZERO
	modulate.a = 1.0

func _process(delta):
	elapsed += delta
	var t = 1 - clamp(elapsed / duration, 0, 1)
	scale = Vector2.ONE * final_scale * t
	modulate.a = 1.0 - t
	if t >= 1.0:
		queue_free()
