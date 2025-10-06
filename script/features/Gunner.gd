extends StarFeature
class_name Gunner

var bullet_script = preload("res://script/features/Bullet.gd")

var interval = 3.0
var timer = 0.0

static func get_feature_name() -> String:
	return "Ejector"
static func get_feature_desc() -> String:
	return """
Eject a small portion of own mass by clicking [RIGHT MOUSE BUTTON] (or once in a while if the user is not a player). 
When Ejecta hits a target, it may break the target.
Can be found in the wild with a small chance.
	"""

func init(_star: Star, _level: int) -> void:
	_star.queue_redraw()
	super.init(_star, _level)

func shoot(direction: Vector2) -> void:
	var BULLET_MASS_RATIO = 0.02
	var bullet = Game.spawn_star_displayer(star.position,
										   star.mass * BULLET_MASS_RATIO)
	star.update_mass(star.mass * (1 - BULLET_MASS_RATIO))

	# 位置稍微偏移，防止重叠 
	var radius_sum = star.get_radius() + bullet.get_radius()
	bullet.position += direction.normalized() * radius_sum * 1.5
	star.add_ignore_gravity(bullet, 5)

	bullet.linear_velocity = direction.normalized() * star.get_radius() * 40
	var bullet_feature = bullet_script.new(bullet, 1)
	bullet_feature.father = star

func process(delta: float) -> void:
	if star is PlayerStar:
		var direction: Vector2 = Vector2.ZERO
		if Input.is_action_just_pressed("Shoot"):
			print("Mouse left clicked")
			var mouse_pos = star.get_global_mouse_position()
			direction = (mouse_pos - star.position).normalized()
			if direction != Vector2.ZERO:
				shoot(direction)
		return
	
	timer -= delta
	if timer <= 0:
		timer += interval
		#var bullet = Star.new()

		var direction: Vector2 = Vector2.ZERO
		if star is not PlayerStar:
			var target: Star = null
			# 瞄准最近的更大星体
			var min_dist = INF
			for other in Game.get_all_stars():
				if other is Star and other != star and other.mass > star.mass:
					var dist = star.position.distance_to(other.position)
					if dist < min_dist:
						min_dist = dist
						target = other
			if target:
				direction = (target.position - star.position).normalized()

		if direction != Vector2.ZERO:
			shoot(direction)

func draw() -> void:
	# debug
	star.draw_circle(Vector2.ZERO, star.get_radius() * 1.1, Color(1, 1, 0, 0.5))

static func generate_weight(stars: Array[Node], player: PlayerStar, star: Star) -> float:
	return 0.02
