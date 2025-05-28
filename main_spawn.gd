extends Node2D

@export var enemy_scene: PackedScene
@export var max_enemies: int = 4
@export var max_total_spawned: int = 10


@export var spawn_points: Array[Vector2] = []
@export var spawn_markers: Array[NodePath] = []
@export var exit_door_path: NodePath

var enemies: Array[Enemy] = []
var total_spawned: int = 0
var exit_door: Node2D

func _ready():
	if spawn_markers.size() > 0:
		for path in spawn_markers:
			var marker = get_node(path)
			if marker and marker is Marker2D:
				spawn_points.append(marker.global_position)

	if exit_door_path != NodePath():
		exit_door = get_node(exit_door_path)
		exit_door.visible = false
		exit_door.connect("door_entered", Callable(self, "_on_door_entered"))

	spawn_initial_enemies()

func spawn_initial_enemies():
	for i in range(min(max_enemies, spawn_points.size(), max_total_spawned)):
		spawn_enemy()

func spawn_enemy():
	if total_spawned >= max_total_spawned:
		return

	if spawn_points.is_empty():
		return

	var enemy = enemy_scene.instantiate() as Enemy
	enemy.position = get_random_spawn_position()
	add_child(enemy)
	enemies.append(enemy)
	total_spawned += 1

	enemy.connect("tree_exited", Callable(self, "_on_enemy_removed").bind(enemy))

func get_random_spawn_position() -> Vector2:
	return spawn_points[randi() % spawn_points.size()]

func _on_enemy_removed(removed_enemy: Enemy):
	enemies.erase(removed_enemy)

	if enemies.size() < max_enemies and total_spawned < max_total_spawned:
		spawn_enemy()

	if total_spawned == max_total_spawned and enemies.is_empty():
		show_exit()

func show_exit():
	if exit_door:
		exit_door.call("show_door")


func _on_door_body_entered(body: Player) -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn") # Replace with function body.
