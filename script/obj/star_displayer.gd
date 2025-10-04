extends Node2D
class_name StarDisplayer

var data: BaseStarData

func set_data(data: BaseStarData):
	self.mass=data.mass
	var rad=data.mass # TODO
	$CollisionShape2D.shape=CircleShape2D.new()
	$CollisionShape2D.shape.radius=rad
	$Sprite2D.scale=Vector2(rad,rad)/32
