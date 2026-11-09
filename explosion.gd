extends Area2D

@export var remain_time: float = 0.2
@export var explosion_power: float = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.start(remain_time)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	queue_free()
