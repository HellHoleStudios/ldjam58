extends StarFeature
class_name Gunner

var bullet_script = preload("res://script/features/Bullet.gd")

var interval = 3.0
var timer = 0.0

static func get_feature_name() -> String:
	return "Coronal Ejection"
static func get_feature_desc() -> String:
	return """
Eject a small portion of own mass every few seconds. 
When Ejecta hits a target, it may break it.
Can be found in the wild with a small chance.
	"""


func shoot(direction: Vector2) -> void:
	var BULLET_MASS_RATIO = 0.2
	var bullet = Game.spawn_star_displayer(star.position,
										   star.mass * BULLET_MASS_RATIO)
	star.update_mass(star.mass * (1 - BULLET_MASS_RATIO))

	# 位置稍微偏移，防止重叠 
	var radius_sum = star.get_radius() + bullet.get_radius()
	bullet.position += direction.normalized() * radius_sum * 1.5
	star.add_ignore_gravity(bullet, 5)

	bullet.linear_velocity = direction.normalized() * 600
	var bullet_feature = bullet_script.new(bullet, 1)
	bullet_feature.father = star

func process(delta: float) -> void:
	timer -= delta
	if timer <= 0:
		timer += interval
		var bullet = Star.new()
		
		# 瞄准最近的更大星体
		var target: Star = null
		var min_dist = INF
		for other in Game.get_all_stars():
			if other is Star and other != star and other.mass > star.mass:
				var dist = star.position.distance_to(other.position)
				if dist < min_dist:
					min_dist = dist
					target = other
		if target:
			var direction = (target.position - star.position).normalized()
			shoot(direction)

func draw() -> void:
	# debug
	star.draw_circle(Vector2.ZERO, star.get_radius() + 15, Color(1, 1, 0, 0.5))

static func generate_weight(stars: Array[Node], player: PlayerStar, star: Star) -> float:
	return 0.02
