class_name NameChanger
extends CanvasLayer

@export var button: Button
@export var lineEdit: LineEdit
@export var lineEditContainer: Control
@export var okButton: Button
@export var cancelButton : Button
@export var portraitLabel: Label
@export var audioOptions: Control

static var instance: NameChanger

signal nameChanged(name: String)

var playerName: String:
	set(val):
		if (playerName == val):
			return
		playerName = val
		nameChanged.emit(val)
		lineEdit.text = val
		portraitLabel.text = val
		InputHandler.instance.player.nameLabel.text = val

func _ready() -> void:
	var inputHandler := InputHandler.instance
	button.mouse_entered.connect(func () -> void:
		inputHandler.handleClick = false
		)
	button.mouse_exited.connect(func () -> void:
		inputHandler.handleClick = true
		)
	button.pressed.connect(func () -> void:
		var vis := !lineEditContainer.visible
		lineEditContainer.visible = vis
		if (vis):
			audioOptions.visible = false
			lineEdit.grab_focus()
			inputHandler.player.inputDir = Vector2.ZERO
		inputHandler.handleInput = !vis
		)
	
	cancelButton.pressed.connect(func () -> void:
		lineEditContainer.visible = false
		inputHandler.handleInput = true
		lineEdit.text = playerName
		)
	lineEdit.text_submitted.connect(func (t: String) -> void:
		playerName = t
		lineEditContainer.visible = false
		inputHandler.handleInput = true
		)
	okButton.pressed.connect(func () -> void:
		playerName = lineEdit.text
		lineEditContainer.visible = false
		inputHandler.handleInput = true
		)
	nameChanged.connect( func (n: String) -> void:
		print("name changed " + n)
		)
	instance = self
