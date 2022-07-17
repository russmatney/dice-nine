extends Node

var player_scene = preload("res://src/Player.tscn")
var hud: CanvasLayer
var pause_popup: PopupPanel
var gameover_popup: PopupPanel

var player_state = {
  # "unlocked_sides": ["one", "two"],
  "unlocked_sides": [],
  "locked_sides": ["one", "two", "three", "four", "five", "six"],
  "health": 1,
  "lives": 3,
  "respawn_side": "none",
}
var initial_player_state

var player_start
var player
var current_level: LevelBase

### level ####################################################################

func set_current_level(level: LevelBase):
  current_level = level

### ready ##############################################################

func _ready():
  initial_player_state = player_state.duplicate(true)

  pause_mode = Node.PAUSE_MODE_PROCESS

func reset_state():
  player_state = initial_player_state.duplicate(true)

func ensure_hud():
  if not hud or not is_instance_valid(hud):
    hud = get_tree().get_root().find_node("HUD", true, false)

  assert(hud, "asserting hud exists")

func ensure_pause():
  if not pause_popup or not is_instance_valid(pause_popup):
    pause_popup = get_tree().get_root().find_node("PausePopup", true, false)

  assert(pause_popup, "asserting pause_popup exists")

func ensure_gameover():
  if not gameover_popup or not is_instance_valid(gameover_popup):
    gameover_popup = get_tree().get_root().find_node("GameOver", true, false)

  assert(gameover_popup, "asserting gameover_popup exists")

### process ##############################################################

func _process(_delta):
  pass

### unhandled_input ##############################################################

func _unhandled_input(event):
  if event.is_action_pressed("respawn"):
    if is_instance_valid(player):
      player_state["respawn_side"] = player.current_side
      player.kill_for_respawn()

    # yep
    gameover_popup.song.stop()

    # TODO do we need to wait?
    # NOTE this allows for life after death
    spawn_player()

  if event.is_action_pressed("pause"):
    if get_tree().paused:
      resume()
    else:
      pause()

func pause():
  var t = get_tree()
  t.paused = true
  if pause_popup and is_instance_valid(pause_popup):
    pause_popup.show()
    pause_popup.resume_song()

func resume():
  var t = get_tree()
  if pause_popup and is_instance_valid(pause_popup):
    pause_popup.hide()
    pause_popup.pause_song()
  t.paused = false

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
  if Nav.current_scene:
    Nav.current_scene.call_deferred("add_child", player)
  else:
    assert(null, "not sure where to put player")
  # get_tree().get_root().call_deferred("add_child", player)

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
    gameover_popup.show()
    gameover_popup.song.play()
    gameover_popup.voice.play()


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
