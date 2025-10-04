## 天体类，要求树下必须有一个`Sprite`和一个`Collision`
class_name Star
extends RigidBody2D

## 类型为：（符号缩写，int）。符号缩写例如H、Fe
var elements: Dictionary
var merge_count: int
var color_ramp=preload("res://partial/star_color.tres")

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
	merge_count=0

func _physics_process(delta: float) -> void:
	rotation=0

func update_mass(_mass: float):
	mass = _mass
	update_visual()

func get_radius() -> float:
	return sqrt(mass) * 3

func get_sprite() -> Sprite2D:
	return $Sprite

func randomize_elements():
	elements={
		"H": randf_range(50,100),
		"He": randf_range(20,50),
		"C":randf_range(1,10),
		"Ne":randf_range(1,5),
		"O":randf_range(1,5),
		"Fe": randf_range(0,1),
		"Si": randf_range(0,1),
	}
	var sm=0
	for k in elements:
		sm+=elements[k]
	for k in elements:
		elements[k]=elements[k]/sm*mass
	update_visual()

func merge_elements(other: Star):
	for i in other.elements:
		if i not in elements:
			elements[i]=0
		elements[i]+=other.elements[i]
	update_visual()

func update_visual():
	var radius = get_radius()
	$Sprite.scale = Vector2(1, 1) * radius / ($Sprite.texture.get_height()/2)
	$Collision.shape.radius = radius
	
	if "H" in elements and "He" in elements:
		print(color_ramp.sample(1-elements["H"]/mass))
		$Sprite.self_modulate=color_ramp.sample(1-elements["H"]/mass)
	
	

func _on_body_entered(body: Node) -> void:
	if body is Star:
		var star: Star = body
		if star.get_mass() < mass:
			if star is not PlayerStar:
				self.update_mass(star.mass + mass)
				self.merge_elements(star)
				star.queue_free()
				print("Sucked!!! New mass:", mass)
				merge_count+=1
			else:
				var BOUNCE_FACTOR = 20
				var dir = (star.position - position).normalized()
				# 连线方向上的分速度设为0
				var rel_vel = star.linear_velocity - linear_velocity
				var proj = rel_vel.dot(dir)
				var v=dir * proj * BOUNCE_FACTOR/(star.mass+mass)
				star.linear_velocity -= v*mass
				linear_velocity += v*star.mass
