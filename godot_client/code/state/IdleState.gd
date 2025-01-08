class_name IdleState
extends MovementState

func enterState(player: Player) -> void:
	player.velocity = Vector2.ZERO
	player.animSprite.play("idle", randf_range(0.5, 1.5))

func process(player: Player) -> void:
	if (player.inputDir != Vector2.ZERO):
		player.setState(MovementState.runningState)
