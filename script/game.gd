extends Node2D
class_name Game
static var instance: Game

signal init_features_finished

func _ready() -> void:
	instance = self
	init_features()
	init_features_finished.emit()

# 玩家位置和边界参数
var player_pos: Vector2 = Vector2.ZERO
var last_player_pos: Vector2 = Vector2.ZERO
var boundary_radius: float = 2000 # 圆形边界半径，可调整
var density_ratio: float = 1000 # 密度参数，越大生成越稠密
var area_accum: float = 0.0 # 累计新区域面积
const MAX_GRAVITY_DIST = 500 * 500

# stars节点引用（需在ready时获取或导出）
@onready var stars = $stars

# 玩家调用此函数更新位置
func update_player_pos(new_pos: Vector2):
	player_pos = new_pos

func _process(delta):
	player_pos = $player.position
	# 根据玩家能看到的范围确定boundary
	boundary_radius = 1000 / ($player/Sprite/Camera2D.zoom.x)
	density_ratio = 1000 / ($player/Sprite/Camera2D.zoom.x)
	
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
		
		#print(spawn_count)
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
				var layer = get_layer(pos)
				var star = spawn_star_displayer(pos, min(10 ** 7, randf_range(0.1 * 2.0 ** layer, 1.9 * (2.0 ** layer))))
				set_star_features(star)
		area_accum -= spawn_count * density
	
	last_player_pos = player_pos

var features = []
func init_features():
	features = []
	var dir = DirAccess.open("res://script/features") # FIXME according to doc this is not correct.
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".gd"):
				var path = "res://script/features/" + file_name
				var feature_script = load(path)
				if feature_script:
					features.append(feature_script)
			file_name = dir.get_next()
		dir.list_dir_end()

static func get_feature(target_feature: StarFeature):
	for feature_script in instance.features:
		if typeof(target_feature) == TYPE_OBJECT and target_feature.get_script() == feature_script:
			return feature_script
	return null

func set_star_features(star: Star):
	# 给新生成的star添加features
	var total_weight = 1 # 正常star权重为1
	for feature_script in features:
		var weight = feature_script.generate_weight(stars.get_children(), $player)
		total_weight += weight
	var rand_val = randf() * total_weight
	if rand_val < 1:
		return # 不添加任何feature
	rand_val -= 1
	for feature_script in features:
		var weight = feature_script.generate_weight(stars.get_children(), $player)
		if rand_val < weight:
			var feature_instance = feature_script.new(star, 1)

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
			var force = star_a.calc_star_force(star_b)
			if force.is_zero_approx():
				continue
			star_a.apply_central_force(force)
			star_b.apply_central_force(-force)

static var star_partial = preload("res://partial/star_displayer.tscn")

static func get_layer(loc: Vector2) -> int:
	return ceil(loc.length() / 2500)

# 生成star_displayer的函数（需根据实际项目实现）
static func spawn_star_displayer(pos: Vector2, mass: float, linear_velocity: Vector2 = Vector2.ZERO):
	var star: Star = star_partial.instantiate()
	star.mass = mass
	star.position = pos
	star.linear_velocity = linear_velocity
	star.randomize_elements()
	
	instance.stars.add_child(star)
	return star

static func get_all_stars() -> Array:
	var all_stars = []
	for star in instance.stars.get_children():
		if star == null:
			continue
		all_stars.append(star)
	# 添加玩家
	all_stars.append(instance.get_node("player"))
	return all_stars