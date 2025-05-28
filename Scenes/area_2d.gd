extends Area2D

signal door_entered

func _ready():
	visible = false
	monitoring = false
	connect("body_entered", Callable(self, "_on_body_entered"))

func show_door():
	visible = true
	monitoring = true
