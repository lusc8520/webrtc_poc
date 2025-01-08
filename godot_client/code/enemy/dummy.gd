class_name Dummy
extends Node2D

@export var hurtbox: Hurtbox
@export var animSprite: AnimatedSprite2D
@export var hitSound: AudioStream

func _ready() -> void:
	hurtbox.onHurt.connect(onHurt)
	
func onHurt() -> void:
	animSprite.stop()
	animSprite.play("hurt" + str(randi_range(1, 3)))
	animSprite.animation_finished.connect(func () -> void:
		animSprite.play("idle")
		)
	AudioHandler.instance.playAudio(hitSound, global_position, randf_range(0.5, 1))
	
	
