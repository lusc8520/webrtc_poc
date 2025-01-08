class_name EnemyHandler
extends Node

@export var world: Node2D
@export var enemyScene: PackedScene
@export var spawnPoint: Node2D
@export var player: Player

var count := 0

static var instance: EnemyHandler

signal onSpawn(id: int)
signal onDie(id: int)
signal onAttack(id: int)
signal onHpChanged(id: int, hp: int)

var enemies : Dictionary[int, Skeleton] = {}

func _ready() -> void:
	instance = self
	spawnEnemyDeferred()
	var t := create_tween()
	t.set_loops()
	t.tween_interval(3)
	t.tween_callback(func () -> void:
		if (enemies.size() < 10):
			spawnEnemyDeferred()
		)

func spawnEnemyDeferred() -> void:
	spawnEnemy.call_deferred()

func spawnEnemy() -> void:
	var skeleton : Skeleton = enemyScene.instantiate()
	var id := count
	var attackTimer := Timer.new()
	attackTimer.autostart = true
	attackTimer.timeout.connect(skeleton.attack)
	skeleton.add_child(attackTimer)
	skeleton.target = player
	skeleton.position = spawnPoint.position
	skeleton.hpChanged.connect(func (hp: int) -> void:
		onHpChanged.emit(id, hp)
		)
	skeleton.onDie.connect(func () -> void:
		attackTimer.stop()
		onDie.emit(id)
		enemies.erase(id)
		)
	skeleton.onAttack.connect(func () -> void:
		onAttack.emit(id)
		)
	skeleton.hurtBox.onHurt.connect(skeleton.hurt)
	world.add_child(skeleton)
	onSpawn.emit(id)
	enemies.set(id, skeleton)
	count = count + 1
	
func spawnEnemyRaw() -> Skeleton:
	var skeleton : Skeleton = enemyScene.instantiate()
	skeleton.position = spawnPoint.position
	world.add_child.call_deferred(skeleton)
	return skeleton
	
