extends Node

enum GameState {
	PLAYER_ROLL,
	PLAYER_PLACE,
	ENEMY_ROLL,
	ENEMY_PLACE,
	CHECK_END,
	GAME_OVER
}

var current_state = GameState.PLAYER_ROLL
var current_die_value = 0
var is_player_turn = true

@onready var board_manager: BoardManager = $"../BoardManager"
@onready var ui_manager = $UIManager        # Optional

func _ready():
	SignalBus.on_column_selected.connect(on_player_column_selected)
	start_game()

func start_game():
	board_manager.reset_boards()
	is_player_turn = true
	change_state(GameState.PLAYER_ROLL)

func change_state(new_state):
	current_state = new_state

	match current_state:
		GameState.PLAYER_ROLL:
			current_die_value = board_manager.roll_die()
			if ui_manager:
				ui_manager.show_die(current_die_value)
				ui_manager.show_turn("Player")
			change_state(GameState.PLAYER_PLACE)

		GameState.PLAYER_PLACE:
			board_manager.set_column_selector_visible(true)
			# Wait for player input — player must call `on_player_column_selected(index)`
			pass

		GameState.ENEMY_ROLL:
			board_manager.set_column_selector_visible(false)
			current_die_value = board_manager.roll_die()
			if ui_manager:
				ui_manager.show_die(current_die_value)
				ui_manager.show_turn("Enemy")
			change_state(GameState.ENEMY_PLACE)

		GameState.ENEMY_PLACE:
			board_manager.set_column_selector_visible(false)
			await get_tree().create_timer(2).timeout
			var column = choose_random_valid_column_for_enemy()
			board_manager.place_die(false, column, current_die_value)
			change_state(GameState.CHECK_END)

		GameState.CHECK_END:
			if board_manager.is_game_over():
				change_state(GameState.GAME_OVER)
			else:
				is_player_turn = !is_player_turn
				if is_player_turn:
					change_state(GameState.PLAYER_ROLL)
				else:
					change_state(GameState.ENEMY_ROLL)

		GameState.GAME_OVER:
			board_manager.set_column_selector_visible(false)
			var winner = board_manager.get_winner()
			if ui_manager:
				ui_manager.show_result(winner)
			print("Game Over! Winner: ", winner)

# This should be triggered externally by column click
func on_player_column_selected(index: int):
	if current_state != GameState.PLAYER_PLACE:
		return
	if board_manager.place_die(true, index, current_die_value):
		change_state(GameState.CHECK_END)
	else:
		push_warning("Did not place die")

# Randomly choose a column for the AI
func choose_random_valid_column_for_enemy() -> int:
	var valid_columns = []
	var enemy_board = board_manager.enemy_board
	for i in range(3):
		if not enemy_board.columns[i].is_full():
			valid_columns.append(i)

	if valid_columns.is_empty():
		return 0  # fallback — shouldn’t happen

	return valid_columns[randi() % valid_columns.size()]
