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

func _ready():
	SignalBus.on_column_selected.connect(on_player_column_selected)
	start_game()

func start_game():
	board_manager.reset_boards()
	is_player_turn = true
	set_state(GameState.PLAYER_ROLL)

func set_state(new_state):
	current_state = new_state
	call_deferred("_process_state")

func _process_state():
	match current_state:
		GameState.PLAYER_ROLL:
			current_die_value = board_manager.roll_die()
			set_state(GameState.PLAYER_PLACE)

		GameState.PLAYER_PLACE:
			board_manager.set_column_selector_visible(true)
			# Waits for player to click a column — handled in `on_player_column_selected`
			pass

		GameState.ENEMY_ROLL:
			board_manager.set_column_selector_visible(false)
			current_die_value = board_manager.roll_die()
			set_state(GameState.ENEMY_PLACE)

		GameState.ENEMY_PLACE:
			board_manager.set_column_selector_visible(false)
			await get_tree().create_timer(2).timeout
			var column = choose_random_valid_column_for_enemy()
			board_manager.place_die(false, column, current_die_value)
			set_state(GameState.CHECK_END)

		GameState.CHECK_END:
			if board_manager.is_game_over():
				set_state(GameState.GAME_OVER)
			else:
				is_player_turn = !is_player_turn
				if is_player_turn:
					set_state(GameState.PLAYER_ROLL)
				else:
					set_state(GameState.ENEMY_ROLL)

		GameState.GAME_OVER:
			board_manager.set_column_selector_visible(false)
			var winner = board_manager.get_winner()
			print("Game Over! Winner: ", winner)

func on_player_column_selected(index: int):
	if current_state != GameState.PLAYER_PLACE:
		return
	if board_manager.place_die(true, index, current_die_value):
		set_state(GameState.CHECK_END)
	else:
		push_warning("Did not place die")

func choose_random_valid_column_for_enemy() -> int:
	var valid_columns = []
	var enemy_board = board_manager.enemy_board
	for i in range(3):
		if not enemy_board.columns[i].is_full():
			valid_columns.append(i)
	return valid_columns.pick_random() if valid_columns.size() > 0 else 0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()
	elif event.is_action_pressed("quit"):
		get_tree().quit()
