extends Node2D

var viewportSize

onready var coin = get_node("Coin")
onready var sprite = get_node("Coin/Sprite")
onready var collectedAudio = get_node("Collected")
var coinsCollected = 0

onready var parent = get_parent()

func _ready():
	sprite.play("rotate")
	viewportSize = get_viewport_rect().size
	_random_pos()

func _random_pos():
	randomize()
	var randomPos = Vector2(rand_range(16, viewportSize.x - 16), rand_range(112, 192))
	if parent.player:
		while abs(randomPos.x - parent.player.position.x) < 32:
			randomPos = Vector2(rand_range(16, viewportSize.x - 16), rand_range(112, 192))
	coin.global_position = randomPos

func _on_Coin_body_entered(body):
	randomize()
	collectedAudio.pitch_scale = rand_range(0.95, 1.05)
	collectedAudio.play()

	Globals.points += 10
	_random_pos()

	coinsCollected += 1
	if coinsCollected >= 3:
		parent.timer.wait_time = clamp(parent.timer.wait_time - 0.1,  0.5, 1000)
		coinsCollected = 0

