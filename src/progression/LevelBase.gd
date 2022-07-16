extends Node2D
class_name LevelBase

var enemy_scene = preload("res://src/Enemy.tscn")

onready var player_start = $PlayerStart
var portals = []
var upgrades = []

var enemies = []
var enemy_starts = []

signal enemies_cleared

# ready #######################################################################

func _ready():
  assert(player_start)

  portals = get_tree().get_nodes_in_group("portals")
  upgrades = get_tree().get_nodes_in_group("upgrades")

  ProgressionState.spawn_player(player_start)

  enemies = get_tree().get_nodes_in_group("enemies")
  for en in enemies:
    en.connect("death", self, "_on_enemy_death", [en])

  enemy_starts = get_tree().get_nodes_in_group("enemy_starts")
  for e_st in enemy_starts:
    spawn_enemy(e_st)

  ProgressionState.set_current_level(self)

  connect("enemies_cleared", self, "_on_enemies_cleared")

### enemy spawn, death ###########################################################

func spawn_enemy(pos:Position2D):
  var enemy = enemy_scene.instance()
  enemies.append(enemy)
  enemy.connect("death", self, "_on_enemy_death", [enemy])
  enemy.position = pos.position
  var sides = [pos.initial_side]
  sides.append_array(pos.other_sides)
  enemy.available_sides = sides
  get_tree().get_root().call_deferred("add_child", enemy)

func _on_enemy_death(en):
  enemies.erase(en)

  if enemies.size() <= 0:
    emit_signal("enemies_cleared")
  else:
    print(enemies.size(), " enemies remaining")

# _on_enemies_cleared #######################################################################

func _on_enemies_cleared():
  print("enemies cleared!")

# hide/show portals #######################################################################

func hide_portals():
  for p in portals:
    p.visible = false
    p.disabled = true

func show_portals():
  for p in portals:
    p.visible = true
    p.disabled = false
