extends Node2D
class_name StarDisplayer

var data: BaseStarData

func set_data(data: BaseStarData):
	$RigidBody2D.mass=data.mass
	var rad=data.mass # TODO
	$RigidBody2D/CollisionShape2D.shape.radius=rad
	$Sprite2D.scale=Vector2(rad,rad)/32
