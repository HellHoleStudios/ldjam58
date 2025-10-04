## 天体类，要求树下必须有一个`Sprite`和一个`Collision`
class_name Star
extends RigidBody2D

#func _init(_mass: float = 1.0):
	#self.mass=_mass
	#
	#$Collision.shape=CircleShape2D.new()
	#update_visual()

func _ready() -> void:
	$Collision.shape=CircleShape2D.new()
	update_visual()

func update_mass(_mass: float):
	mass = _mass
	update_visual()

func get_radius() -> float:
	return sqrt(mass)*3

func get_sprite() -> Sprite2D:
	return $Sprite

func update_visual():
	var radius = get_radius()
	$Sprite.scale = Vector2(1, 1) * radius / 32
	$Collision.shape.radius = radius
	
	
