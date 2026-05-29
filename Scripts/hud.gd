extends CanvasLayer

@onready var death_label: Label = $death
@onready var finish_label: Label = $finish
@onready var wave_counter: Label = $waveCounter
@onready var reset_button: Button = $Button


func _ready() -> void:
	_hide_all()
	reset_button.pressed.connect(_on_reset_pressed)

	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.player_died.connect(show_death)

	var spawner := get_node_or_null("../EnemySpawner")
	if spawner:
		spawner.all_waves_cleared.connect(_on_all_waves_cleared)
		spawner.wave_started.connect(_on_wave_started)
		_update_wave_counter(0, spawner.waves.size())


func _hide_all() -> void:
	death_label.visible = false
	finish_label.visible = false
	reset_button.visible = false
	wave_counter.visible = true


func show_death() -> void:
	finish_label.visible = false
	death_label.visible = true
	reset_button.visible = true


func show_finish() -> void:
	death_label.visible = false
	finish_label.visible = true
	reset_button.visible = true


func _on_wave_started(current: int, total: int) -> void:
	_update_wave_counter(current, total)


func _update_wave_counter(current: int, total: int) -> void:
	wave_counter.text = "Wave %d/%d" % [current, total]


func _on_all_waves_cleared() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player and player.is_alive:
		show_finish()


func _on_reset_pressed() -> void:
	get_tree().reload_current_scene()
