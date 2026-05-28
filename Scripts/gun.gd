extends Node2D

@onready var sprite = $Sprite2D
@onready var bullet_marker = $Sprite2D/Bullet_Marker

@export var bullet_scene: PackedScene

@onready var player = get_tree().get_first_node_in_group("player")

enum state {GROUND, HAND}
var actual_state = state.GROUND

@export_category("Gun State")
@export var fire_time = 0.5
@export var bullet_speed = 200.0
@export var damage = 10.0
@export var bullet_size = 1.0

var can_shoot = true

func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if player.is_alive and actual_state == state.HAND:
		aim()
		shoot()
	
	
	pass

func aim():
	look_at(get_global_mouse_position())
	
	if get_global_mouse_position().x < global_position.x:
		sprite.scale.y = -1
	else:
		sprite.scale.y = 1
	
	pass

func shoot():
	
	if Input.is_action_pressed("shoot") and bullet_scene and can_shoot:
		
		can_shoot = false
		$Timer.start(fire_time)
		
		var bullet = bullet_scene.instantiate()
		
		get_tree().current_scene.add_child(bullet)
		
		bullet.global_position = bullet_marker.global_position
		bullet.global_rotation = global_rotation
		
		
		bullet.speed = bullet_speed
		bullet.damage = damage
		bullet.scale = Vector2(1,1) * bullet_size
	
	pass

func grab():
	
	var hand = player.get_node("Hand")
	
	actual_state = state.HAND
	$Area2D.queue_free()
	
	if hand.get_child_count() == 0:
		call_deferred("reparent", hand, true)
		global_position = hand.global_position
	
	elif hand.get_child_count() >= 0:
		
		hand. get_child(0).queue_free()
		call_deferred("reparent", hand, true)
		global_position = hand.global_position
	
	
	
	
	pass
	
	

func _on_area_2d_area_entered(area: Area2D) -> void:
	
	if area.get_parent().is_in_group("player"):
		grab()
		print("peguei")
		
	pass # Replace with function body.


func _on_timer_timeout() -> void:
	
	can_shoot = true
	
	pass # Replace with function body.
