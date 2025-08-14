class_name Medicine
extends Resource

# 药水稀有度枚举
enum Rarity { COMMON, UNCOMMON, RARE }

@export var medicine_name: String
@export var id: String # 药水唯一标识符
@export var icon: Texture2D # 药水图标
@export var rarity: Rarity # 药水稀有度
@export var battle_only: bool = true  # 是否只能在战斗中使用
@export var value: int = 0 # 药水效果数值
@export var target: String = "SELF" # SELF,ENEMY,RANDOM_ENEMY 药水目标类型
@export_multiline var tooltip: String   # 药水描述文本

# 初始化药水
func initialize_medicine(_owner: MedicineUI) -> void:
	pass
	
# 使用药水
func use_medicine(_owner: MedicineUI) -> void:
	pass
	
# 获取药水描述
func get_tooltip() -> String:
	return tooltip
