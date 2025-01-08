class_name RemotePlayerHandler
extends Node

@export var world: Node2D
@export var playerScene: PackedScene
@export var portraitList: Control
@export var portraitScene: PackedScene

static var instance: RemotePlayerHandler

var players: Dictionary[int, Player] = {}
var enemies: Dictionary[int, Dictionary] = {}
var portraits: Dictionary[int, Control] = {}

func _ready() -> void:
	instance = self
	
func despawnPlayer(id: int) -> void:
	var ens: Dictionary = enemies.get(id)
	
# 	despawn enemies
	for enemyId: int in ens.keys():
		var skel = ens.get(enemyId)
		if (skel is Skeleton):
			skel.die()
		ens.erase(enemyId)
	enemies.erase(id)
	
# 	despawn player
	var player = players.get(id)
	if (player is Player):
		player.queue_free()
		players.erase(id)

func getOrCreate(id: int) -> Player:
	var existent = players.get(id)
	if (existent is Player):
		return existent
	var player : Player = playerScene.instantiate()
# 	player.aimController.process_mode = PROCESS_MODE_DISABLED
	player.aimController.visible = false
	players.set(id, player)
	enemies.set(id, {})
	return player

func handlePacket(peer: RemoteWebRTCPeer, dict: Dictionary) -> void:
	var player := getOrCreate(peer.id)
	var type: PacketType = dict.get("pType")
	var callable: Callable = callbacks.get(type, fallback)
	callable.call(player, peer, dict)

func fallback(_player: Player, _peer: RemoteWebRTCPeer, dict: Dictionary) -> void:
	print("unknown packet: " + str(dict))
	
enum PacketType {SPAWN, HIT, AIM, MOVE, STOP, SYNC, NAME, SPAWN_ENEMY, HIT_ENEMY, HURT_ENEMY, ENEMY_ATTACK, ENEMY_SYNC, HP, ENEMY_HP}
		
var callbacks: Dictionary[PacketType, Callable] = {
	PacketType.SPAWN: (func (player: Player, _peer: RemoteWebRTCPeer, dict: Dictionary) -> void:
		var posX: int = dict.get("posX")
		var posY: int = dict.get("posY")
		var hp: int = dict.get("hp")
		var pos := Vector2i(posX, posY)
		player.global_position = pos
		player.hpBar.value = hp
		world.add_child(player)
		),
	PacketType.HIT: (func (player: Player, _peer: RemoteWebRTCPeer, _dict: Dictionary) -> void:
		player.attack()
		),
	PacketType.AIM: (func (player: Player, _peer: RemoteWebRTCPeer,  dict: Dictionary) -> void:
		var val: int = dict.get("val")
		player.aimAngle = deg_to_rad(val)
		),
	PacketType.MOVE: (func (player: Player, _peer: RemoteWebRTCPeer,  dict: Dictionary) -> void:
		var val: int = dict.get("val")
		player.inputDir = Vector2.from_angle(deg_to_rad(val))
		),
	PacketType.STOP: (func (player: Player, _peer: RemoteWebRTCPeer,  _dict: Dictionary) -> void:
		player.inputDir = Vector2.ZERO
		),
	PacketType.SYNC:(func (player: Player, _peer: RemoteWebRTCPeer,  dict: Dictionary) -> void:
		var posX: int = dict.get("posX")
		var posY: int = dict.get("posY")
		var pos := Vector2i(posX, posY)
		if (player.global_position.distance_to(pos) > 20):
			player.global_position = pos
		),
	PacketType.NAME: (func (player: Player, _peer: RemoteWebRTCPeer,  dict: Dictionary) -> void: 
		var playerName: String = dict.get("name")
		player.nameLabel.text = playerName
		),
	PacketType.SPAWN_ENEMY: (func (player: Player, peer: RemoteWebRTCPeer,  dict: Dictionary) -> void:
		var skel := EnemyHandler.instance.spawnEnemyRaw()
		var id : int = dict.get("id")
		var hp: int = dict.get("hp")
		skel.target = player
		skel.hurtBox.onHurt.connect(func () -> void:
			peer.sendPacket(PacketType.HIT_ENEMY, RemoteWebRTCPeer.SendType.Reliable, {"id": id})
			)
		var ens: Dictionary = enemies.get(peer.id)
		ens.set(id, skel)
		skel.onDie.connect(func () -> void:
			ens.erase(id)
			)
		skel.hp = hp
		),
	PacketType.HIT_ENEMY: (func (_player: Player, _peer: RemoteWebRTCPeer, dict: Dictionary) -> void:
		var id: int = dict.get("id")
		var enemy = EnemyHandler.instance.enemies.get(id)
		if (enemy is Skeleton):
			enemy.hurt()
		),
	PacketType.ENEMY_ATTACK: (func (_player: Player, peer: RemoteWebRTCPeer, dict: Dictionary) -> void:
		var id: int = dict.get("id")
		var ens: Dictionary = enemies.get(peer.id)
		var en = ens.get(id)
		if (en is Skeleton):
			en.forceAttack()
		),
	PacketType.ENEMY_SYNC: (func (_player: Player, peer: RemoteWebRTCPeer, dict: Dictionary) -> void:
		var id: int = dict.get("id")
		var ens: Dictionary = enemies.get(peer.id)
		var en = ens.get(id)
		if (en is Skeleton):
			var posX: int = dict.get("posX")
			var posY: int = dict.get("posY")
			var pos := Vector2i(posX, posY)
			if (en.global_position.distance_to(pos) > 20):
				en.global_position = pos
		),
	PacketType.HP: (func (player: Player, _peer: RemoteWebRTCPeer, dict: Dictionary) -> void:
		var hp: int = dict.get("hp")
		player.hpBar.value = hp
		),
	PacketType.ENEMY_HP: (func (_player: Player, peer: RemoteWebRTCPeer, dict: Dictionary) -> void:
		var id: int = dict.get("id")
		var ens: Dictionary = enemies.get(peer.id)
		var en = ens.get(id)
		if (en is Skeleton):
			var hp: int = dict.get("hp")
			en.hp = hp
		)
}	
