## 天体类，要求树下必须有一个`Sprite`和一个`Collision`
class_name Star
extends RigidBody2D

## 类型为：（符号缩写，int）。符号缩写例如H、Fe
var elements: Dictionary
var merge_count: int
var color_ramp = preload("res://partial/star_color.tres")
var explosion_scene = preload("res://partial/explosion.tscn")

var features: Array[StarFeature] = []

var IgnoreGravity: Dictionary[Star, float] = {}

#func _init(_mass: float = 1.0):
	#self.mass=_mass
	#
	#$Collision.shape=CircleShape2D.new()
	#update_visual()

func _ready() -> void:
	#$Collision.shape = CircleShape2D.new()
	update_visual()

	contact_monitor = true
	max_contacts_reported = 4
	merge_count = 0

func _process(delta: float) -> void:
	for f in features:
		f.process(delta)
	update_ignore_gravity(delta)

func _draw() -> void:
	for f in features:
		f.draw()

func _physics_process(_delta: float) -> void:
	rotation = 0

func update_mass(_mass: float):
	mass = _mass
	update_visual()

func get_radius() -> float:
	return sqrt(mass) * 3

func get_sprite() -> Sprite2D:
	return $Sprite

func randomize_elements():
	var h = randf_range(30, 80)
	elements = {
		"H": h,
		"He": 90 - h,
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
	update_visual()

func merge_elements(other: Star):
	for i in other.elements:
		if i not in elements:
			elements[i] = 0
		elements[i] += other.elements[i]
	update_visual()

func split(split_mass: float) -> Star:
	if split_mass >= mass:
		return null
	var new_star = Game.spawn_star_displayer(position, split_mass)
	self.update_mass(mass - split_mass)
	var radius_sum = get_radius() + new_star.get_radius()
	# 位置稍微偏移，防止重叠
	var rand_angle = randf() * PI * 2
	new_star.position = position + Vector2(radius_sum * 1.01, 0).rotated(rand_angle)
	new_star.linear_velocity = linear_velocity + Vector2(linear_velocity.length() * randf_range(0, 1) + radius_sum * 10, 0).rotated(rand_angle)
	
	# 按比例分配元素
	new_star.elements = {}
	for k in elements:
		var portion = elements[k] * (split_mass / (mass + split_mass))
		new_star.elements[k] = portion
		elements[k] -= portion
	update_visual()
	new_star.update_visual()

	# 添加忽略引力
	add_ignore_gravity(new_star, 0.5)
	return new_star

func update_visual():
	var radius = get_radius()
	$Sprite.scale = Vector2(1, 1) * radius / ($Sprite.texture.get_height() / 2)
	$Collision.shape.radius = radius

	if "H" in elements and "He" in elements:
		#print(color_ramp.sample(1 - elements["H"] / mass))
		$Sprite.self_modulate = color_ramp.sample(1 - elements["H"] / mass)

func merge_features(other: Star) -> void:
	for f in other.features:
		if not f.mergeable():
			continue

		var found = false
		for i in range(features.size()):
			if features[i].get_script() == f.get_script():
				features[i].merge(f)
				found = true
				break
		if not found:
			# 复制一个新的同类feature
			Game.get_feature(f).new(self, f.level)

func merge(other: Star) -> void:
	# 动量守恒
	var total_mass = other.mass + mass
	var new_velocity = (other.linear_velocity * other.mass + linear_velocity * mass) / total_mass
	linear_velocity = new_velocity
	# 位置移到重心
	position = (other.position * other.mass + position * mass) / total_mass

	self.update_mass(mass + other.mass)
	self.merge_elements(other)
	self.merge_features(other)
	other.queue_free()
	merge_count += 1
	
func _on_body_entered(body: Node) -> void:
	if body is Star:
		var star: Star = body
		if star.mass < mass:
			# feature可接管撞击判定
			var flag = false
			for f in features:
				if f.crash(star):
					flag = true
			for f in star.features:
				if f.crash(self):
					flag = true
			if flag:
				return
				
			if star is not PlayerStar:
				merge(star)
			else:
				var CRASH_SPEED = 50
				if (star.linear_velocity - linear_velocity).length() > CRASH_SPEED: # 临界速度可调
					#print("split")
					linear_velocity = star.linear_velocity * 2
					# 分裂成多个碎块
					var split_num = min(int((star.linear_velocity - linear_velocity).length() / CRASH_SPEED * 0.5) + randi_range(2, 4), 10) + 8
					# 碎块质量随机分配
					var masse_ratios = []
					var sum = 0
					for i in range(split_num):
						masse_ratios.append(randf_range(1, 10))
						sum += masse_ratios[i]

					var fragments = [self]
					for i in range(split_num):
						#print(mass * masse_ratios[i] / sum)
						var fragment = split(mass * masse_ratios[i] / sum)
						if fragment:
							fragments.append(fragment)
					star.linear_velocity *= -0.5

					# 碎片之间忽略0.2秒引力
					for fragment_a in fragments:
						for fragment_b in fragments:
							if fragment_a == fragment_b:
								continue
							fragment_a.add_ignore_gravity(fragment_b, 0.2)

					var explosion: Sprite2D = explosion_scene.instantiate()
					get_tree().current_scene.add_child(explosion)
					explosion.global_position = global_position
					var explosion_scale = get_radius() / 40
					explosion.scale = Vector2(explosion_scale, explosion_scale)
				else:
					var BOUNCE_FACTOR = 20
					var dir = (star.position - position).normalized()
					# 连线方向上的分速度设为0
					var rel_vel = star.linear_velocity - linear_velocity
					var proj = rel_vel.dot(dir)
					var v = dir * proj * BOUNCE_FACTOR / (star.mass + mass)
					star.linear_velocity -= v * mass
					linear_velocity += v * star.mass

					# 相互忽略0.2秒引力
					star.add_ignore_gravity(self, 0.2)
					add_ignore_gravity(star, 0.2)

func calc_star_force(other: Star) -> Vector2:
	if other in IgnoreGravity:
		return Vector2.ZERO

	var G = 100000 # 引力常数，可调整
	var dir = other.get_sprite().global_position - get_sprite().global_position
	var dist_sq = dir.length_squared()
	if dist_sq == 0:
		return Vector2.ZERO
	if dist_sq > Game.MAX_GRAVITY_DIST / pow(Game.instance.get_node("player/Sprite/Camera2D").zoom.x, 2):
		return Vector2.ZERO
	var min_dist = get_radius() + other.get_radius()
	min_dist *= 1.5
	var dist = sqrt(dist_sq)
	var force_mag = G * get_mass() * other.get_mass() / dist_sq

	if dist < min_dist:
		force_mag = G * get_mass() * other.get_mass() / pow(min_dist, 2)
	return dir.normalized() * force_mag

func update_ignore_gravity(delta: float):
	var to_remove = []
	for star in IgnoreGravity.keys():
		if not is_instance_valid(star):
			to_remove.append(star)
			continue
		IgnoreGravity[star] -= delta
		if IgnoreGravity[star] <= 0:
			to_remove.append(star)
	for star in to_remove:
		IgnoreGravity.erase(star)

func add_ignore_gravity(star: Star, duration: float):
	IgnoreGravity[star] = duration
