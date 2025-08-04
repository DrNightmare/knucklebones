extends Control
class_name CustomColumn

enum Direction { UP, DOWN }

@export var stack_direction: Direction = Direction.DOWN
@export var entry_height: float = 125.0
@export var max_entries: int = 3
@onready var score_label: Label = $ScoreLabel

var values: Array[int] = []
var sprites: Array[TextureRect] = []

const texture_map := {
	1: preload("res://assets/one.png"),
	2: preload("res://assets/two.png"),
	3: preload("res://assets/three.png"),
	4: preload("res://assets/four.png"),
	5: preload("res://assets/five.png"),
	6: preload("res://assets/six.png"),
}

func _ready() -> void:
	score_label.text = ""
	call_deferred("update_score_label_position")

func get_score_text(score: int) -> String:
	return "" if score == 0 else str(score)

func add_value(value: int):
	if value < 1 or value > 6:
		push_warning("Invalid die value: %d" % value)
		return
	if values.size() >= max_entries:
		push_warning("Column full, cannot add more")
		return

	values.append(value)

	var tex_rect := TextureRect.new()
	tex_rect.texture = texture_map[value]
	tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex_rect.custom_minimum_size = Vector2(100, 100)
	tex_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	tex_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	add_child(tex_rect)
	sprites.append(tex_rect)

	# Set initial position offset (spawn in from slight vertical offset)
	var y_position = -50 if stack_direction == Direction.DOWN else 50
	tex_rect.position = get_entry_position(values.size() - 1) + Vector2(0, y_position)

	score_label.text = get_score_text(get_score())
	animate_all_entries()

func remove_all_of_value(value: int):
	for i in range(values.size() - 1, -1, -1):
		if values[i] == value:
			values.remove_at(i)
			var sprite = sprites[i]
			sprites.remove_at(i)
			sprite.queue_free()

	score_label.text = get_score_text(get_score())
	animate_all_entries()

func clear():
	values.clear()
	for sprite in sprites:
		sprite.queue_free()
	sprites.clear()
	score_label.text = ""

func is_full() -> bool:
	return values.size() >= max_entries

func get_score() -> int:
	var freq := {}
	for v in values:
		freq[v] = freq.get(v, 0) + 1

	var score = 0
	for v in values:
		score += v * freq[v]
	return score

func get_entry_position(index: int) -> Vector2:
	var y_offset := entry_height * index
	return Vector2(0, -y_offset if stack_direction == Direction.DOWN else y_offset)

func animate_all_entries():
	for i in range(sprites.size()):
		var sprite = sprites[i]
		var target_pos = get_entry_position(i)

		var tween = create_tween()
		tween.tween_property(sprite, "position", target_pos, 0.3) \
			.set_trans(Tween.TRANS_CUBIC) \
			.set_ease(Tween.EASE_OUT)

func update_score_label_position():
	var entry_position = get_entry_position(0)
	var label_offset = entry_height * max_entries
	match stack_direction:
		Direction.UP:
			score_label.position = Vector2(entry_position.x + 25, label_offset)
		Direction.DOWN:
			score_label.position = Vector2(entry_position.x + 25, -label_offset + 70)
