extends Node2D

# --- Movement ---
const SPEED := 30.0
var direction: int = 1
var is_attacking: bool = false
var damage: int = 20

# --- Nodes ---
@onready var attack_area: Area2D = $AttackArea
@onready var ray_cast_right: RayCast2D = $AnimatedSprite2D/RayCastRight


@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var area: Area2D = $Area2D
@onready var _hp_progress_bar: ProgressBar = %HPProgressBar
@onready var _animation_player: AnimationPlayer = %AnimationPlayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var ray_cast_left: RayCast2D = $AnimatedSprite2D/RayCastLeft

# --- Constants ---
const DEATH_ANIMATION_NAME := "death"

# --- State ---
var is_dying: bool = false
var max_health: int = 100
var health: int = max_health


func _physics_process(delta: float) -> void:
	check_attack()

func check_attack() -> void:
	if ray_cast_left.is_colliding() or ray_cast_right.is_colliding():
		var from_right = ray_cast_right.is_colliding()

		if from_right:
			animated_sprite.flip_h = false  # face right
		else:
			animated_sprite.flip_h = true
			   # face left

		# Trigger attack if not already attacking
		if not animated_sprite.is_playing() or animated_sprite.animation != "attack":
			animated_sprite.play("attack")
	else:
		# Reset to idle after attack is done
		if animated_sprite.animation == "attack" and not animated_sprite.is_playing():
			animated_sprite.play("idle")


# --- Setup ---
func _ready() -> void:
	add_to_group("Enemies")

	# ✅ Initialize health
	health = max_health
	if _hp_progress_bar:
		_hp_progress_bar.max_value = max_health
		_hp_progress_bar.value = health

	# ✅ Connect signals safely
	if area and not area.is_connected("body_entered", Callable(self, "_on_Area2D_body_entered")):
		area.body_entered.connect(_on_Area2D_body_entered)

	if attack_area and not attack_area.is_connected("body_entered", Callable(self, "_on_attack_area_body_entered")):
		attack_area.body_entered.connect(_on_attack_area_body_entered)


# --- Movement and patrol ---
func _process(delta: float) -> void:
	# ❌ Prevent ALL actions if dying
	if is_dying:
		return

	# Prevent moving while attacking
	if is_attacking:
		if not animated_sprite.is_playing():
			is_attacking = false
		return

	# Patrol logic
	

	# Animate walking
	if not animated_sprite.is_playing():
		animated_sprite.play("walk")


# --- Detect player proximity ---
func _on_Area2D_body_entered(body: Node) -> void:
	if body == null or is_dying:
		return

	if body.is_in_group("Players"):
		is_attacking = true
		if animated_sprite.has_animation("attack"):
			animated_sprite.play("attack")


# --- Attack hit detection ---
func _on_attack_area_body_entered(body: Node) -> void:
	if body == null or is_dying:
		return

	if body.is_in_group("Players") and body.has_method("take_damage"):
		body.take_damage(damage)
		print("💥 Enemy dealt", damage, "damage to player")


# --- Enemy takes damage ---
func take_damage(amount: int) -> void:
	if is_dying:
		return  # No damage if already dying

	health = max(0, health - amount)
	print("Enemy health:", health)

	if _hp_progress_bar:
		_hp_progress_bar.value = health

	# Play hit animation if exists
	if _animation_player and _animation_player.has_animation("hit"):
		_animation_player.play("hit")

	if health <= 0:
		die()


# --- Collision with player (optional) ---
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Players"):
		if body.has_method("die"):
			body.die()


# --- Death sequence ---
func die() -> void:
	# Prevent multiple death calls
	if is_dying:
		return

	is_dying = true
	print("💀 Enemy died! Starting death sequence.")

	# Disable all collision and input
	if collision_shape:
		collision_shape.set_deferred("disabled", true)
	if attack_area:
		attack_area.set_deferred("monitoring", false)
	if area:
		area.set_deferred("monitoring", false)

	# Stop any current animation
	if animated_sprite:
		animated_sprite.stop()

	# Play death animation if it exists
	if animation_player and animation_player.has_animation(DEATH_ANIMATION_NAME):
		var anim_duration := animation_player.get_animation(DEATH_ANIMATION_NAME).length
		animation_player.stop(true)
		animation_player.play(DEATH_ANIMATION_NAME)
		await get_tree().create_timer(anim_duration).timeout
	else:
		print("⚠️ Death animation not found. Removing immediately.")
	get_tree().change_scene_to_file("res://free.tscn")

	# Remove the enemy after animation
	queue_free()
