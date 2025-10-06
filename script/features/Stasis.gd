extends StarFeature
class_name Stasis

var sprite_texture: Texture2D = preload("res://texture/stasis_cover.png")
var sprite: Sprite2D = null

static func get_feature_name() -> String:
	return "Sturdy"
static func get_feature_desc() -> String:
	return """
The star can resist crash force and cannot split from crash, but lose 1% mass.
	"""

func process(_delta: float) -> void: 
	if sprite == null:
		sprite = Sprite2D.new()
		sprite.texture = sprite_texture
		star.add_child(sprite)
		sprite.modulate.a = 0.3
	sprite.scale = star.get_sprite().scale

func crash(other: Star) -> bool:
	if other is not PlayerStar && star.mass >= other.mass:
		star.merge(other)
	elif star is not PlayerStar && star.mass <= other.mass:
		other.merge(star)
	else:
		# 相互忽略0.2秒引力
		var CRASH_SPEED = 50
		if (other.linear_velocity - star.linear_velocity).length() > CRASH_SPEED && other is not PlayerStar:
			var flag = true
			for f in other.features:
				if f is Stasis:
					flag = false
			if flag:
				other.explode(star, CRASH_SPEED)
		star.mass = star.mass * 0.99
		star.add_ignore_gravity(other, 0.2)
		other.add_ignore_gravity(star, 0.2)
	return true

static func generate_weight(stars: Array[Node], player: PlayerStar, star: Star) -> float:
	for f in player.features:
		if f is Morass:
			return 0.1
	return 0
