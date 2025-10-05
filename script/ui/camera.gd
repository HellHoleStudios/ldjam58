extends Camera2D

var targetZoom:float=1

func _process(delta: float) -> void:
	#var layer=Game.get_layer(%player.position)
	#if layer<=5:
		#targetZoom=1d
	#else:
		#targetZoom=(1/sqrt(2))**(layer-5)
	
	targetZoom = 32/%player.get_radius()
	self.zoom=lerp(self.zoom,Vector2.ONE*targetZoom,0.01)
