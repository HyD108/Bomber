extends Node

class_name PowerUpSystem

var player: Player

@onready var animated_sprite_2d: AnimatedSprite2D = $"../AnimatedSprite2D"
@onready var bomb_placement_system: BombPlacementSystem = $"../BombPlacementSystem"
@onready var speed_up_timer: Timer = $SpeedUpTimer
@onready var invincibility_timer: Timer = $InvinvibilityTime

const SPEED_MULTIPLIER = 2

var is_invincible := false

func _ready() -> void:
	player = get_parent()

func enable_power_up(power_up_type: Utils.PowerUpType):
	match power_up_type:
		Utils.PowerUpType.BOMB_UP:
			player.max_bombs_at_once += 1
		Utils.PowerUpType.FIRE_UP:
			bomb_placement_system.explosion_size += 0.5
		Utils.PowerUpType.SPEED_UP:
			player.movement_speed *= SPEED_MULTIPLIER
			animated_sprite_2d.speed_scale = 3
			speed_up_timer.start()
		Utils.PowerUpType.WALL_PASS:
			var raycast_nodes = get_tree().get_nodes_in_group("raycasts") as Array[RayCast2D]
			for raycast in raycast_nodes:
				raycast.set_collision_mask_value(3, false)
		Utils.PowerUpType.INVINCIBILITY:
			is_invincible = true
			player.modulate = Color(1, 1, 1, 0.5) 
			invincibility_timer.start()

func _on_speed_up_timer_timeout() -> void:
	player.movement_speed /= SPEED_MULTIPLIER
	animated_sprite_2d.speed_scale = 1


func _on_invinvibility_time_timeout() -> void:
	is_invincible = false
	player.modulate = Color(1, 1, 1, 1)
