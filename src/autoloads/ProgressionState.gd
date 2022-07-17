extends Node

var player_scene = preload("res://src/Player.tscn")
var hud: CanvasLayer
var pause_popup: PopupPanel
var gameover_popup: PopupPanel

var player_state = {
  "health": 1,
  "lives": 3,
  "respawn_side": "one",
  "clone_sides": ["three"],
}
var initial_player_state

var player_start
var player
var current_level: LevelBase

var clones = []

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
      var clone_sides = []
      for c in clones:
        clone_sides.append(c.current_side)
      player_state["clone_sides"] = clone_sides.duplicate()
      player.kill_for_respawn()
      for c in clones:
        clones.erase(c)
        c.kill_for_respawn()

    # yep
    gameover_popup.song.stop()

    # NOTE this allows for life after death
    if current_level:
      current_level.reset()

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

# spawn a clone by passing a position as the second arg
func spawn_player(pos:Position2D = player_start, clone_pos = null) -> Node:
  if not clone_pos:
    # don't update player start
    player_start = pos
  var state = ProgressionState.player_state

  var new_player = player_scene.instance()

  if clone_pos:
    new_player.current_side = "three" # arbitrary clone init
    new_player.set_side() # side-effect, sets the clone health
  else:
    # copy in health/lives for player
    for key in state:
      if key in new_player:
        new_player[key] = state[key]

  new_player.connect("death", self, "_on_player_death", [new_player])

  if clone_pos:
    new_player.position = clone_pos
    new_player.is_clone = true
    clones.append(new_player)
  else:
    new_player.position = player_start.position
    # maintain local `player` var
    player = new_player

  if Nav.current_scene:
    Nav.current_scene.call_deferred("add_child", new_player)
  else:
    assert(null, "not sure where to put player")
  # get_tree().get_root().call_deferred("add_child", player)

  update_hud()

  return new_player

func spawn_clone():
  var offset = Vector2(20, 20)
  var clone = spawn_player(null, player.get_global_position() + offset)
  # attach levelBase listeners
  current_level.setup_player(clone)
  return clone

func update_hud():
  hud.set_lives(player_state["lives"])

  if player and is_instance_valid(player):
    var clone_sides = []
    for c in clones:
      if c and is_instance_valid(c):
        clone_sides.append(c.current_side)

    print("setting hud dice: ", player.current_side, " - ", clone_sides)
    hud.set_dice(player.current_side, clone_sides)

func _on_player_death(p):
  if p.is_clone:
    print("clone death!")
    clones.erase(p)
    # make sure the player has the camera
    p.camera.current = true
  elif clones.size() > 0:
    # promote clone
    var new_p = clones.pop_front()
    player = new_p
    player.is_clone = false
    player_state["clone_sides"].erase(player.current_side)
    player_state["respawn_side"] = player.current_side

    player.camera.current = true # I think?
  else:
    player_state["respawn_side"] = "one"

    if player_state["lives"] > 0:
      player_state["lives"] -= 1
      current_level.reset()
    else:
      # TODO cheat-death system?
      print("no more lives")
      gameover_popup.show()
      gameover_popup.song.play()
      gameover_popup.voice.play()

  update_hud()

### upgrades ##############################################################

func upgrade_collected(_upgrade):
  # var next_side = player_state["locked_sides"].pop_front()
  if player.health < 6:
    print("player health less than six, incrementing")
    var next_side = Dice.side_for_num(player.health + 1)
    player_state["respawn_side"] = player.current_side
    player.set_side(next_side)
  else:
    print("player health six or more, looking for clone to heal")
    var upgraded_clone = false
    for c in clones:
      print("clone side: ", c.current_side, " health: ", c.health)
      if c.current_side != "six":
        print("found non-six clone ", c.current_side, " ", c)
        var next_side = Dice.side_for_num(c.health + 1)
        player_state["clone_sides"].erase(c.current_side)
        player_state["clone_sides"].append(next_side)
        c.set_side(next_side)
        upgraded_clone = true
        break

    if not upgraded_clone:
      print("no non-six clone, adding a new one")
      # create a new clone
      var c = spawn_clone()
      player_state["clone_sides"].append(c.current_side)

  update_hud()

### progress ##############################################################

# pah, this is definitely LevelBase logic
func update_player_start(new_start):
  player_start = new_start

var next_level_dict = {
  "Level1": "goto_level2",
  "Level2": "goto_level3",
  "Level3": "win",
}

func goto_next_level():
  player_state["respawn_side"] = player.current_side
  var clone_sides = []
  for c in clones:
    clone_sides.append(c.current_side)
  player_state["clone_sides"] = clone_sides.duplicate()
  player.kill_for_respawn()
  for c in clones:
    clones.erase(c)
    c.kill_for_respawn()

  # NOTE depends on the 'name' set on the level node!! Brittle!
  var next_level_fn = next_level_dict[current_level.name]
  funcref(Nav, next_level_fn).call_func()
