extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const GRAVITY = 600.0  
const CROUCH_SPEED = 60.0   # slower movement while crouching

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var is_attacking: bool = false

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Handle jump (disabled while crouching or attacking)
	if Input.is_action_just_pressed("jump") and is_on_floor() and not Input.is_action_pressed("crouch") and not is_attacking:
		velocity.y = JUMP_VELOCITY

	# Get input direction (-1 = left, 1 = right)
	var direction := Input.get_axis("left", "right")

	# Flip sprite depending on direction
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	# Check if crouching
	var is_crouching = Input.is_action_pressed("crouch") and is_on_floor()

	# Handle attack input
	if Input.is_action_just_pressed("attack") and not is_attacking:
		is_attacking = true
		animated_sprite.play("attack")
		return  # stop other movement logic for this frame

	# If attacking, wait for animation to finish
	if is_attacking:
		if not animated_sprite.is_playing():
			is_attacking = false
		# Prevent movement while attacking
		move_and_slide()
		return

	# Play animations
	if is_crouching:
		animated_sprite.play("crouch")
	elif is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")

	# Apply horizontal movement
	if direction:
		if is_crouching:
			velocity.x = direction * CROUCH_SPEED
		else:
			velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Finally move the character
	move_and_slide()


func _on_hurt_box_area_entered(hitbox) -> void:
	var base_damage = hitbox.damage
	self.hp -= base_damage
	print(hitbox.getparent().name + " 's hit box touched " + name + " 's hurt box and dealt " + str(base_damage))
