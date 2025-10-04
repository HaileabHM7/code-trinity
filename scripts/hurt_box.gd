class_name HurtBox
extends Area2D

signal received_damage(damage: int)
@export var health: Health

func _ready() -> void:
	connect("area_entered", _on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area is HitBox:
		health.health -= area.damage
		received_damage.emit(area.damage)
