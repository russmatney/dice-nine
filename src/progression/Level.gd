extends Node2D

onready var player_start = $PlayerStart
onready var player_spawn_timer = $PlayerSpawnTimer

# ready #######################################################################

func _ready():
  player_spawn_timer.start(1.0)

# spawn_player #######################################################################

func _on_PlayerSpawnTimer_timeout():
  ProgressionState.spawn_player(player_start)
