class_name AudioOptions
extends Button

@export var container: Control
@export var nameChange: Control
@export var okButton: Button

@export var musicSlider: HSlider
@export var soundEffectSlider: HSlider

func _ready() -> void:
	var audioHandler := AudioHandler.instance
	var inputHandler := InputHandler.instance
	mouse_entered.connect(func () -> void:
		inputHandler.handleClick = false
		)
	mouse_exited.connect(func () -> void:
		inputHandler.handleClick = true
		)
	pressed.connect(func () -> void:
		var vis := !container.visible
		container.visible = vis
		if (vis):
			inputHandler.player.inputDir = Vector2.ZERO
			nameChange.visible = false
		inputHandler.handleInput = !vis
		)
	musicSlider.value_changed.connect(func (val: float) -> void:
		audioHandler.musicScale = val
		)
	soundEffectSlider.value_changed.connect(func (val: float) -> void:
		audioHandler.soundEffectScale = val
		)
	okButton.pressed.connect(func() -> void:
		inputHandler.handleInput = true
		container.visible = false
		)
		
