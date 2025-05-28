extends Area2D

class_name Enemy

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var speed: float = 25.0
@export var direction_intersection_change_chance: float = 0.5
@export var change_direction_timeout: float = 3.0
var current_change_direction_timeout: float = 0.0

var direction: Vector2 = Vector2.LEFT
var tile_map: TileMapLayer

func _ready() -> void:
	tile_map = get_tree().get_first_node_in_group("tilemap")


func _process(delta: float) -> void:
	position += direction * speed * delta
	
	if direction == Vector2.LEFT or direction == Vector2.RIGHT:
		position.y = roundf(position.y / 16) * 16
	elif direction == Vector2.UP or direction == Vector2.DOWN:
		position.x = roundf(position.x / 16) * 16
	
	if roundi(position.x) % 16 == 0 && roundi(position.y) % 16 == 0 && \
		current_change_direction_timeout >= change_direction_timeout && \
		randf() <= direction_intersection_change_chance:
			current_change_direction_timeout = 0
			change_direction_at_intersection(direction)
		
	current_change_direction_timeout += delta
	
func change_direction_at_intersection(current_direction: Vector2):
	direction = calculate_new_direction(current_direction, true)
	
func calculate_new_direction(current_direction: Vector2, prevent_backtracking: bool) -> Vector2:
	var all_directions = [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]
	var possible_directions: Array[Vector2] = []
	
	all_directions.erase(current_direction)
	
	if prevent_backtracking:
		all_directions.erase(-current_direction)
	
	for direction_to_check in all_directions:
		if not is_direction_blocked(direction_to_check):
			possible_directions.append(direction_to_check)
	
	if possible_directions.size() > 0:
		var new_direction = possible_directions[randi_range(0, possible_directions.size() - 1)]
		change_sprite_direction(new_direction)
		return new_direction
	return current_direction

func is_direction_blocked(direction_to_check: Vector2):
	var position_to_check = round(position/16)*16  + direction_to_check*16
	var local_position_to_check = tile_map.to_local(position_to_check)
	var tile_position = tile_map.local_to_map(local_position_to_check)
	var tile_data = tile_map.get_cell_tile_data(tile_position)
	return tile_data != null
	
func _on_area_entered(area: Area2D) -> void:
	if (area is Player):
		(area as Player).die()
	else:
		direction = calculate_new_direction(direction, false)

func _on_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		direction = calculate_new_direction(direction, false)
	

func change_sprite_direction(new_direction: Vector2):
	if [Vector2.LEFT, Vector2.RIGHT].has(new_direction):
		animated_sprite_2d.scale.x = sign(new_direction.x)

func die():
	animated_sprite_2d.play("die")
	set_physics_process(false)
	speed = 0
	direction = Vector2.ZERO
	set_collision_mask_value(1, false)

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "die":
		queue_free()
