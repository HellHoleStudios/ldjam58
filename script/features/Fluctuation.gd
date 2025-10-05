extends StarFeature
class_name Fluctuation

static var circle_wave_partial = preload("res://partial/circle_wave.tscn")

var timer = 0
var interval = 2

static func get_feature_name() -> String:
	return "Fluctuation"
static func get_feature_desc() -> String:
	return """
Generate a fluctuation wave every once in a while that pushes large objects away.
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

		for other_star in Game.instance.stars.get_children():
			if other_star is not Star or other_star == star or other_star.mass < star.mass:
				continue
			var dist = star.position.distance_to(other_star.position)
			if dist < affect_range:
				var direction = (other_star.position - star.position).normalized()
				var force_magnitude = 500 * other_star.mass
				other_star.apply_central_impulse(direction * force_magnitude)

		timer -= interval

static func generate_weight(stars: Array[Node], player: PlayerStar) -> float:
	return 0.05
