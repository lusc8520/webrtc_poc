class_name Hurtbox
extends Area2D

signal onHurt()
	
func hurt() -> void:
	onHurt.emit()
