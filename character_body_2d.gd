
extends CharacterBody2D

const SPEED = 800.0
const GROUND_ACCELERATION = 2500.0
const AIR_ACCELERATION = 1600.0
const GROUND_FRICTION = 5000
const AIR_FRICTION = 150.0
const JUMP_VELOCITY = -900.0

@onready var hurtbox: Area2D = $hurtbox
@onready var iframe_timer: Timer = $IFrameTimer

var is_invincible: bool = false
var fired_last: bool = false

var current_checkpoint: Node2D = null

const BULLET_SCENE = preload("res://bullet.tscn")
@onready var muzzle = $pivot/muzzle


func _ready() -> void:
	iframe_timer.timeout.connect(_on_iframe_timer_timeout)



func _physics_process(delta: float) -> void:

	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_pressed('checkpoint') and current_checkpoint != null:
		position = current_checkpoint.global_position
		velocity.x = 0
		velocity.y = 0

	# Horizontal movement
	var direction := Input.get_axis("left", "right")

	if direction != 0:
		var acceleration = GROUND_ACCELERATION if is_on_floor() else AIR_ACCELERATION

		# Apply acceleration instead of directly setting velocity
		if sign(direction) != sign(velocity.x) or abs(velocity.x) < SPEED:
			velocity.x += direction * acceleration * delta

	else:
		# Friction when no input is applied
		var friction = GROUND_FRICTION if is_on_floor() else AIR_FRICTION
		velocity.x = move_toward(velocity.x, 0, friction * delta)

	# Flip player sprite
	if velocity.x > 0:
		$pivot.scale = Vector2(1, 1)
	elif velocity.x < 0:
		$pivot.scale = Vector2(-1, 1)

	# Shooting (right stick)
	var updown = Input.get_axis("up2", "down2")
	var leftright = Input.get_axis("left2", "right2")

	if abs(updown) < 0.2 and abs(leftright) < 0.2:
		fired_last = false

	elif not fired_last:
		var fireDirection = Vector2(leftright, updown).normalized()

		print("firing")

		var bullet = BULLET_SCENE.instantiate()
		bullet.global_transform = muzzle.global_transform
		bullet.direction = fireDirection
		get_tree().current_scene.add_child(bullet)

		fired_last = true

	move_and_slide()


func take_damage(damage_amount):
	print("damage taken: ", damage_amount)
	start_iframes()


func start_iframes() -> void:
	is_invincible = true
	iframe_timer.start()

	modulate.a = 0.5


func _on_iframe_timer_timeout() -> void:
	is_invincible = false
	modulate.a = 1.0

	var overlapping_bodies = hurtbox.get_overlapping_bodies()

	if overlapping_bodies.size() > 0:
		var enemy = overlapping_bodies[0]
		_on_area_2d_body_entered(enemy)


func _on_area_2d_body_entered(body: Node2D) -> void:

	if is_invincible:
		return

	var damage_amount = 1

	if "damage" in body:
		damage_amount = body.damage

	take_damage(damage_amount)


func _on_explosion_area_area_entered(area: Area2D) -> void:
	print("we have an explosion within range")

	var relative_pos = (global_position - area.global_position)
	var norm = relative_pos.normalized()
	print('relative pos', relative_pos)
	var distance = relative_pos.x * relative_pos.x + relative_pos.y * relative_pos.y
	var distance_scale = 1/sqrt(distance/5000)
	print(distance_scale)
	if distance_scale > 1:
		distance_scale = 1
	velocity += norm * 1000 * area.explosion_power * distance_scale
	
	

func _on_cp_finder_area_entered(area: Area2D) -> void:
	print('found checkpoint', area)
	current_checkpoint = area
