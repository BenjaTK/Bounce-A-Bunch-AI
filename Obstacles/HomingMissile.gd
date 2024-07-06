extends KinematicBody2D

export var speed := 256
export var force := 0.03
onready var target := get_global_position()
var vel = Vector2.ZERO

var following = true
var type = "bird"

func _ready():
	_spawn()
	$Timer.start()

func _physics_process(delta):
	if following:
		vel = _steer(target)
	move_and_slide(vel)

	target = Globals.player.global_position

func _steer(target):
	var desired = (target - global_position).normalized() * speed
	var steer = desired - vel
	var targetVel = vel + (steer * force)
	return targetVel


func _on_Timer_timeout():
	following = false
	vel = global_position.direction_to(target).normalized() * speed

func _spawn():
	randomize()
	global_position = Vector2(rand_range(-64, 384), rand_range(-64, 0))

func _on_VisibilityNotifier2D_screen_exited():
	if !following:
		queue_free()

