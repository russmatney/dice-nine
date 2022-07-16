extends CanvasLayer
# TODO learn how this should work - using this to get the HUD placement 'right'

var player_scene = preload("res://src/Player.tscn")
var hud_scene = preload("res://src/ui/HUD.tscn")
var hud: Control

var player_state = {
  "unlocked_sides": [],
  "locked_sides": ["one", "two", "three", "four", "five", "six"],
  "health": 1,
  "lives": 3,
  "respawn_side": "none",
}

var player_start
var player
var current_level: LevelBase

### level ####################################################################

func set_current_level(level: LevelBase):
  current_level = level

### ready ##############################################################

func _ready():
  print("progression state ready")


func ensure_hud():
  if not hud:
    hud = get_tree().get_root().find_node("HUD")
    print("found hud in tree?", hud)

    if not hud:
      print("progression state creating hud!")
      hud = hud_scene.instance()
      call_deferred("add_child", hud)

### process ##############################################################

func _process(_delta):
  pass

### unhandled_input ##############################################################

func _unhandled_input(event):
  if event.is_action_pressed("respawn"):
    if is_instance_valid(player):
      player_state["respawn_side"] = player.current_side
      player.kill_for_respawn()
    # TODO do we need to wait?
    # NOTE this allows for life after death
    spawn_player()

### spawn, death, respawn ####################################################

func spawn_player(pos:Position2D = player_start) -> Node:
  player_start = pos
  var state = ProgressionState.player_state

  player = player_scene.instance()
  for key in state:
    if key in player:
      player[key] = state[key]

  player.connect("death", self, "_on_player_death", [player])

  player.position = player_start.position
  get_tree().get_root().call_deferred("add_child", player)

  hud.set_lives(player_state["lives"])
  hud.set_dice(player_state["unlocked_sides"])

  return player

func _on_player_death(p):
  player_state["respawn_side"] = p.current_side
  if player_state["lives"] > 0:
    player_state["lives"] -= 1
    spawn_player()
  else:
    # TODO cheat-death system?
    print("no more lives")
    # game over

### progress ##############################################################

func unlock_next_side():
  var next_side = player_state["locked_sides"].pop_front()
  player_state["unlocked_sides"].append(next_side)
  # TODO animate
  hud.set_dice(player_state["unlocked_sides"])

func update_player_start(new_start):
  player_start = new_start

var next_level_dict = {
  "Level1": "goto_level2",
  "Level2": "goto_level3",
  "Level3": "win",
}

func goto_next_level():
  player_state["respawn_side"] = player.current_side
  player.kill_for_respawn()
  # NOTE depends on the 'name' set on the level node!! Brittle!
  var next_level_fn = next_level_dict[current_level.name]
  funcref(Nav, next_level_fn).call_func()
