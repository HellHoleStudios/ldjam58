extends Node2D

# 玩家位置和边界参数
var player_pos: Vector2 = Vector2.ZERO
var last_player_pos: Vector2 = Vector2.ZERO
var boundary_radius: float = 1000.0 # 圆形边界半径，可调整
var density: float = 50000.0 # 密度参数，越大生成越稀疏
var area_accum: float = 0.0 # 累计新区域面积

# stars节点引用（需在ready时获取或导出）
@onready var stars = get_node_or_null("../stars/")

# 玩家调用此函数更新位置
func update_player_pos(new_pos: Vector2):
	player_pos = new_pos

func _process(delta):
	if not stars:
		return
	# 1. 检查所有star_displayer是否在圆形边界内
	for star in stars.get_children():
		if not star.has_method("get_position"):
			continue
		var pos = star.position if star.has_variable("position") else star.get_position()
		if pos.distance_to(player_pos) > boundary_radius:
			star.queue_free()

	# 2. 计算新旧圆环区域面积
	var area_new = PI * pow(boundary_radius, 2)
	var area_old = PI * pow(boundary_radius, 2)
	var move_dist = player_pos.distance_to(last_player_pos)
	if move_dist > 0:
		# 相应方向的半圆向player_pos-last_player_pos运动产生的区域：2*PI*R*dx
		var ring_area = PI * boundary_radius * move_dist
		area_accum += ring_area
		# 3. 按密度生成新star_displayer
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
			var pos = player_pos + offset + advance

			# 只生成在新圆环区域（即距离last_player_pos > boundary_radius）
			if pos.distance_to(last_player_pos) > boundary_radius:
				spawn_star_displayer(pos)
		area_accum -= spawn_count * density

	last_player_pos = player_pos

# 生成star_displayer的函数（需根据实际项目实现）
func spawn_star_displayer(pos: Vector2):
	# TODO: 替换为实际生成逻辑
	var star_partial = preload("res://partial/star_displayer.tscn")
	var star = star_partial.instance()
	star.position = pos
	stars.add_child(star)
