class_name SomeNpc
extends Node

@export var npc: Player
@export var dummy: Dummy

func _ready() -> void:
	npc.nameLabel.text = "npc"
	npc.aimController.visible = false
	npc.hpBar.visible = false
	npc.aimAngle = (dummy.position - npc.position).angle()
	startAttack()
	
func startAttack() -> void:
	var rand := randf_range(0.5, 2)
	var tween := create_tween()
	tween.tween_interval(rand)
	tween.tween_callback(npc.attack)
	tween.tween_callback(self.startAttack)
