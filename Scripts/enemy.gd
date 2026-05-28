extends Area2D

var life = 100
var speed = 10
var velocity = Vector2.ZERO

var is_alive = true

@export_category("Loot")
@export_range(0.0, 1.0) var drop_chance: float = 0.25
@export var drop_weapons: Array[PackedScene] = []

@onready var sprite = $AnimatedSprite2D

func _ready() -> void:
	
	
	
	pass


func _physics_process(delta: float) -> void:
	
	if is_alive:
		move(delta)
		anim()
	
	pass


func move(delta):
	
	var player = get_tree().get_first_node_in_group("player")
	if not player: return
	
	var direction = global_position.direction_to(player.global_position)
	
	var push = Vector2.ZERO
	
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy != self:
			if global_position.distance_to(enemy.global_position) < 40:
				push += enemy.global_position.direction_to(global_position)
				
	var final_direction = (direction + push).normalized()
	
	velocity = velocity.lerp(final_direction * speed, 0.1)
	
	global_position += velocity * delta
	
	if global_position.x < player.global_position.x:
		sprite.flip_h = false
	else:
		sprite.flip_h = true
	
	pass


func anim():
	
	
	pass





func die() -> void:
	if not is_alive:
		return

	is_alive = false
	call_deferred("_try_drop_weapon")
	sprite.play("die")
	$CollisionShape2D.queue_free()
	await get_tree().create_timer(1.0).timeout
	queue_free()


func _try_drop_weapon() -> void:
	if drop_weapons.is_empty():
		return
	if randf() > drop_chance:
		return

	var weapon_scene: PackedScene = drop_weapons[randi() % drop_weapons.size()]
	if weapon_scene == null:
		return

	var weapon := weapon_scene.instantiate()
	var drop_pos := global_position
	var parent := get_tree().current_scene
	parent.add_child.call_deferred(weapon)
	weapon.call_deferred("set_global_position", drop_pos)


func _on_area_entered(area: Area2D) -> void:
	
	if area.is_in_group("bullet"):
		
		$AnimationPlayer.play("hit")
		life -= area.damage
		
		area.queue_free()
		
		if life <= 0:
			die()
		
	if area.get_parent().is_in_group("player"):
		die()
		area.get_parent().die()
	
	pass # Replace with function body.
