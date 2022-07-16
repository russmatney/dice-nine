extends Node2D
class_name LevelBase

onready var player_start = $PlayerStart
onready var player_spawn_timer = $PlayerSpawnTimer

var enemies = []

# ready #######################################################################

func _ready():
  assert(player_start)
  assert(player_spawn_timer)

  player_spawn_timer.start(0.0)

  enemies = get_tree().get_nodes_in_group("enemies")

  for en in enemies:
    en.connect("death", self, "_on_enemy_death", [en])

  ProgressionState.set_current_level(self)

func _on_enemy_death(en):
  print("parent on enemy death")
  enemies.erase(en)

  if enemies.size() <= 0:
    print("level complete!")
  else:
    print(enemies.size(), " enemies remaining")

# spawn_player #######################################################################

func _on_PlayerSpawnTimer_timeout():
  ProgressionState.spawn_player(player_start)
