class_name InputHandler
extends Node

@export var camera: Camera2D
@export var player: Player
@export var aimLine: Line2D
@export var entrance: Area2D

static var instance: InputHandler

var handleClick: bool = true
var handleInput: bool = true

func _ready() -> void:
	instance = self
	player.hitbox.area_entered.connect(func (hurtbox: Hurtbox) -> void:
		hurtbox.hurt()
		)

func _physics_process(_delta: float) -> void:
	if (handleInput):
		player.inputDir = Input.get_vector("left", "right", "up", "down")
		if (handleClick && Input.is_action_just_pressed("hit")):
			player.attack()

func _process(_delta: float) -> void:
	camera.position = player.position
	player.aimAngle = (aimLine.get_global_mouse_position() - aimLine.global_position).angle()
