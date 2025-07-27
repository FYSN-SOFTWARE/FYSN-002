class_name FruitJuice
extends Medicine


# 使用药水
func use_medicine(owner: MedicineUI) -> void:
	var player := owner.get_tree().get_first_node_in_group("player") as Player
	if player:
		var init_max_health = player.stats.max_health
		player.stats.max_health = init_max_health + value
		
