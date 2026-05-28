extends Node2D

@export_category("Inimigo")
@export var enemy_scene: PackedScene

@export_category("Ondas")
@export var waves: Array[WaveConfig] = []

@export_category("Spawn")
@export var auto_start: bool = true

var _spawn_points: Array[Marker2D] = []


func _ready() -> void:
	_collect_spawn_points()
	if auto_start:
		call_deferred("start_spawning")


func start_spawning() -> void:
	if enemy_scene == null:
		push_warning("EnemySpawner: defina enemy_scene no Inspector.")
		return
	if waves.is_empty():
		push_warning("EnemySpawner: nenhuma onda configurada em waves.")
		return
	if _spawn_points.is_empty():
		push_warning("EnemySpawner: nenhum ponto de spawn encontrado em SpawnAreas.")
		return
	_run_waves()


func _collect_spawn_points() -> void:
	_spawn_points.clear()
	var areas_node := get_node_or_null("SpawnAreas")
	if areas_node == null:
		return

	for area in areas_node.get_children():
		for point in area.get_children():
			if point is Marker2D:
				_spawn_points.append(point)


func _run_waves() -> void:
	for wave_index in waves.size():
		var wave := waves[wave_index]
		if wave == null:
			continue

		var wave_enemies: Array = []
		for enemy_index in wave.enemy_count:
			wave_enemies.append(_spawn_enemy())
			var is_last_enemy := enemy_index >= wave.enemy_count - 1
			if not is_last_enemy and wave.spawn_interval > 0.0:
				await get_tree().create_timer(wave.spawn_interval).timeout

		await _wait_until_wave_cleared(wave_enemies)

		var is_last_wave := wave_index >= waves.size() - 1
		if not is_last_wave and wave.delay_after_wave > 0.0:
			await get_tree().create_timer(wave.delay_after_wave).timeout


func _wait_until_wave_cleared(wave_enemies: Array) -> void:
	while _count_alive_enemies(wave_enemies) > 0:
		await get_tree().process_frame


func _count_alive_enemies(wave_enemies: Array) -> int:
	var alive_count := 0
	for enemy in wave_enemies:
		if is_instance_valid(enemy) and enemy.is_alive:
			alive_count += 1
	return alive_count


func _spawn_enemy() -> Node:
	var enemy := enemy_scene.instantiate()
	var spawn_pos := _get_random_spawn_position()
	var parent := get_tree().current_scene
	parent.add_child.call_deferred(enemy)
	enemy.call_deferred("set_global_position", spawn_pos)
	return enemy


func _get_random_spawn_position() -> Vector2:
	var point := _spawn_points[randi() % _spawn_points.size()]
	return point.global_position
