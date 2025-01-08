class_name Hitbox extends Area2D

func activateForOneFrame() -> void:
	monitoring = true
	# physics tick  is 60fps, so waiting for 1/60seconds + 0.01seconds and then deactivating means activating it for 1 frame
	# should be called from _physics_process to make it more secure
	var timer := get_tree().create_timer(1.0 / 60.0 + 0.01, true, true)
	timer.timeout.connect(deactivate)
	
func deactivate() -> void:
	self.monitoring = false
