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
var is_dead: bool = false

# --- Nodes ---
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var attack_area: Area2D = $AttackArea

func _ready() -> void:
	add_to_group("Players")

	# Disable attack area initially
	if attack_area:
		attack_area.monitoring = false
		attack_area.body_entered.connect(_on_attack_area_body_entered)


func _physics_process(delta: float) -> void:
	# Stop all control if dead
	if is_dead:
		return

	# Prevent movement while attacking
	if is_attacking:
		if not animated_sprite.is_playing() or animated_sprite.animation != "attack":
			is_attacking = false
			if attack_area:
				attack_area.monitoring = false
		return

	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Horizontal movement input
	var direction := Input.get_axis("left", "right")

	# Flip sprite based on direction
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	# Crouch detection
	var is_crouching := Input.is_action_pressed("crouch") and is_on_floor()

	# Animation logic
	if is_crouching:
		animated_sprite.play("crouch")
	elif is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")

	# Horizontal velocity
	if direction != 0:
		velocity.x = direction * (CROUCH_SPEED if is_crouching else SPEED)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack") and not is_attacking and not is_dead:
		is_attacking = true
		animated_sprite.play("attack")
		if attack_area:
			attack_area.monitoring = true


# --- Attack handling ---
func _on_attack_area_body_entered(body: Node) -> void:
	if body.is_in_group("Enemies") and body.has_method("take_damage"):
		body.take_damage(20)
		print("Player dealt 20 damage to enemy")


# --- Taking damage ---
func take_damage(amount: int) -> void:
	if is_dead:
		return

	health -= amount
	print("Player health:", health)

	if health <= 0:
		die()


# --- Death handling ---
func die() -> void:
	is_dead = true
	is_attacking = false
	if attack_area:
		attack_area.monitoring = false

	animated_sprite.play("death")

	# Wait for death animation duration
	await get_tree().create_timer(1.0).timeout

	# Reload scene safely
	var scene_path := get_tree().current_scene.scene_file_path
	if scene_path != "":
		get_tree().change_scene_to_file(scene_path)
	else:
		push_error("Cannot reload scene: current scene path is empty")
