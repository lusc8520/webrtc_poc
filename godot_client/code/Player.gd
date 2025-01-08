class_name Player
extends CharacterBody2D

const SPEED:= 100

@export var animSprite: AnimatedSprite2D
@export var footstepSound: AudioStream
@export var handSprite: Sprite2D
@export var swordSprite: Sprite2D
@export var handOrigin: Node2D
@export var aimController: Node2D
@export var handWrapper: Node2D
@export var handController: Node2D
@export var swordSound: AudioStream
@export var soundPosition: Node2D
@export var hitbox: Hitbox
@export var nameLabel: Label
@export var hurtBox: Hurtbox
@export var hpBar: ProgressBar

var isAttacking: bool
var inputDir: Vector2:
	set(value):
		if (value == inputDir):
			return
		inputDir = value
		moveAngleChanged.emit(value)

signal moveAngleChanged(vec: Vector2)
signal aimAngleChanged(aim: float)
signal attacked()

## false == face right,
## true == face left
var flip: bool:
	set(value):
		if (value == flip):
			return
		flip = value
		animSprite.flip_h = value
		handSprite.flip_h = !value
		swordSprite.flip_h = !value

var aimAngle: float:
	set(value):
		if (aimAngle == value):
			return
		aimAngle = value
		aimAngleChanged.emit(value)
		handOrigin.rotation = value
		aimController.rotation = value
		flip = absf(value) > PI / 2

var currentState: MovementState = MovementState.idleState

func _ready() -> void:
	setState(MovementState.idleState)
	hitbox.area_entered.connect(func (hurtbox: Hurtbox) -> void:
		ParticleHandler.instance.spawnParticle(hurtbox.global_position)
		)
	animSprite.frame_changed.connect(func () -> void: currentState.onAnimationFrameChanged(self, animSprite.frame))

func _physics_process(_delta: float) -> void:
	currentState.process(self)
	move_and_slide()
	
func setState(newState: MovementState) -> void:
	currentState.leaveState(self)
	newState.enterState(self)
	currentState = newState
	
func attack() -> void:
	if (isAttacking):
		return
	
	attacked.emit()
	var scale := 3
	isAttacking = true
	var soundTween := create_tween()
	soundTween.set_speed_scale(scale)
	soundTween.tween_interval(0.25)
	soundTween.tween_callback(func () -> void:
		AudioHandler.instance.playAudio(swordSound, soundPosition.global_position, randf_range(1.25, 1.5))
	)

	var targetRota := handOrigin.rotation + TAU * (-1 if flip else 1)
	var armRotaTween := create_tween()
	armRotaTween.set_speed_scale(scale)
	armRotaTween.tween_property(handOrigin, "rotation", targetRota, 1)

	var hitTween := create_tween()
	hitTween.set_speed_scale(scale)
	hitTween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	hitTween.tween_interval(0.5)
	hitTween.tween_callback(hitbox.activateForOneFrame)
	

	var handOffsetTween := create_tween()
	handOffsetTween.set_speed_scale(scale)
	handOffsetTween.tween_property(handController, "position:x", -20, 0.5)
	handOffsetTween.tween_property(handController, "position:x", -8, 0.5)

	var aim := lerp_angle(handWrapper.rotation, aimAngle, 1)
	var handRotaTween := create_tween()
	handRotaTween.set_speed_scale(scale)
	handRotaTween.tween_property(handWrapper, "rotation", aim, 0.5)
	handRotaTween.tween_property(handWrapper, "rotation", -PI / 2, 0.5)

	handRotaTween.finished.connect(func () -> void:
		isAttacking = false
	)
