extends StarFeature
class_name Hydrogen

static func get_feature_name() -> String:
	return "Hydrogen"
static func get_feature_desc() -> String:
	return """
Explode when colliding with another star, causing massive damage to nearby stars.
Indicated by red warning circles.

Can be found in the wild with a small chance.
	"""

var cooldown: float = 20
var timer: float = 0.0

var affect_range_ratio: float = 8

var draw_timer: float = 0.0
var animate_interval: float = 2.0
var draw_number: int = 3
var circles: Array[float] = []


static var H_explosion = preload("res://partial/H_explosion.tscn")


func process(delta: float) -> void:
	timer -= delta

	if timer < 0:
		timer = 0

		draw_timer += delta
		if draw_timer > animate_interval:
			draw_timer = 0
			circles.append(0)

	var i = 0
	while i < circles.size():
		circles[i] += delta / animate_interval / float(draw_number)
		if circles[i] > 1:
			circles.remove_at(i)
		else:
			i += 1

	star.queue_redraw()

func draw() -> void:
	# 画三个圆，随着时间轮流从中心向外扩散并变淡
	var radius = star.get_radius() * affect_range_ratio
	var color = Color(1, 0, 0, 0.3)

	for j in range(circles.size()):
		var c = circles[j]
		var r = radius * c
		var a = (1 - c) * 0.3
		color.a = a
		star.draw_circle(Vector2.ZERO, r, color)
		

func crash(other: Star) -> bool:
	if timer > 0:
		return false
	else:
		timer = cooldown

		var affect_range = star.get_radius() * affect_range_ratio

		var flag = false
		for other_star: Star in Game.get_all_stars():
			if other_star != star and other_star.get_position().distance_to(star.get_position()) < affect_range and other_star.mass > star.mass * 0.8:
				other_star.explode(star, 50, false)
				flag = true
		if flag:
			var wave = H_explosion.instantiate()
			wave.init(affect_range)
			star.add_child(wave)
			wave.position = Vector2.ZERO

			circles.clear()

			return true
		else:
			return false

static func generate_weight(stars: Array[Node], player: PlayerStar, star: Star) -> float:
	return 0.05 # 需要更改
