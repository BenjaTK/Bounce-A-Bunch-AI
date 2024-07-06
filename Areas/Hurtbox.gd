extends Area2D

signal health_updated

export var maxHp := 3
onready var hp = maxHp

onready var parent = get_parent()
onready var hurtAudio = parent.get_node("Hurt")

func damage(value):
	parent.animPlayer.play("flash")
	GlobalCamera.add_trauma(0.3, 0.4)
	hp = clamp(hp - value, 0, maxHp)
	if hp == 0:
		parent.kill()

	emit_signal("health_updated")

	randomize()
	hurtAudio.pitch_scale = rand_range(0.9, 1.1)
	hurtAudio.play()
