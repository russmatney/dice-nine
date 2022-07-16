extends Node

var player_state = {
  "unlocked_sides": ["one"],
  "health": 3,
  "lives": 3,
}

func _ready():
  pass # Replace with function body.



func unlock_side(side):
  player_state["unlocked_sides"].append(side)
