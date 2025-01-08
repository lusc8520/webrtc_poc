class_name ServerConnection
extends Node

static var instance: ServerConnection

var connection := WebSocketPeer.new()
var processFunc: Callable = Util.doNothing
var localPeer := LocalPeer.new()

var state := WebSocketPeer.STATE_CLOSED:
	set(value):
		if state == value:
			return
		state = value
		match value:
			WebSocketPeer.STATE_CONNECTING:
				print("connecting...")
			WebSocketPeer.STATE_OPEN:
				onOpen()
			WebSocketPeer.STATE_CLOSED:
				onClose()

func _ready() -> void:
	instance = self
	startConnection()
	
func startConnection() -> void:
	var url := "ws://127.0.0.1:80/" if OS.is_debug_build() else "server url here.."
	var error := connection.connect_to_url(url)
	if error != OK:
		push_error(error)
		return
	get_tree().create_timer(10).timeout.connect(func () -> void:
		if (state == WebSocketPeer.STATE_CONNECTING):
			print("timeout!")
			connection.close()
		)
	
func _physics_process(_delta: float) -> void:
	connection.poll()
	state = connection.get_ready_state()
	processFunc.call()
	
func readPackets() -> void:
	var count := connection.get_available_packet_count()
	for i in count:
		var dict: Dictionary = JSON.parse_string(connection.get_packet().get_string_from_ascii())
		var type: PacketType = dict.get("pType")
		var callback: Callable = callbacks.get(type)
		callback.call(dict)

func sendPacket(type: PacketType, dict: Dictionary = {}) -> void:
	dict.set("pType", type)
	connection.send_text(JSON.stringify(dict))

func onOpen() -> void:
	print("websocket open")
	processFunc = readPackets

func onClose() -> void:
	var closeCode := connection.get_close_code()
	var reason := connection.get_close_reason()
	print("websocket closed! code:" + str(closeCode) + " reason: " + reason)
	processFunc = Util.doNothing
	
enum PacketType { JOINED = 0, SDP = 1, ICE = 2 }
	
var callbacks: Dictionary[PacketType, Callable] = {
	PacketType.JOINED: (func(dict: Dictionary) -> void:
		var ids: Array = dict.get("ids")
		localPeer.initialize(ids)
		add_child(localPeer)
		),
	PacketType.SDP: (func(dict: Dictionary) -> void:
		localPeer.handleSdp(dict)
		),
	PacketType.ICE: (func(dict: Dictionary) -> void:
		localPeer.handleIce(dict)
		),
}
