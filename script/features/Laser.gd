extends StarFeature
class_name Laser

var timer = 0
var interval = 2

var particle: Line2D

static func get_feature_name() -> String:
	return "Laser"
static func get_feature_desc() -> String:
	return """
Shoot a layer focused on the nearest large star (>1.5x mass). If focused for long enough, the laser breaks and splits it.
Indicated by a green(player initiated)/red(enemy initiated) line.

Generates after layer 8.
	"""

static var l = preload("res://partial/gas_line.tscn")

var sucking: Star
var timeout = 0.0

func process(delta: float) -> void:
	timeout -= delta
	
	# Find Target
	var smallest_dist = 1e9
	var smallest_star: Star = null
	for other_star in Game.instance.stars.get_children():
		if other_star is not Star or other_star == star or other_star.mass < 1:
			continue
		var os: Star = other_star
		if os.mass > 1.5* star.mass:
			var dist = star.position.distance_to(other_star.position)
			if dist < smallest_dist:
				smallest_star = os
				smallest_dist = dist
	
	if PlayerStar.instance.mass > 1.5* star.mass:
		var dist = star.position.distance_to(PlayerStar.instance.position)
		if dist < smallest_dist:
			smallest_dist = dist
			smallest_star = PlayerStar.instance
	
	# First time using laser.
	if particle == null:
		particle = l.instantiate()
		particle.gradient = null
		
		star.add_child(particle)
	
	# No target
	if smallest_star == null or smallest_dist > star.get_radius() * 20:
		particle.visible = false
		sucking = null
		return
	
	# Target Changed
	var max_timeout = max(0.5, 3.0/level)
	if smallest_star!=sucking:
		timeout = max_timeout
		SoundManager.instance.play_sound("res://sound/laser.wav",0.5,star.position)
	
	sucking = smallest_star
	
	particle.visible = true
	particle.points[1] = smallest_star.position - star.position
	particle.width = 5 / Game.instance.camera.zoom.x
	if star is PlayerStar:
		particle.default_color = Color.GREEN.lightened(timeout / max_timeout)
	else:
		particle.default_color = Color.RED.lightened(timeout / max_timeout)
	
	if timeout < 0 and sucking != null:
		sucking.explode(star, 50.0, false)
		sucking = null

static func generate_weight(stars: Array[Node], player: PlayerStar, star: Star) -> float:
	#print(star)
	if Game.get_layer(star.position) >= 8:
		#print("Indeed greater generate")
		return min(0.25, 0.05 + (Game.get_layer(star.position) - 8) * 0.01)
	return 0
