extends CharacterBody2D

@export var speed: float = 150.0
@export var direction: int = 1  # 1 for right, -1 for left

@export var damage: int
@export var explosion_interval: float = 2
@export var explosion_power: int = 1
@export var respawn_interval: float = 5
var corporal = true
var soon_respawning = true

var EXPLOSION_SCENE = preload("res://explosion.tscn")

@onready var sprite: Sprite2D = $Sprite2D  # Adjust if using Sprite2D

func _ready() -> void:
	$Label.text = str(explosion_interval)


# Called when the node enters the scene tree for the first time.
func _physics_process(delta: float) -> void:
	if corporal:
		update_movement(delta)
		# Add gravity if your enemy needs it (remove if top-down)
		
		
	elif soon_respawning == true:
		$Label.text = str(snapped($respawn_timer.time_left, 0.1))
		
	else:
		$Label.text = str(snapped($explosion_timer.time_left, 0.1))

func flip_direction() -> void:
	direction *= -1
	
func update_movement(delta):
	pass

func _on_area_2d_area_entered(body: Node2D) -> void:
	if corporal == false:
		return
	
	print("enemy hit by:", body)
	print('explosion interval is:', explosion_interval)
	$explosion_timer.start(explosion_interval)
	$Sprite2D.hide()
	$CollisionShape2D.set_deferred("disabled", true)
	$Area2D.set_deferred("monitorable", false)
	
	$respawn_timer.start(respawn_interval)
	corporal = false
	soon_respawning = false
	
	


func _on_explosion_timer_timeout() -> void:
	var explosion = EXPLOSION_SCENE.instantiate()
	explosion.global_transform = global_transform
	explosion.explosion_power = explosion_power
	get_tree().current_scene.add_child(explosion)
	soon_respawning = true
	



func _on_respawn_timer_timeout() -> void:
	scale.x = 1
	scale.y = 1
	$Sprite2D.show()
	$CollisionShape2D.set_deferred("disabled", false)
	$Area2D.set_deferred("monitorable", true)
	corporal = true
	soon_respawning = false
	$Label.text = str(explosion_interval)
