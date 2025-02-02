class_name RemoteWebRTCPeer

enum SendType { Reliable, Unreliable }

var id: int
var connection: WebRTCPeerConnection
var reliableChannel : WebRTCDataChannel
var unreliableChannel : WebRTCDataChannel

static var config := {
	"iceServers": [
		{
			"urls": ["stun:stun.l.google.com:19302", "stun:stun1.l.google.com:19302", "stun:stun2.l.google.com:19302", "stun:stun3.l.google.com:19302", "stun:stun4.l.google.com:19302"]
		}
	]
}

signal onConnected()
signal onClosed()
signal onMessage(dict: Dictionary)

var connectionState: WebRTCPeerConnection.ConnectionState = WebRTCPeerConnection.STATE_NEW:
	set(newState):
		if (newState == connectionState):
			return
		connectionState = newState
		match newState:
			WebRTCPeerConnection.STATE_CONNECTED:
				_onConnected()
			WebRTCPeerConnection.STATE_CLOSED:
				onClosed.emit()
			WebRTCPeerConnection.STATE_FAILED:
				close()
			WebRTCPeerConnection.STATE_DISCONNECTED:
				close()
				

func _init(clientId: int) -> void:
	id = clientId
	connection = WebRTCPeerConnection.new()
	connection.initialize(config)
	reliableChannel = connection.create_data_channel("reliable", {"negotiated": true, "id": 1 })
	unreliableChannel = connection.create_data_channel("unreliable", {"negotiated": true, "id": 2, "maxRetransmits": 0 })
	connection.session_description_created.connect(onSessionDescriptionCreated)
	connection.ice_candidate_created.connect(onIceCandidateCreated)
	
func sendPacketRaw(sendType: SendType, dict: Dictionary = {}) -> void:
	var channelToSend := reliableChannel if sendType == SendType.Reliable else unreliableChannel
	if (channelToSend.get_ready_state() == WebRTCDataChannel.STATE_OPEN):
		channelToSend.put_packet(JSON.stringify(dict).to_ascii_buffer())

func sendPacket(type: RemotePlayerHandler.PacketType, sendType: SendType, dict: Dictionary = {}) -> void:
	dict.set("pType", type)
	sendPacketRaw(sendType, dict)

func poll() -> void:
	connection.poll()
	connectionState = connection.get_connection_state()
	
	if (reliableChannel.get_ready_state() == WebRTCDataChannel.STATE_OPEN):
		var packetCount := reliableChannel.get_available_packet_count()
		for c in packetCount:
			var packet := reliableChannel.get_packet()
			var dict : Dictionary = JSON.parse_string(packet.get_string_from_ascii())
			onMessage.emit(dict)
			
	if (unreliableChannel.get_ready_state() == WebRTCDataChannel.STATE_OPEN):
		var packetCount := unreliableChannel.get_available_packet_count()
		for c in packetCount:
			var packet := unreliableChannel.get_packet()
			var dict : Dictionary = JSON.parse_string(packet.get_string_from_ascii())
			onMessage.emit(dict)
			
func createOffer() -> void:
	connection.create_offer()
	
func close() -> void:
	connection.close()

func _onConnected() -> void:
	InputHandler.instance.get_tree().create_timer(0.2).timeout.connect(func () -> void:
		onConnected.emit()
		)

func onSessionDescriptionCreated(type: String, sdp: String) -> void:
	connection.set_local_description(type, sdp)
	ServerConnection.instance.sendPacket(ServerConnection.PacketType.SDP, {"type": type, "sdp" : sdp, "receiverId": self.id})
	
func onIceCandidateCreated(media: String, index: int, iceName: String) -> void:
	ServerConnection.instance.sendPacket(ServerConnection.PacketType.ICE, {"media": media, "index" : index, "name": iceName, "receiverId": self.id})

func addIceCandidateFromDict(dict: Dictionary) -> void:
	connection.add_ice_candidate(dict.get("media"), dict.get("index"), dict.get("name"))
	
func setRemoteDescriptionFromDict(dict: Dictionary) -> void:
	connection.set_remote_description(dict.get("type"), dict.get("sdp"))
		
