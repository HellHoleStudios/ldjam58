extends StarFeature
class_name Dash

static func get_feature_name() -> String:
	return "Dash"

static func get_feature_desc() -> String:
	return """
Allows the star to dash quickly in a direction.
Player can dash towards the mouse by holding Shift.
Can be found in the wild with a small chance.
"""

var timer = 0
var interval = 2

var duration = 0.5
var dash_timer = 0

var SPEED = 50

func dash(direction: Vector2) -> void:
	dash_timer = duration
	star.linear_velocity = direction.normalized() * SPEED * star.get_radius()

func process(delta: float) -> void:
	if dash_timer > 0:
		dash_timer -= delta
		star.linear_velocity = star.linear_velocity.normalized() * SPEED * star.get_radius()
		# 生成残影
		if int(dash_timer * 100) % 5 == 0:
			var afterimage = Sprite2D.new()
			var star_sprite = star.get_node_or_null("Sprite")
			if star_sprite:
				# 我也不知道有哪些属性要复制，索性让ai生成一通
				afterimage.texture = star_sprite.texture
				afterimage.region_enabled = star_sprite.region_enabled
				afterimage.region_rect = star_sprite.region_rect
				afterimage.hframes = star_sprite.hframes
				afterimage.vframes = star_sprite.vframes
				afterimage.frame = star_sprite.frame
				afterimage.flip_h = star_sprite.flip_h
				afterimage.flip_v = star_sprite.flip_v
				afterimage.modulate = star_sprite.modulate
				afterimage.position = star.position
				afterimage.z_index = star.z_index - 1
				afterimage.scale = star_sprite.scale
				afterimage.rotation = star_sprite.rotation
				afterimage.global_position = star.global_position
				afterimage.set_deferred("visible", true)
				
				star.get_tree().current_scene.add_child(afterimage)
				afterimage.modulate.a = 0.3
			star.get_tree().create_timer(0.2).timeout.connect(afterimage.queue_free)
	else:
		dash_timer = 0
		timer += delta
		if timer >= interval:
			if star is not PlayerStar:
				timer -= interval

				# Dash forward
				var direction = star.linear_velocity
				if direction == Vector2.ZERO:
					direction = Vector2.RIGHT.rotated(randf() * PI * 2)
				dash(direction)
			elif star is PlayerStar:
				# 检查是否按下Dash键
				if Input.is_action_pressed("Dash"):
					timer -= interval
					# 向鼠标方向冲刺
					var mouse_position = star.get_global_mouse_position()
					var direction = (mouse_position - star.position).normalized()
					dash(direction)

static func generate_weight(stars: Array[Node], player: PlayerStar, star: Star) -> float:
	return 0.04
