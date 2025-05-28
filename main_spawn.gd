extends Node2D

@export var enemy_scene: PackedScene
@export var max_enemies: int = 4

@export var spawn_points: Array[Vector2] = []

@export var spawn_markers: Array[NodePath] = []

var enemies: Array[Enemy] = []

func _ready():
	if spawn_markers.size() > 0:
		for path in spawn_markers:
			var marker = get_node(path)
			if marker and marker is Marker2D:
				spawn_points.append(marker.global_position)

	spawn_initial_enemies()

func spawn_initial_enemies():
	for i in range(min(max_enemies, spawn_points.size())):
		spawn_enemy()

func spawn_enemy():
	if spawn_points.is_empty():
		return

	var enemy = enemy_scene.instantiate() as Enemy
	var spawn_pos = get_random_spawn_position()
	enemy.position = spawn_pos
	add_child(enemy)
	enemies.append(enemy)

	enemy.connect("tree_exited", Callable(self, "_on_enemy_removed").bind(enemy))

func get_random_spawn_position() -> Vector2:
	return spawn_points[randi() % spawn_points.size()]

func _on_enemy_removed(removed_enemy: Enemy):
	enemies.erase(removed_enemy)

	if enemies.size() < max_enemies:
		spawn_enemy()
