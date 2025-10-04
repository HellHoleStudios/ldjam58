extends GridContainer

var elements=[]
func _process(delta: float) -> void:
	$Mass.text="%.3f M⨀"%(%player.mass)
	$Merge.text="%d times"%(%player.merge_count)
	for i in %player.elements:
		if i not in elements:
			elements.append(i)
			
			var lbl=Label.new()
			lbl.text=i
			add_child(lbl)
			
			var lbl2=Label.new()
			lbl2.name=i
			lbl2.text="UWU"
			add_child(lbl2)
	
	for i in elements:
		get_node(i).text="%.3f M⨀"%[%player.elements[i]]
