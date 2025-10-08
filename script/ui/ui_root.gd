extends Control

func _process(delta: float) -> void:
	$Label.visible = PlayerStar.instance.mass>1e12
