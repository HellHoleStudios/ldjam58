extends RigidBody2D
class_name StarDisplayer

var data: BaseStarData

func get_data() -> BaseStarData:
	return data

func set_data(d: BaseStarData):
	data = d
	data.set_sprite($Sprite2D)
	data.set_collision_shape($CollisionShape2D)
	data.set_rigidbody(self)
	data.update_visual()
