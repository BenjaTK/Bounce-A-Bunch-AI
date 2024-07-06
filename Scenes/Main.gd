extends Node2D

onready var timer = get_node("DelayTimer")

var obstaclesPaths := ["res://Obstacles/HomingMissile.tscn",
						"res://Obstacles/Laser.tscn",
						"res://Obstacles/Spike.tscn"]
var queue = []

onready var player = $Player


func _ready() -> void:
	timer.start()


func _process(delta: float) -> void:
	$UI/HUD/Points/Label2.text = str($AiEnvironment.score)


func _random_obstacle():
	if $Obstacles.get_child_count() == 5:
		return

	randomize()
	if queue.empty():
		obstaclesPaths.shuffle()
		queue = obstaclesPaths.duplicate()
	_spawn_obstacle(load(queue.pop_front()))


func _on_DelayTimer_timeout():
	_random_obstacle()
	timer.start()


func _spawn_obstacle(obstacle):
	var obs = obstacle.instance()
	$Obstacles.add_child(obs)


func reset_game() -> void:
	Globals.points = 0
	$Player.global_position = Vector2(144, 260)
	$Player.hurtbox.hp = $Player.hurtbox.maxHp
	for child in $Obstacles.get_children():
		child.queue_free()
	$Player.vel = Vector2.ZERO
	$CoinSpawner._random_pos()
	timer.stop()
	timer.start()
	timer.wait_time = 3
	$CoinSpawner.coinsCollected = 0
