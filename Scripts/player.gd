extends Area2D

class_name Player

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var raycasts: Raycasts = $Raycasts
@onready var bomb_placement_system: BombPlacementSystem = $BombPlacementSystem
@onready var power_up_system: Node = $PowerUpSystem

@export var movement_speed: float = 75

var max_bombs_at_once = 1
var movement: Vector2 = Vector2.ZERO

func _process(delta: float) -> void:
	var collisions = raycasts.check_collisions()
	if collisions.has(movement):
		return
	position += movement * delta * movement_speed

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("place_bomb"):
		bomb_placement_system.place_bomb()

	if Input.is_action_pressed("right"):
		movement = Vector2.RIGHT
		animated_sprite_2d.play("walk_right")
	elif Input.is_action_pressed("left"):
		movement = Vector2.LEFT
		animated_sprite_2d.play("walk_left")
	elif Input.is_action_pressed("up"):
		movement = Vector2.UP
		animated_sprite_2d.play("walk_up")
	elif Input.is_action_pressed("down"):
		movement = Vector2.DOWN
		animated_sprite_2d.play("walk_down")
	else:
		movement = Vector2.ZERO
		animated_sprite_2d.stop()

func die():
	if power_up_system.is_invincible:
		return
	animated_sprite_2d.play("die")
	movement = Vector2.ZERO
	set_process_input(false)
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://GameOver.tscn")

func _on_area_entered(area: Area2D) -> void:
	if area is PowerUp:
		power_up_system.enable_power_up((area as PowerUp).type)
		area.queue_free()

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "die":
		queue_free()
