extends Area2D

var speed = 60
var damage = 20

func _ready() -> void:
	
	await get_tree().create_timer(3.0).timeout
	queue_free()
	
	pass
	
func _physics_process(delta: float) -> void:
	
	position += transform.x * speed * delta
	
	pass
