extends CharacterBody2D

signal player_died

@onready var sprite = $AnimatedSprite2D

var speed = 55
var direction = Vector2.ZERO

var is_alive = true


func _physics_process(delta: float) -> void:
	if is_alive:
		move()
		anim()

	pass

func move():
	direction = Input.get_vector("left", "right", "up", "down")

	if direction != Vector2.ZERO:
		velocity = direction * speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed)
	move_and_slide()
	
	pass

func anim():
	
	if direction == Vector2.ZERO:
		sprite.play("idle")
	else:
		if abs(direction.x) > abs(direction.y):
			sprite.play("walk_side")
			if direction.x <0:
				sprite.flip_h = true
			else:
				sprite.flip_h = false
		if abs(direction.y) > abs(direction.x):
			if direction.y < 0:
				sprite.play("walk_up")
			else:
				sprite.play("walk_down")
	
	
	pass


func die():
	
	if is_alive:
		is_alive = false
		sprite.play("death")
		player_died.emit()
		
	pass
