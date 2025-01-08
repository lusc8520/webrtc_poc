class_name LocalPeer
extends Node

var remotePeers: Dictionary[int, RemoteWebRTCPeer] = {}

func initialize(ids: Array) -> void:
	for id: int in ids:
		var peer := getOrCreate(id)
		peer.createOffer()
	var localPlayer := InputHandler.instance.player
	var nameChanger := NameChanger.instance
	var timer := Timer.new()
	var enemyHandler := EnemyHandler.instance
	timer.autostart = true
	timer.wait_time = 1
	timer.timeout.connect(func () -> void:
		var pos := localPlayer.global_position
		broadCast(RemotePlayerHandler.PacketType.SYNC, RemoteWebRTCPeer.SendType.Unreliable,
		 {"posX": roundi(pos.x), "posY": roundi(pos.y) })
		for enemyId in enemyHandler.enemies:
			var e: Skeleton = enemyHandler.enemies.get(enemyId)
			var ePos := e.global_position
			broadCast(RemotePlayerHandler.PacketType.ENEMY_SYNC, RemoteWebRTCPeer.SendType.Unreliable, 
			{"id": enemyId, "posX": roundi(ePos.x), "posY": roundi(ePos.y) })
		)
	localPlayer.add_child(timer)
	localPlayer.attacked.connect(func () -> void:
		broadCast(RemotePlayerHandler.PacketType.HIT, RemoteWebRTCPeer.SendType.Reliable))
	localPlayer.aimAngleChanged.connect(func(aimAngle: float) -> void:
		broadCast(RemotePlayerHandler.PacketType.AIM, RemoteWebRTCPeer.SendType.Unreliable, {"val": rad_to_deg(aimAngle)})
		)
	localPlayer.moveAngleChanged.connect(func (vec: Vector2) -> void:
		if (vec.is_zero_approx()):
			broadCast(RemotePlayerHandler.PacketType.STOP, RemoteWebRTCPeer.SendType.Reliable)
		else:
			broadCast(RemotePlayerHandler.PacketType.MOVE, RemoteWebRTCPeer.SendType.Unreliable, {"val": rad_to_deg(vec.angle())})
		)
	nameChanger.nameChanged.connect(func (n: String) -> void:
		broadCast(RemotePlayerHandler.PacketType.NAME, RemoteWebRTCPeer.SendType.Reliable, {"name" : n})
		)
	enemyHandler.onSpawn.connect(func (id: int) -> void:
		broadCast(RemotePlayerHandler.PacketType.SPAWN_ENEMY, RemoteWebRTCPeer.SendType.Reliable, {"id": id, "hp" : 100})
		)
	enemyHandler.onHpChanged.connect(func (id: int, hp: int) -> void:
		broadCast(RemotePlayerHandler.PacketType.ENEMY_HP, RemoteWebRTCPeer.SendType.Reliable, {"id": id, "hp":hp })
		)
	enemyHandler.onAttack.connect(func (id: int) -> void:
		broadCast(RemotePlayerHandler.PacketType.ENEMY_ATTACK, RemoteWebRTCPeer.SendType.Reliable, {"id": id})
		)
	Portrait.instance.hpChanged.connect(func (hp: int) -> void:
		broadCast(RemotePlayerHandler.PacketType.HP, RemoteWebRTCPeer.SendType.Reliable, {"hp": hp})
		)

func getOrCreate(id: int) -> RemoteWebRTCPeer:
	var existent = remotePeers.get(id)
	if (existent is RemoteWebRTCPeer):
		return existent
	var peer := RemoteWebRTCPeer.new(id)
	remotePeers.set(id, peer)
	peer.onConnected.connect(func() -> void:
		var player: = InputHandler.instance.player
		var pos := InputHandler.instance.player.global_position
		var hp := Portrait.instance.hp
		peer.sendPacket(RemotePlayerHandler.PacketType.SPAWN, RemoteWebRTCPeer.SendType.Reliable, {"posX": roundi(pos.x), "posY": roundi(pos.y), "hp": hp})
		for enemyId in EnemyHandler.instance.enemies:
			var e: Skeleton = EnemyHandler.instance.enemies.get(enemyId)
			var ePos := e.global_position
			peer.sendPacket(RemotePlayerHandler.PacketType.SPAWN_ENEMY, RemoteWebRTCPeer.SendType.Reliable, {"id": enemyId, "hp": e.hp })
			peer.sendPacket(RemotePlayerHandler.PacketType.ENEMY_SYNC, RemoteWebRTCPeer.SendType.Reliable,
			 {"id": enemyId, "posX": roundi(ePos.x), "posY": roundi(ePos.y) })
		)
	peer.onMessage.connect(func (dict: Dictionary) -> void:
		RemotePlayerHandler.instance.handlePacket(peer, dict)
		)
	peer.onClosed.connect(func () -> void:
		remotePeers.erase(id)
		RemotePlayerHandler.instance.despawnPlayer(id)
		)
	return peer		
	
func _process(_delta: float) -> void:
	for id in remotePeers:
		var peer : RemoteWebRTCPeer = remotePeers.get(id)
		peer.poll()
	
func broadCast(type: RemotePlayerHandler.PacketType, sendType: RemoteWebRTCPeer.SendType, dict: Dictionary = {}) -> void:
	dict.set("pType", type)
	for id in remotePeers:
		var client : RemoteWebRTCPeer = remotePeers.get(id)
		client.sendPacketRaw(sendType, dict)	

func handleSdp(dict: Dictionary) -> void:
	var senderId : int = dict.get("senderId")
	var client := getOrCreate(senderId)
	client.setRemoteDescriptionFromDict(dict)
	
func handleIce(dict: Dictionary) -> void:
	var senderId : int = dict.get("senderId")
	var client := getOrCreate(senderId)
	client.addIceCandidateFromDict(dict)
