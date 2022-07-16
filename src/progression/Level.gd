extends Node2D

onready var player_start = $PlayerStart
onready var player_spawn_timer = $PlayerSpawnTimer
onready var player_scene = preload("res://src/Player.tscn")

# ready #######################################################################

func _ready():
  player_spawn_timer.start(1.0)

# spawn_player #######################################################################

func spawn_player():
  var state = ProgressionState.player_state

  var player = player_scene.instance()
  for key in state:
    if key in player:
      player[key] = state[key]

  player.position = player_start.position
  get_tree().get_root().call_deferred("add_child", player)

func _on_PlayerSpawnTimer_timeout():
  spawn_player()
