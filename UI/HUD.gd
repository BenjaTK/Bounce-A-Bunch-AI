extends Control

onready var heartsContainer = get_node("Hearts")
onready var pointsLabel = get_node("Points/Label")

func _ready():
	Globals.player.hurtbox.connect("health_updated", self, "_change_hearts")

func _process(delta):
	pointsLabel.text = str(Globals.points)

func _change_hearts():
	for c in heartsContainer.get_children():
		if int(c.name) <= Globals.player.hurtbox.hp:
			c.texture = load("res://Assets/Sprites/heart.png")
		else:
			c.texture = load("res://Assets/Sprites/heart_empty.png")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_tree().paused = !get_tree().paused
