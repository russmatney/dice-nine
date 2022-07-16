extends Node2D
class_name LevelBase

var enemy_scene = preload("res://src/Enemy.tscn")

onready var player_start = $PlayerStart

var enemies = []
var enemy_starts = []

# ready #######################################################################

func _ready():
  assert(player_start)

  ProgressionState.spawn_player(player_start)

  enemies = get_tree().get_nodes_in_group("enemies")
  for en in enemies:
    en.connect("death", self, "_on_enemy_death", [en])

  enemy_starts = get_tree().get_nodes_in_group("enemy_starts")
  for e_st in enemy_starts:
    spawn_enemy(e_st)

  ProgressionState.set_current_level(self)

### enemy spawn, death ###########################################################

func spawn_enemy(pos:Position2D):
  var enemy = enemy_scene.instance()
  enemies.append(enemy)
  enemy.connect("death", self, "_on_enemy_death", [enemy])
  enemy.position = pos.position
  enemy.available_sides = [pos.initial_side]
  get_tree().get_root().call_deferred("add_child", enemy)

func _on_enemy_death(en):
  print("parent on enemy death")
  enemies.erase(en)

  if enemies.size() <= 0:
    print("level complete...?")
  else:
    print(enemies.size(), " enemies remaining")

# spawn_player #######################################################################

func _on_PlayerSpawnTimer_timeout():
  ProgressionState.spawn_player(player_start)
