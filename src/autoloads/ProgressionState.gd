extends Node

var player_scene = preload("res://src/Player.tscn")

var player_state = {
  "unlocked_sides": ["one"],
  "locked_sides": ["two", "three", "four", "five", "six"],
  "health": 3,
  "lives": 3,
}

func _ready():
  print("progression state ready")
  pass # Replace with function body.


func spawn_player(player_start):
  var state = ProgressionState.player_state

  var player = player_scene.instance()
  for key in state:
    if key in player:
      player[key] = state[key]

  player.position = player_start.position
  get_tree().get_root().call_deferred("add_child", player)


func unlock_side(side):
  player_state["unlocked_sides"].append(side)

func unlock_next_side():
  var next_side = player_state["locked_sides"].pop_front()
  player_state["unlocked_sides"].append(next_side)
