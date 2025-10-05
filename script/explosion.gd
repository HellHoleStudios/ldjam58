extends Sprite2D

var t:float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self_modulate=Color(1.3,1.3,1.3,1)
	t=0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	t+=delta
	if t<0.1:
		var c=1.3-3*t
		self_modulate=Color(c,c,c,1)
	elif t<0.3:
		self_modulate=Color(1,1,1,(0.3-t)/0.2)
		scale*=1.1
	else:
		queue_free()
