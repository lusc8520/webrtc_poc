class_name RunningState
extends MovementState

func enterState(player: Player) -> void:
	player.animSprite.play("run", randf_range(0.75, 1.25))
	
func onAnimationFrameChanged(player: Player, frame: int) -> void:
	if frame == 0 || frame == 3:
		AudioHandler.instance.playAudio(player.footstepSound, player.global_position, randf_range(0.4, 0.8), -27)

func process(player: Player) -> void:
	if (player.inputDir == Vector2.ZERO):
		player.setState(MovementState.idleState)
	player.velocity = player.inputDir * player.SPEED
	
