extends Control

onready var tween = get_node("Tween")
onready var started = false


func _input(event):
	if event.is_action_released("start"):
		if visible && !started:
			started = true
			tween.interpolate_property(self, "modulate", Color("ffffff"), Color("00ffffff"), 0.2, Tween.TRANS_QUINT, Tween.EASE_OUT)
			tween.start()
			yield(get_tree().create_timer(0.2), "timeout")
			visible = false
			get_tree().paused = false
