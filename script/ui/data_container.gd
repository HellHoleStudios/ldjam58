extends GridContainer

var elements=[]
func _process(delta: float) -> void:
	$Pos.text="(%.1f,%.1f) Layer %d"%[%player.position.x, %player.position.y, Game.get_layer(%player.position)]
	$Mass.text="%.3f M⨀"%(%player.mass)
	$Merge.text="%d times"%(%player.merge_count)
	$Age.text="%.0f%%"%(%player.age*100)
