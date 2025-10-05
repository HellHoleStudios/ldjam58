extends VBoxContainer

func init():
	# Feature:StarFeature . Fuck godot!!
	for feature in Game.instance.features:
		if not feature.mergeable():
			continue
		var lbl = Button.new()
		lbl.name = feature.get_feature_name()
		lbl.text = feature.get_feature_name()
		lbl.flat = true
		lbl.icon = load("res://texture/feature/%s.png" % (feature.get_feature_name()))
		lbl.add_theme_color_override("font_color", Color.GRAY) # Fuck here too
		lbl.add_theme_color_override("font_focus_color", Color.GRAY) # Fuck here too
		lbl.expand_icon = true
		lbl.pressed.connect(func(): open_salami(feature))
		#lbl.font_color=Color.GRAY
		add_child(lbl)

func open_salami(feature):
	$"../Window/TextureRect".texture = load("res://texture/feature/%s.png" % (feature.get_feature_name()))
	$"../Window/Label".text = feature.get_feature_name()
	$"../Window/Label2".text = feature.get_feature_desc()
	$"../Window".popup_centered()
	
func _process(delta: float) -> void:
	if get_child_count() == 0:
		init()
	
	for i: StarFeature in %player.features:
		get_node(i.get_feature_name()).add_theme_color_override("font_color", Color.GREEN)
		get_node(i.get_feature_name()).add_theme_color_override("font_focus_color", Color.GREEN) # Fuck here too
		

func _on_window_close_requested() -> void:
	$"../Window".hide()
