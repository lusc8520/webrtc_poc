class_name ParticleHandler
extends Node2D

@export var particleScene: PackedScene

static var instance: ParticleHandler

func _ready() -> void:
	instance = self
	
func spawnParticle(globalPos: Vector2) -> void:
	var particle: GPUParticles2D = particleScene.instantiate()
	particle.global_position = globalPos
	add_child(particle)
	particle.restart()
	particle.finished.connect(particle.queue_free)
	
	

	
