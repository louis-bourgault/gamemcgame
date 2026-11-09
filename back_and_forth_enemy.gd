extends "res://enemy.gd"

func update_movement(delta:float):
	if not is_on_floor():
		velocity += get_gravity() * delta

		# Set horizontal velocity
	velocity.x = direction * speed

	# Move and slide handles the collision and movement
	move_and_slide()

	# Check for walls and flip direction
	if is_on_wall():
		flip_direction()

	# Optional: Flip sprite visual based on direction
	if direction != 0:
		sprite.flip_h = direction < 0
