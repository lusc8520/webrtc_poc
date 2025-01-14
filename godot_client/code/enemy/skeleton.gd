class_name Skeleton
extends CharacterBody2D

@export var agent: NavigationAgent2D
@export var target: Node2D
@export var navUpdateTimer: Timer
@export var aimController: Node2D
@export var hand: Node2D
@export var animSprite: AnimatedSprite2D
@export var handWrapper: Node2D
@export var hpBar: ProgressBar
@export var hurtBox: Hurtbox
@export var hitBox: Hitbox
@export var hurtSound: AudioStream

signal onDie()

var isDying: bool

var state: EnemyState:
	set(newState):
		if (state == null || state == newState):
			return
		state.leaveState(self)
		newState.enterState(self)
		state = newState

var flip: bool:
	set(newFlip):
		if (flip == newFlip):
			return
		flip = newFlip
		animSprite.flip_h = newFlip
		hand.position.x = 8 if newFlip else -8
		hand.scale.y = -1 if newFlip else 1

const SPEED:= 80

var physicsFunc: Callable = Util.doNothing

func _ready() -> void:
	hitBox.area_entered.connect(func (hurtbox: Hurtbox) -> void:
		hurtbox.hurt()
		ParticleHandler.instance.spawnParticle(hurtbox.global_position)
		)
	hurtBox.onHurt.connect(func () -> void:
		AudioHandler.instance.playAudio(hurtSound, global_position, randf_range(0.9, 1.25) )
		)
	navUpdateTimer.start()
	navUpdateTimer.timeout.connect(func () -> void:
		agent.target_position = target.position
		)
	state = EnemyState.enemyIdle
	agent.target_position = target.position
	get_tree().create_timer(0.25).timeout.connect(func () -> void:
		if (isDying):
			return
		animSprite.play("run")
		physicsFunc = follow
		)
	agent.target_reached.connect(func () -> void:
		navUpdateTimer.stop()
		physicsFunc = notFollow
		animSprite.play("idle")
		)

signal hpChanged(amount: int)

var hp := 100:
	set(newHp):
		newHp = clampi(newHp, 0, 100)
		if (hp == newHp):
			return
		hp = newHp
		hpBar.value = newHp
		hpChanged.emit(newHp)
		if (hp <= 0):
			die()

func hurt() -> void:
	if (isDying):
		return
	hp = hp - 25

func die() -> void:
	isDying = true
	onDie.emit()
	physicsFunc = Util.doNothing
	animSprite.play("die")
	handWrapper.visible = false
	hpBar.visible = false
	animSprite.position.y = -32
	animSprite.animation_finished.connect(func () -> void:
		get_tree().create_timer(3).timeout.connect(func () -> void:
			var t := create_tween()
			t.tween_property(self, "modulate", Color.TRANSPARENT, 0.5)
			t.finished.connect(queue_free)
			)
		)

func _physics_process(_delta: float) -> void:
	physicsFunc.call()

func _process(_delta: float) -> void:
	if (isDying):
		return
	var aimDir := aimController.global_position.direction_to(target.global_position + Vector2(0, -10) ).angle()
	var handDir := hand.global_position.direction_to(target.global_position + + Vector2(0, -10)).angle()
	aimController.rotation = aimDir
	hand.rotation = handDir
	flip = absf(aimDir) > PI / 2
	
signal onAttack()

func attack() -> void:
	if (position.distance_to(target.position) > 50):
		return
	_attack()
	
func _attack() -> void:
	onAttack.emit()
	var t := create_tween()
	t.tween_property(handWrapper, "position:x", 20, 0.15)
	t.tween_callback(hitBox.activateForOneFrame)
	t.tween_property(handWrapper, "position:x", 0, 0.15)

func forceAttack() -> void:
	_attack()
	

func follow() -> void:
	var nextPos := agent.get_next_path_position()
	var dir := self.position.direction_to(nextPos) * SPEED
	velocity = dir
	move_and_slide()
	
func notFollow() -> void:
	if (position.distance_to(target.position) > 40):
		agent.target_position = target.position
		navUpdateTimer.start()
		physicsFunc = follow
		animSprite.play("run")

class EnemyState:
	
	static var enemyIdle := EnemyIdle.new()
	static var enemyFollow := EnemyFollow.new()
	
	func enterState(_skeleton: Skeleton) -> void:
		pass
	
	func process(_skeleton: Skeleton) -> void:
		pass
		
	func leaveState(_skeleton: Skeleton) -> void:
		pass

class EnemyIdle extends EnemyState:
	
	func enterState(_skeleton: Skeleton) -> void:
		pass
	
	func process(_skeleton: Skeleton) -> void:
		pass
		
	func leaveState(_skeleton: Skeleton) -> void:
		pass
		
class EnemyFollow extends EnemyState:
	
	func enterState(_skeleton: Skeleton) -> void:
		pass
	
	func process(_skeleton: Skeleton) -> void:
		pass
		
	func leaveState(_skeleton: Skeleton) -> void:
		pass
