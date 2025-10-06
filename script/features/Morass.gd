extends StarFeature
class_name Morass

static func get_feature_name() -> String:
	return "Accretion"

static func get_feature_desc() -> String:
	return """
Creates an accretion disk that slows down nearby stars.
Can be found in the wild with a small chance.
"""

var sprite_texture: Texture2D = preload("res://texture/accretion.png")

var sprite: Sprite2D = null

var timer: float = 0.0

func process(delta: float) -> void:
	timer += delta
	if sprite == null:
		sprite = Sprite2D.new()
		sprite.texture = sprite_texture
		star.add_child(sprite)

		# sprite不能覆盖星体
		sprite.z_index = -1

	sprite.rotation-=0.02
	# 半透明，随时间波动
	sprite.modulate.a = 0.3 + 0.04 * sin(timer * 5)

	var affect_range: float = star.get_radius() * 5
	sprite.scale = Vector2.ONE * affect_range / (sprite_texture.get_height() / 2)

	# 对范围内所有星体自己加一层阻尼
	for other_star in Game.get_all_stars():
		var other: Star = other_star
		# 遍历features，检查是否有Bullet且father是自己，不会影响到自己发射的子弹
		var has_bullet = false
		for f in other.features:
			if f is Bullet and f.father == star:
				has_bullet = true
				break
		if has_bullet:
			continue
		if other != star and other.get_position().distance_to(star.get_position()) < affect_range:
			other.linear_velocity *= 0.995

static func generate_weight(stars: Array[Node], player: PlayerStar, star: Star) -> float:
	return 0.02
