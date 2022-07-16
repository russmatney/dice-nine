extends Node2D

onready var player_start = $PlayerStart
onready var player_spawn_timer = $PlayerSpawnTimer

var enemies = []

# ready #######################################################################

func _ready():
  player_spawn_timer.start(0.0)

  enemies = get_tree().get_nodes_in_group("enemies")

  for en in enemies:
    en.connect("death", self, "_on_enemy_death", [en])

func _on_enemy_death(en):
  enemies.erase(en)

  if enemies.size() <= 0:
    print("level complete!")
  else:
    print(enemies.size(), " enemies remaining")

# spawn_player #######################################################################

func _on_PlayerSpawnTimer_timeout():
  ProgressionState.spawn_player(player_start)

# process #######################################################################

func _process(_delta):
  pass
