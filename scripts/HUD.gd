extends Control

var life_max_max

func _ready():	
	set_fixed_process(true)

func init_life_bar():
	var life_bar = get_node("life_bar")
	life_bar.set_min(0.0)
	life_max_max = get_tree().get_nodes_in_group("player")[0].max_life
	life_bar.set_max(life_max_max)
	

func _fixed_process(delta):
	
	var player = get_tree().get_nodes_in_group("player")[0]
	
	var nb = player.devil_hearts
	var label = get_node("collectable/devil_heart/Label")
	if nb != int(label.get_text()):
		label.set_text(int_to_text(nb))
		
	nb = player.devil_shoes
	label = get_node("collectable/devil_shoes/Label")
	if nb != int(label.get_text()):
		label.set_text(int_to_text(nb))
		
	nb = player.devil_eyes
	label = get_node("collectable/devil_eyes/Label")
	if nb != int(label.get_text()):
		label.set_text(int_to_text(nb))
	
	get_node("life_bar").set_value(player.life * (float(player.life) / float(player.max_life)))

func int_to_text(val) :
	return String(val / 100) + String((val % 100) / 10) + String((val % 100) % 10)
