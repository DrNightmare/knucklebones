extends VBoxContainer
class_name Column

@onready var score_label: Label = $ScoreLabel

const texture_map = {
	1: preload("res://assets/one.png"),
	2: preload("res://assets/two.png"),
	3: preload("res://assets/three.png"),
	4: preload("res://assets/four.png"),
	5: preload("res://assets/five.png"),
	6: preload("res://assets/six.png"),
}

var values: Array = []

func _ready() -> void:
	score_label.text = '0'

func add_value(value: int):
	if value < 1 or value > 6:
		push_warning("Invalid value %d, not adding" % value)
		return
	if values.size() == 3:
		push_warning("Column full, not adding")
		return

	values.append(value)

	var texture_rect = TextureRect.new()
	texture_rect.texture = texture_map[value]
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.custom_minimum_size = Vector2(112, 112)
	add_child(texture_rect)
	score_label.text = str(get_score())


func remove_all_of_value(value: int):
	if values.is_empty():
		return

	# Remove all matching values from the data list
	values = values.filter(func(v): return v != value)

	# Remove all matching TextureRects from the visual column
	for child in get_children():
		if child is TextureRect and child.texture == texture_map[value]:
			child.queue_free()

	# Update score label if applicable
	if score_label:
		score_label.text = str(get_score())

func clear():
	values.clear()
	for child in get_children():
		if child is TextureRect:
			child.queue_free()

func get_score() -> int:
	var freq_map = {}
	for v in values:
		freq_map[v] = freq_map.get(v, 0) + 1

	var score = 0
	for v in values:
		score += v * freq_map[v]
	return score

func is_full() -> bool:
	return values.size() >= 3
