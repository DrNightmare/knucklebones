extends Node
class_name PlayerBoard

@onready var columns = [
	$HBoxContainer/Column,
	$HBoxContainer/Column2,
	$HBoxContainer/Column3
]
@onready var score_label: Label = $ScoreLabel

func reset_board():
	for col in columns:
		col.clear()
	score_label.text = str(0)

func can_place(column_index: int) -> bool:
	return not columns[column_index].is_full()

func place_die(column_index: int, die_value: int):
	columns[column_index].add_value(die_value)
	score_label.text = str(get_total_score())

func remove_dice_with_value(column_index: int, value: int):
	columns[column_index].remove_all_of_value(value)
	score_label.text = str(get_total_score())

func get_total_score() -> int:
	var total = 0
	for col in columns:
		total += col.get_score()
	return total

func is_full() -> bool:
	for col in columns:
		if not col.is_full():
			return false
	return true
