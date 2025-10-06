extends CharacterBody2D

# --- Movement constants ---
const SPEED := 130.0
const JUMP_VELOCITY := -300.0
const GRAVITY := 600.0
const CROUCH_SPEED := 60.0

# --- Health ---
var max_health := 100
var health := max_health

# --- State ---
var is_attacking: bool = false

# --- Nodes ---
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer  # optional
@onready var attack_area: Area2D = $AttackArea  # player attack hitbox

func _ready() -> void:
	add_to_group("Players")
	# Disable attack area initially
	if attack_area:
		attack_area.monitoring = false
		attack_area.body_entered.connect(_on_attack_area_body_entered)

func _physics_process(delta: float) -> void:
	# Prevent movement while attacking
	if is_attacking:
		if not animated_sprite.is_playing():
			is_attacking = false
			if attack_area:
				attack_area.monitoring = false
		return

	# Gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Horizontal input
	var direction := Input.get_axis("left", "right")

	# Flip sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	# Crouch
	var is_crouching := Input.is_action_pressed("crouch") and is_on_floor()

	# Animations
	if is_crouching:
		animated_sprite.play("crouch")
	elif is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")

	# Horizontal movement
	if direction != 0:
		velocity.x = direction * (CROUCH_SPEED if is_crouching else SPEED)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack") and not is_attacking:
		is_attacking = true
		if animated_sprite:
			animated_sprite.play("attack")
		if attack_area:
			attack_area.monitoring = true

# --- Player attack hits enemies ---
func _on_attack_area_body_entered(body: Node) -> void:
	if body.is_in_group("Enemies") and body.has_method("take_damage"):
		body.take_damage(20)  # deal 20 damage
		print("Player dealt 20 damage to enemy")

# --- Take damage ---
func take_damage(amount: int) -> void:
	health -= amount
	print("Player health:", health)
	if health <= 0:
		die()

func die() -> void:
	animated_sprite.play("death")

	# Wait for animation to finish
	await get_tree().create_timer(0.5).timeout

	# Reload current scene safely
	var current_scene = get_tree().change_scene_to_file("res://scenes/restart.tscn")
	if current_scene:
		var path = current_scene.scene_file_path
		if path != "":
			get_tree().change_scene_to_file(path)
		else:
			push_error("Cannot reload scene: scene path is empty")
	else:
		push_error("No current scene found")
