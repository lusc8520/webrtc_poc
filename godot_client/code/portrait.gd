class_name Portrait
extends Node2D

@export var hpBar: ProgressBar

static var instance: Portrait

signal hpChanged(amount: int)

var hp := 100:
	set(newHp):
		newHp = clampi(newHp, 0, 100)
		if (hp == newHp):
			return
		hp = newHp
		hpBar.value = newHp
		hpChanged.emit(newHp)
		
func _ready() -> void:
	hpBar.max_value = 100
	hpBar.value = 100
	var player := InputHandler.instance.player
	player.hurtBox.onHurt.connect(func () -> void:
		hp = hp - 5
		)
	player.hitbox.area_entered.connect(func (_a: Area2D) -> void:
		hp = hp + 3
		)
	instance = self
