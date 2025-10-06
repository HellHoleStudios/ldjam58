extends StarFeature
class_name Gas

var timer = 0
var interval = 2

var particle: Line2D

static func get_feature_name() -> String:
	return "Gas"
static func get_feature_desc() -> String:
	return """
Steal mass from the closest small star nearby.
Indicated by an orange(gaining mass)/cyan(losing mass) line.
Generates after layer 5.
	"""

static var l=preload("res://partial/gas_line.tscn")

var acc_delta=0

func process(delta: float) -> void:
	acc_delta+=delta
	
	var smallest_dist=1e9
	var smallest_star:Star=null
	for other_star in Game.instance.stars.get_children():
		if other_star is not Star or other_star == star or other_star.mass<1:
			continue
		var os:Star=other_star
		if os.mass<star.mass*0.75:
			var dist = star.position.distance_to(other_star.position)
			if dist<smallest_dist:
				smallest_star=os
				smallest_dist=dist
	
	if PlayerStar.instance.mass<star.mass*0.75:
		var dist = star.position.distance_to(PlayerStar.instance.position)
		if dist<smallest_dist:
			smallest_dist=dist
			smallest_star=PlayerStar.instance
			
	if particle==null:
		particle=l.instantiate()
		star.add_child(particle)
		
	if smallest_star==null or smallest_dist>star.get_radius()*10:
		particle.visible=false
		return
	
	particle.visible=true
	particle.points[1]=smallest_star.position-star.position
	particle.width=sin(acc_delta*2)*2+5
	
	var steal=smallest_star.mass*(level/10000.0)
	
	#print("Stealing mass:",steal, "from:",smallest_star, "lvl=",level)
	
	smallest_star.update_mass(smallest_star.mass-steal)
	star.update_mass(star.mass+steal)

static func generate_weight(stars: Array[Node], player: PlayerStar, star: Star) -> float:
	#print(star)
	if Game.get_layer(star.position)>=5:
		#print("Indeed greater generate")
		return 0.05
	return 0
