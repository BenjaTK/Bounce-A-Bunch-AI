extends Node2D


export var learn: bool = true

var scores = []
var eps_history = []
var average_scores = []
var n_games = 500
var loaded_episode = 0
var i = 0

var last_observation: Array
var last_action: int
var last_position: Vector2
var last_hp
var score = 0
var last_points
var done = true

var ticks = 0

onready var AI = get_parent().get_node("AI")
onready var player = get_parent().get_node("Player")
onready var coin = get_parent().get_node("CoinSpawner/Coin")


# Called when the node enters the scene tree for the first time.
func _ready():
	last_observation = get_observation()

	loaded_episode = int(AI.get_loaded_episode())
	print(AI.get_loaded_episode())

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("save"):
		save_data()


func get_observation():
	var observation = []

	var player_pos: Vector2 = player.position
	var coin_pos: Vector2 = coin.position
	observation.append(normalize(player_pos.x, 288))
	observation.append(normalize(player_pos.y, 288))
	observation.append(normalize(coin_pos.x, 288))
	observation.append(normalize(coin_pos.y, 288))
	var direction_to_coin: Vector2 = player_pos.direction_to(coin_pos)
	observation.append(sign(coin_pos.x - player_pos.x) / 2.0 + 0.5)
	observation.append(direction_to_coin.y / 2.0 + 0.5)

	var spikes = []
	var lasers = []
	var birds = []
	spikes.resize(6)
	lasers.resize(3)
	birds.resize(6)

	var closest_dist = INF
	var closest_obstacle = null
	for obstacle in get_parent().get_node("Obstacles").get_children():
		match obstacle.type:
			"spike":
				spikes[spikes.find(null)] = normalize(obstacle.position.x, 288)
				spikes[spikes.find(null)] = normalize(obstacle.position.y, 288)
			"laser":
				lasers[spikes.find(null)] = normalize(obstacle.position.x, 288)
			"bird":
				birds[spikes.find(null)] = normalize(obstacle.position.x, 288)
				birds[spikes.find(null)] = normalize(obstacle.position.y, 288)

		var dist = player.position.distance_squared_to(obstacle.position)
		if dist < closest_dist:
			closest_dist = dist
			closest_obstacle = obstacle

	for arr in [spikes, lasers, birds]:
		for i in arr.size():
			if arr[i] == null:
				arr[i] = 0

	observation.append_array(spikes)
	observation.append_array(lasers)
	observation.append_array(birds)
	if is_instance_valid(closest_obstacle):
		var dir_to_closest_obstacle = player.position.direction_to(closest_obstacle.position)
		observation.append(dir_to_closest_obstacle.x / 2.0 + 0.5)
		observation.append(dir_to_closest_obstacle.y / 2.0 + 0.5)
	else:
		observation.append(0.5)
		observation.append(0.5)

	return observation

func normalize(n, max_n):
	return clamp(n, 0, max_n) / max_n


func average(arr):
	var sum = 0
	for a in arr:
		sum += a
	return sum / arr.size()


# Called every frame. 'delta' is the elapsed time since the previous frame.
var _tick_timer = 0
func _process(delta):
	if done:
		var avg_score = 0

		# Track stuff
		if i != 0:
			scores.append(score)
			eps_history.append(AI.get_epsilon())
			avg_score = average(scores.slice(scores.size() - 100, scores.size(), 1, false))
			average_scores.append(avg_score)
			prints("Epsiode", i + loaded_episode, "score %.2f" % score, "average score", avg_score,
				"epsilon", AI.get_epsilon(), Time.get_datetime_string_from_system(false, true))

			if i % 5 == 0:
				save_checkpoint()
		# Reset
		score = 0
		last_hp = player.hurtbox.maxHp
		done = false
		last_observation = get_observation()
		last_action = player.dir
		last_points = 0
		last_position = player.position
		ticks = 0
		get_parent().reset_game()

		i += 1
		return
	else:
		move_player()
		ticks+=1


func move_player():

	var action = AI.get_action(last_observation)

	player.dir = action - 1

	var observation = get_observation()

	done = player.hurtbox.hp <= 0


	var reward = 0
	if done: # Morimos
		reward = -100
	elif last_points < Globals.points:
		reward = 15
		last_points = Globals.points
	elif player.hurtbox.hp < last_hp:
		reward = -10
		last_hp = player.hurtbox.hp
	else:
		# Comparar distancia a moneda.
		var old_dist_to_coin = abs(last_position.x - coin.position.x)
		var new_dist_to_coin = abs(player.position.x - coin.position.x)
		if new_dist_to_coin < old_dist_to_coin:
			reward = 0.1
		else:
			reward = -0.05

		# Evitar que se quede en los bordes.
		if player.position.x < 16.0 or player.position.x > 272.0:
			reward -= 0.04

	last_position = player.position

	score += reward

	AI.store_transition(last_observation, action, reward, observation, done)
	if learn:
		AI.learn()
	last_observation = observation


func save_data() -> void:
	var file = File.new()

	var path = "res://data/data %s.csv" % Time.get_datetime_string_from_system(false, true).replace(":", "_")

	# Compile the data
	var text = "Episode, Score, Average Score, Epsilon"
	for i in range(0, scores.size()):
		var variables = [
			i, scores[i], average_scores[i], eps_history[i]
		]
		text += "%d, %f, %f, %f\n" % variables

	# Save to file
	file.open(path, file.WRITE)
	assert(file.is_open())
	file.store_string(text)
	file.close()
	save_checkpoint()


func save_checkpoint():
	AI.save_checkpoint(i + loaded_episode)
