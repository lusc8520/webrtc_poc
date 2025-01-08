class_name AudioHandler
extends Node2D

static var instance : AudioHandler

var musicPlayer: AudioStreamPlayer

@export var defaultMusic: AudioStream

func _ready() -> void:
	musicPlayer = AudioStreamPlayer.new()
	musicPlayer.volume_db = -25
	add_child(musicPlayer)
	instance = self
	get_tree().create_timer(3).timeout.connect(func () -> void: playMusic(defaultMusic))

func playAudio(stream: AudioStream, globalPos: Vector2, pitch: float = 1, volume: float = 0) -> void:
	var player := AudioStreamPlayer2D.new()
	player.max_distance = 400
	player.stream = stream
	player.pitch_scale = pitch
	if volume != 0:
		player.volume_db = volume
	else:
		player.volume_db = -15
	player.global_position = globalPos
	player.finished.connect(player.queue_free)
	add_child(player)
	player.play()

func playMusic(stream: AudioStream) -> void:
	musicPlayer.stream = stream
	musicPlayer.play()
	
	
