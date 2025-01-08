class_name MovementState

static var runningState:= RunningState.new()
static var idleState:= IdleState.new()

func enterState(_player: Player) -> void:
	pass
	
func process(_player: Player) -> void:
	pass
	
func leaveState(_player: Player) -> void:
	pass
	
func onAnimationFrameChanged(_player: Player, _frame: int) -> void:
	pass
