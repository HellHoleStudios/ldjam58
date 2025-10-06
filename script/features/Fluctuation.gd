extends StarFeature
class_name Fluctuation

static var circle_wave_partial = preload("res://partial/circle_wave.tscn")

var timer = 0
var interval = 2

static func get_feature_name() -> String:
	return "Fluctuation"
static func get_feature_desc() -> String:
	return """
Generate a fluctuation wave every once in a while that pulls smaller objects towards the user.
Indicated by a blue wave.
Can be found in the wild with a small chance.
	"""

func process(delta: float) -> void:
	timer += delta
	var affect_range = star.get_radius() * 20

	if timer >= interval:
		print("Fluctuation feature activated")
		
		var wave = circle_wave_partial.instantiate()
		wave.init(affect_range)
		star.add_child(wave)
		wave.position = Vector2.ZERO

		for other_star in Game.get_all_stars():
			if other_star is not Star or other_star == star or other_star.mass > star.mass:
				continue
			var other: Star = other_star
			# 遍历features，检查是否有Bullet且father是自己，不会影响到自己发射的子弹
			var has_bullet = false
			for f in other.features:
				if f is Bullet and f.father == star:
					has_bullet = true
					break
			if has_bullet:
				continue
			var dist = star.position.distance_to(other.position)
			if dist < affect_range:
				var direction = (other.position - star.position).normalized()
				var force_magnitude = 30 * other.mass * star.get_radius()
				other.apply_central_impulse(-direction * force_magnitude)

		timer -= interval

static func generate_weight(stars: Array[Node], player: PlayerStar, star: Star) -> float:
	return 0.05
