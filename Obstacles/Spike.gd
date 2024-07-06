extends KinematicBody2D

export var gravity := 192
var vel := Vector2.ZERO

var type = "spike"

func _ready():
	_spawn()

func _physics_process(delta):
	vel.y = gravity
	move_and_slide(vel, Vector2.UP)
	if is_on_floor():
		queue_free()
		GlobalCamera.add_trauma(0.2, 0.5)

func _spawn():
	randomize()
	gravity = 0
	global_position = Vector2(Globals.player.global_position.x, -12)
	gravity = 192
