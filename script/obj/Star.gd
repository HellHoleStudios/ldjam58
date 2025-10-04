## 天体类，要求树下必须有一个`Sprite`和一个`Collision`
class_name Star
extends RigidBody2D

#func _init(_mass: float = 1.0):
	#self.mass=_mass
	#
	#$Collision.shape=CircleShape2D.new()
	#update_visual()

func _ready() -> void:
	$Collision.shape = CircleShape2D.new()
	update_visual()

	contact_monitor = true
	max_contacts_reported = 4

func update_mass(_mass: float):
	mass = _mass
	update_visual()

func get_radius() -> float:
	return sqrt(mass) * 3

func get_sprite() -> Sprite2D:
	return $Sprite

func update_visual():
	var radius = get_radius()
	$Sprite.scale = Vector2(1, 1) * radius / 32
	$Collision.shape.radius = radius
	

func _on_body_entered(body: Node) -> void:
	if body is Star:
		var star: Star = body
		if star.get_mass() < mass:
			if star is not PlayerStar:
				self.update_mass(star.mass + mass)
				star.queue_free()
				print("Sucked!!! New mass:", mass)
			else:
				var BOUNCE_FACTOR = 4
				var dir = (star.position - position).normalized()
				# 连线方向上的分速度设为0
				var rel_vel = star.linear_velocity - linear_velocity
				var proj = rel_vel.dot(dir)
				star.linear_velocity -= dir * proj * BOUNCE_FACTOR
				linear_velocity += dir * proj * BOUNCE_FACTOR
