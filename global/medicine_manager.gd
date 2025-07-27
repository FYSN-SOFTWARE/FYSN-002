# 药水管理器
# 全局管理药水资源和掉落概率
extends Node

var medicines: Array[Medicine] = []  # 所有药水资源
var medicine_drop_chance: float = 1.0   # 初始掉落概率

func _ready() -> void:
	load_all_medicines()
	
# 加载所有药水资源
func load_all_medicines():
	var dir = DirAccess.open("res://medicines/")
	if dir:
		dir.list_dir_begin()
		var filename = dir.get_next()
		while filename != "":
			if filename.ends_with(".tres"):
				#print(filename)
				if filename == "default_medicine.tres" or filename == "strength_medicine.tres":
					filename = dir.get_next()
					continue
				#if filename != "duplication_medicine.tres":
					#filename = dir.get_next()
					#continue
				var resource_path = "res://medicines/" + filename
				var medicine_resource = load(resource_path)
				if medicine_resource:
					medicines.append(medicine_resource)
			
			filename = dir.get_next()
	

# 获取随机药水
func get_random_medicine() -> Medicine:
	var rand_value = randf()
	var rarity_pool: Array[Medicine] = []
	
	if rand_value < 0.65: # 65% 普通
		rarity_pool = medicines.filter(func(p): return p.rarity == Medicine.Rarity.COMMON)
	elif rand_value < 0.9: # 25% 罕见
		rarity_pool = medicines.filter(func(p): return p.rarity == Medicine.Rarity.UNCOMMON)
	else: # 10% 稀有
		rarity_pool = medicines.filter(func(p): return p.rarity == Medicine.Rarity.RARE)	
	
	if rarity_pool.size() > 0:
		return rarity_pool[randi() % rarity_pool.size()]
	return medicines[0]


# 更新掉落概率
func update_drop_chance(dropped: bool) -> void:
	if dropped:
		medicine_drop_chance = max(0.1,medicine_drop_chance - 0.1)
	else:
		medicine_drop_chance = min(1.0,medicine_drop_chance + 0.1)

# 本轮是否能掉落药水
func can_drop_medicine() -> bool:
	var rand_value = randf()
	if rand_value <= medicine_drop_chance:
		update_drop_chance(true)
		return true
	else:
		update_drop_chance(false)
		return false
