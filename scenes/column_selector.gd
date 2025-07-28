extends Sprite2D

# default to middle column
var current_column_index = 1
var x_position_map = {
	0: 838,
	1: 970,
	2: 1102,
}

func _tween_to_column(index: int) -> void:
	var target_x = x_position_map[index]
	var tween := create_tween()
	tween.tween_property(self, "position:x", target_x, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("next_column"):
		if current_column_index == 2:
			return
		current_column_index += 1
		_tween_to_column(current_column_index)
	elif event.is_action_pressed("prev_column"):
		if current_column_index == 0:
			return
		current_column_index -= 1
		_tween_to_column(current_column_index)
	elif event.is_action_pressed("select"):
		SignalBus.on_column_selected.emit(current_column_index)

func _ready() -> void:
	position.x = x_position_map[current_column_index]
