class_name block_medicine
extends Medicine


# 使用药水
func use_medicine(owner: MedicineUI) -> void:
	var player := owner.get_tree().get_first_node_in_group("player") as Player
	if player:
		var block_effect := BlockEffect.new()
		block_effect.amount = value
		block_effect.execute([player])
