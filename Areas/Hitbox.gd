extends Area2D

onready var parent = get_parent()
export var queueFree = true

func _on_Hitbox_area_entered(area):
	if area.parent != parent:
		area.damage(1) #Damage for 1 hp
		if queueFree:
			parent.queue_free()
