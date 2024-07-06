extends KinematicBody2D

onready var sprite = get_node("Sprite")
onready var hurtbox = get_node("Hurtbox")
onready var jumpAudio = get_node("Jump")
onready var animPlayer = get_node("AnimationPlayer")

var dir = 0
var vel := Vector2.ZERO

export var speed := 192
export var jumpVel := -384.0
export var gravity := 512

func _ready():
	Globals.player = self
	animPlayer.play("RESET")


func _physics_process(delta):
	move_and_slide(vel, Vector2.UP)

#	dir = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	if dir != 0:
		vel.x = lerp(vel.x, dir * speed, 0.1)
		sprite.flip_h = true if dir == 1 else false
	else:
		vel.x = lerp(vel.x, dir * speed, 0.1)

	if is_on_floor():
		sprite.play("on floor")
		vel.y = jumpVel
		randomize()
		jumpAudio.pitch_scale = rand_range(0.9, 1.1)
		jumpAudio.play()
	else:
		sprite.play("jump")
		vel.y += gravity * delta


func kill():
	pass

