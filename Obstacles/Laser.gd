extends Area2D

onready var sprite = get_node("Sprite")
onready var hitboxArea = get_node("Hitbox/Area")
onready var shootAudio = get_node("Shoot")
onready var tween = get_node("Tween")
onready var timer = $Timer

var type = "laser"

func _ready():
	_spawn()
	timer.start()

func _spawn():
	global_position = Vector2(rand_range(12, 275), 304)

func _on_Timer_timeout():
	GlobalCamera.add_trauma(0.2, 0.5)
	hitboxArea.disabled = false
	sprite.visible = true
	shootAudio.play()
	tween.interpolate_property(sprite, "scale", Vector2.ZERO, Vector2.ONE, 0.1, Tween.TRANS_QUINT, Tween.EASE_OUT)
	tween.start()

func _on_Lifetime_timeout():
	queue_free()
