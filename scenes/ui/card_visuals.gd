class_name CardVisuals
extends Control

@export var card: Card : set = set_card

@onready var panel: Panel = $Panel
@onready var cost: Label = $Cost
@onready var icon: TextureRect = $Icon
@onready var rarity: TextureRect = $Rarity
@onready var description_container: PanelContainer = $DescriptionContainer
# 使用更安全的引用方式
@onready var description_label: RichTextLabel = $DescriptionContainer/DescriptionLabel if has_node("DescriptionContainer/DescriptionLabel") else null
@onready var keyword_tooltip: Control = $KeywordTooltip
@onready var keyword_list: VBoxContainer = $KeywordTooltip/KeywordList


# 在 _ready() 函数中添加鼠标事件处理设置
func _ready() -> void:
	# 确保整个卡牌区域接收鼠标事件
	mouse_filter = Control.MOUSE_FILTER_IGNORE  # 改为忽略，让父节点处理事件
	
	# 确保关键词提示不拦截鼠标事件
	if keyword_tooltip:
		keyword_tooltip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		keyword_tooltip.process_mode = Node.PROCESS_MODE_DISABLED
		# 设置关键词提示框在最上层显示
		keyword_tooltip.z_index = 1000  # 高值确保在最上层

# 添加公共方法供父节点调用
func show_keyword_tooltip():
	if keyword_tooltip != null and keyword_list.get_child_count() > 0:
		# 确保关键词提示框在最上层
		keyword_tooltip.z_index = 1000
		keyword_tooltip.show()
		
		# 调整关键词提示框位置
		var tooltip_size = keyword_tooltip.size
		keyword_tooltip.position.x = size.x + 10
		keyword_tooltip.position.y = min(size.y - tooltip_size.y, 0)

func hide_keyword_tooltip():
	if keyword_tooltip != null:
		keyword_tooltip.hide()

func set_card(value: Card) -> void:
	# 先确保节点准备就绪
	if not is_node_ready():
		await ready
	
	# 添加 null 检查
	if value == null:
		return
		
	card = value
	
	# 安全设置文本属性
	if cost != null:
		cost.text = str(card.cost)
	
	if icon != null:
		icon.texture = card.icon
	
	if rarity != null:
		rarity.modulate = Card.RARITY_COLORS[card.rarity]
	
	# 安全设置描述文本
	if description_label != null:
		description_label.bbcode_enabled = true  # 启用BBCode解析
		description_label.text = card.get_default_tooltip()
	elif description_container != null && description_container.has_node("DescriptionLabel"):
		# 尝试获取子节点
		var label = description_container.get_node("DescriptionLabel") as RichTextLabel
		if label:
			label.bbcode_enabled = true  # 启用BBCode解析
			label.text = card.get_default_tooltip()
			description_label = label
	
	# 初始化关键词列表
	_init_keyword_list()
	
	# 始终显示描述文本
	if description_container != null:
		description_container.show()

func _init_keyword_list() -> void:
	# 清除现有的关键词列表
	if keyword_list:
		for child in keyword_list.get_children():
			child.queue_free()
	
	# 根据卡牌类型添加关键词解释
	if card is Card:
		# 为战士的大猛击卡牌添加关键词解释
		if card.id == "warrior_big_slam":
			_add_keyword("暴露", "敌人受到攻击时多承受50%伤害")
		if card.id == "warrior_true_strength":
			_add_keyword("肌肉", "每层肌肉使攻击多造成1伤害")
		# 可以在这里添加其他卡牌的关键词解释
		# 例如:
		# if card.id == "other_card_id":
		#   _add_keyword("Keyword", "Explanation")

func _add_keyword(name: String, description: String) -> void:
	if keyword_list == null:
		return
		
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	
	# 关键词名称
	var name_label = Label.new()
	name_label.text = name + ":"
	name_label.add_theme_color_override("font_color", Color.GOLD)
	name_label.add_theme_font_size_override("font_size", 20)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	vbox.add_child(name_label)
	
	# 关键词描述
	var desc_label = Label.new()
	desc_label.text = description
	desc_label.add_theme_font_size_override("font_size", 18)
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(desc_label)
	
	keyword_list.add_child(vbox)
	
	# 调整关键词提示框大小以适应新字体
	keyword_tooltip.size = Vector2.ZERO
	keyword_tooltip.reset_size()
