## 天体类，要求树下必须有一个`Sprite`和一个`Collision`
class_name Star
extends RigidBody2D

## 类型为：（符号缩写，int）。符号缩写例如H、Fe
var elements: Dictionary
var merge_count: int

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
	merge_count = 0

func _physics_process(delta: float) -> void:
	rotation = 0

func update_mass(_mass: float):
	mass = _mass
	update_visual()

func get_radius() -> float:
	print(mass, sqrt(mass) * 3)
	return sqrt(mass) * 3

func get_sprite() -> Sprite2D:
	return $Sprite

func randomize_elements():
	elements = {
		"H": randf_range(50, 100),
		"He": randf_range(20, 50),
		"C": randf_range(1, 10),
		"Ne": randf_range(1, 5),
		"O": randf_range(1, 5),
		"Fe": randf_range(0, 1),
		"Si": randf_range(0, 1),
	}
	var sm = 0
	for k in elements:
		sm += elements[k]
	for k in elements:
		elements[k] = elements[k] / sm * mass

func merge_elements(other: Star):
	for i in other.elements:
		if i not in elements:
			elements[i] = 0
		elements[i] += other.elements[i]

func split(split_mass: float) -> Star:
	if split_mass >= mass:
		return null
	var new_star = Game.spawn_star_displayer(position, split_mass)
	self.update_mass(mass - split_mass)
	var radius_sum = get_radius() + new_star.get_radius()
	# 位置稍微偏移，防止重叠
	var rand_angle = randf() * PI * 2
	new_star.position = position + Vector2(radius_sum * 1.1, 0).rotated(rand_angle)
	new_star.linear_velocity = linear_velocity + Vector2(linear_velocity.length() * 1, 0).rotated(rand_angle + PI / 2)
	
	# 按比例分配元素
	new_star.elements = {}
	for k in elements:
		var portion = elements[k] * (split_mass / (mass + split_mass))
		new_star.elements[k] = portion
		elements[k] -= portion
	update_visual()
	new_star.update_visual()
	return new_star

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
				self.merge_elements(star)
				star.queue_free()
				print("Sucked!!! New mass:", mass)
				merge_count += 1
			else:
				if (star.linear_velocity - linear_velocity).length() < 20: # 临界速度可调
					var BOUNCE_FACTOR = 20
					var dir = (star.position - position).normalized()
					# 连线方向上的分速度设为0
					var rel_vel = star.linear_velocity - linear_velocity
					var proj = rel_vel.dot(dir)
					var v = dir * proj * BOUNCE_FACTOR / (star.mass + mass)
					star.linear_velocity -= v * mass
					linear_velocity += v * star.mass
				else:
					print("split")
					linear_velocity = star.linear_velocity * 2
					# 分裂成多个碎块
					var split_num = int((star.linear_velocity - linear_velocity).length() / 20) + randi_range(0, 2)
					# 碎块质量随机分配
					var masse_ratios = []
					var sum = 0
					for i in range(split_num):
						masse_ratios.append(randf_range(0, 1))
						sum += masse_ratios[i]
					for i in range(split_num):
						print(star.mass * masse_ratios[i] / sum)
						split(star.mass * masse_ratios[i] / sum)
					var rand_angle = randf() * PI * 2
					linear_velocity = linear_velocity + Vector2(linear_velocity.length() * 2, 0).rotated(rand_angle + PI / 2)

					star.linear_velocity = Vector2.ZERO
