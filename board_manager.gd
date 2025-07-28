# BoardManager.gd
extends Node
class_name BoardManager

@onready var player_board: PlayerBoard = $PlayerBoard
@onready var enemy_board: PlayerBoard = $EnemyBoard
@onready var column_selector: Sprite2D = $ColumnSelector
@onready var rolled_die: TextureRect = $RolledDie

const texture_map = {
	1: preload("res://assets/one.png"),
	2: preload("res://assets/two.png"),
	3: preload("res://assets/three.png"),
	4: preload("res://assets/four.png"),
	5: preload("res://assets/five.png"),
	6: preload("res://assets/six.png"),
}

func set_column_selector_visible(visible: bool):
	column_selector.set_visible(visible)

func reset_boards():
	player_board.reset_board()
	enemy_board.reset_board()

func roll_die() -> int:
	var value = randi_range(1, 6)
	rolled_die.texture = texture_map[value]
	return value

func place_die(is_player: bool, column_index: int, value: int) -> bool:
	var own_board = player_board if is_player else enemy_board
	var opp_board = enemy_board if is_player else player_board

	if own_board.can_place(column_index):
		own_board.place_die(column_index, value)
		opp_board.remove_dice_with_value(column_index, value)
		return true
	return false

func is_game_over() -> bool:
	return player_board.is_full() or enemy_board.is_full()

func get_winner() -> String:
	var player_score = player_board.get_total_score()
	var enemy_score = enemy_board.get_total_score()
	if player_score > enemy_score:
		return "Player"
	elif enemy_score > player_score:
		return "Enemy"
	else:
		return "Draw"

func get_scores() -> Dictionary:
	return {
		"player": player_board.get_total_score(),
		"enemy": enemy_board.get_total_score()
	}
