extends Node2D
class_name Game
static var instance: Game
func _ready() -> void:
	instance = self

# 玩家位置和边界参数
var player_pos: Vector2 = Vector2.ZERO
var last_player_pos: Vector2 = Vector2.ZERO
var boundary_radius: float = 1000 # 圆形边界半径，可调整
var density_ratio: float = 1000 # 密度参数，越大生成越稠密
var area_accum: float = 0.0 # 累计新区域面积
const MAX_GRAVITY_DIST=500*500

# stars节点引用（需在ready时获取或导出）
@onready var stars = $stars

# 玩家调用此函数更新位置
func update_player_pos(new_pos: Vector2):
	player_pos = new_pos

func _process(delta):
	player_pos = $player.position
	if not stars:
		return
	clean_up_stars()
	generate_stars()

	# 计算所有星体间的引力并应用
	update_star_forces()
	
func clean_up_stars():
	# 检查所有star_displayer是否在圆形边界内
	for star in stars.get_children():
		var pos = star.position
		if pos.distance_to(player_pos) > boundary_radius:
			star.queue_free()

func generate_stars():
	# 计算新旧圆环区域面积
	var move_dist = player_pos.distance_to(last_player_pos)
	if move_dist > 0:
		# 相应方向的半圆向player_pos-last_player_pos运动产生的区域：2*PI*R*dx
		var ring_area = PI * boundary_radius * move_dist
		area_accum += ring_area
		# 按密度生成新star_displayer
		var density = boundary_radius * boundary_radius / density_ratio
		var spawn_count = int(area_accum / density)
		for i in range(spawn_count):
			# 计算玩家移动方向
			var move_vec = player_pos - last_player_pos
			var move_dir = move_vec.normalized() if move_dist > 0 else Vector2.RIGHT

			# 半圆弧的中心为player_pos，方向与move_dir对齐
			# 随机半圆弧角度（-PI/2到PI/2），以move_dir为0度
			var theta = (randf() - 0.5) * PI
			var r = boundary_radius * sqrt(randf())
			# 旋转单位向量
			var dir = move_dir.rotated(theta)
			var offset = dir * r

			# 沿移动方向再推进0~1倍的移动距离
			var advance = move_dir * (randf() * move_dist)
			var pos = player_pos + offset - advance

			# 只生成在新圆环区域（即距离last_player_pos > boundary_radius）
			if pos.distance_to(last_player_pos) > boundary_radius:
				spawn_star_displayer(pos, randf_range(5, 15))
		area_accum -= spawn_count * density
	
	last_player_pos = player_pos

func update_star_forces():
	# 所有stars内的BaseStarData再加上玩家的BaseStarData
	var player_star: Star = $player
	var all_stars: Array = [player_star]
	for star in stars.get_children():
		all_stars.append(star)
	
	# 计算每对星体间的引力并应用
	for i in range(all_stars.size()):
		for j in range(i + 1, all_stars.size()):
			var star_a: Star = all_stars[i]
			var star_b: Star = all_stars[j]
			var force = calc_star_force(star_a, star_b)
			if force.is_zero_approx():
				continue
			star_a.apply_central_impulse(force)
			star_b.apply_central_impulse(-force)

func calc_star_force(star_a: Star, star_b: Star) -> Vector2:
	var G = 1000 # 引力常数，可调整
	var dir = star_b.get_sprite().global_position - star_a.get_sprite().global_position
	var dist_sq = dir.length_squared()
	if dist_sq == 0:
		return Vector2.ZERO
	if dist_sq > MAX_GRAVITY_DIST:
		return Vector2.ZERO
	var min_dist = star_a.get_radius() + star_b.get_radius()
	min_dist*=1.5
	var dist = sqrt(dist_sq)
	var force_mag = G * star_a.get_mass() * star_b.get_mass() / dist_sq
	
	if dist < min_dist:
		#force_mag = (dist / min_dist) * (G * star_a.get_mass() * star_b.get_mass() / (min_dist * min_dist))
		force_mag = (G * star_a.get_mass() * star_b.get_mass() / (min_dist * min_dist))
	return dir.normalized() * force_mag

static var star_partial = preload("res://partial/star_displayer.tscn")
# 生成star_displayer的函数（需根据实际项目实现）
static func spawn_star_displayer(pos: Vector2, mass: float, linear_velocity: Vector2 = Vector2.ZERO):
	var star:Star = star_partial.instantiate()
	star.mass = mass
	star.position = pos
	star.linear_velocity = linear_velocity
	star.elements={
		"H": randi_range(0,1),
		"He": randi_range(0,1),
		"Fe": randi_range(0,1),
		"Si": randi_range(0,1)
	}
	
	instance.stars.add_child(star)
