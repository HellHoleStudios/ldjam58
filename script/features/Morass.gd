extends StarFeature
class_name Morass

var sprite_texture: Texture2D = preload("res://texture/morass.png")

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

    # 半透明，随时间波动
    sprite.modulate.a = 0.3 + 0.1 * sin(timer * 5)

    var affect_range: float = star.get_radius() * 5
    sprite.scale = Vector2.ONE * affect_range / (sprite_texture.get_height() / 2)

    # 对范围内所有星体自己加一层阻尼
    for other_star in Game.get_all_stars():
        var other: Star = other_star
        if other != star and other.get_position().distance_to(star.get_position()) < affect_range:
            other.linear_velocity *= 0.95

static func generate_weight(stars: Array[Node], player: PlayerStar, star: Star) -> float:
    return 0.02