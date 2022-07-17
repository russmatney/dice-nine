extends Node2D
class_name LevelBase

var upgrade_scene = preload("res://src/Upgrade.tscn")
var enemy_scene = preload("res://src/Enemy.tscn")
var hud_scene = preload("res://src/ui/HUD.tscn")
var hud: CanvasLayer

onready var sounds = $Sounds

onready var player_start = $PlayerStart
var portals = []
var upgrades = []
var upgrade_starts = []

var enemies = []
var enemy_starts = []

signal enemies_cleared

# ready #######################################################################

func _ready():
  assert(player_start)
  assert(sounds)

  portals = get_tree().get_nodes_in_group("portals")
  upgrades = get_tree().get_nodes_in_group("upgrades")
  upgrade_starts = get_tree().get_nodes_in_group("upgrade_starts")
  enemies = get_tree().get_nodes_in_group("enemies")
  enemy_starts = get_tree().get_nodes_in_group("enemy_starts")

  if not hud or not is_instance_valid(hud):
      hud = hud_scene.instance()
      call_deferred("add_child", hud)

      hud.connect("ready", self, "setup_level")

  connect("enemies_cleared", self, "_on_enemies_cleared")

func setup_level():
  ProgressionState.ensure_hud()
  ProgressionState.ensure_pause()
  ProgressionState.ensure_gameover()
  ProgressionState.set_current_level(self)

  var player = ProgressionState.spawn_player(player_start)
  setup_player(player)

  var i = 0
  for clone_side in ProgressionState.player_state["clone_sides"]:
    var offset = Vector2(10, 10) * i
    var clone = ProgressionState.spawn_clone(offset)
    clone.set_side(clone_side)
    i += 1

  for u_st in upgrade_starts:
    spawn_upgrade(u_st)

  for e_st in enemy_starts:
    spawn_enemy(e_st)

func setup_player(p):
  p.connect("roll_start", self, "_on_player_roll_start")
  p.connect("rolled", self, "_on_player_rolled")
  p.connect("death", self, "_on_player_death", [p])

func reset():
  # remove left over upgrades
  for up in upgrades:
    if up and is_instance_valid(up):
      up.queue_free()

  # remove left over enemies
  for en in enemies:
    if en and is_instance_valid(en):
      en.queue_free()

  # reset level after player death
  setup_level()

### enemy spawn, death ###########################################################

func spawn_enemy(pos:Position2D):
  var enemy = enemy_scene.instance()
  enemies.append(enemy)
  enemy.connect("death", self, "_on_enemy_death", [enemy])
  enemy.position = pos.position
  var sides = [pos.initial_side]
  sides.append_array(pos.other_sides)
  enemy.available_sides = sides

  if Nav.current_scene:
    # prefer to add to the current scene, which gets cleaned up
    Nav.current_scene.call_deferred("add_child", enemy)
  else:
    get_tree().get_root().call_deferred("add_child", enemy)

func _on_enemy_death(en):
  enemies.erase(en)
  sounds.enemy_die_sound.play()

  if enemies.size() <= 0:
    emit_signal("enemies_cleared")
    sounds.enemies_cleared_sound.play()
  else:
    print(enemies.size(), " enemies remaining")

# _on_enemies_cleared #######################################################################

func _on_enemies_cleared():
  print("enemies cleared!")

# upgrades #######################################################################

func spawn_upgrade(pos:Position2D):
  var upgrade = upgrade_scene.instance()
  upgrades.append(upgrade)
  upgrade.connect("collected", self, "_on_upgrade_collected", [upgrade])
  upgrade.position = pos.position
  if Nav.current_scene:
    # prefer to add to the current scene, which gets cleaned up
    Nav.current_scene.call_deferred("add_child", upgrade)
  else:
    get_tree().get_root().call_deferred("add_child", upgrade)

# _on_upgrade_collected #######################################################################

func _on_upgrade_collected(upgrade):
  print("upgrade collected!")
  ProgressionState.upgrade_collected(upgrade)
  # TODO announcement via HUD/Notifs/Banner

# _on_player_death #######################################################################

func _on_player_death(_p):
  print("player death")
  sounds.player_death_sound.play()

# _on_player_roll_start #######################################################################

func _on_player_roll_start():
  print("player roll start")
  sounds.player_roll_sound.play()

# _on_player_rolled #######################################################################

func _on_player_rolled():
  print("player rolled")

# hide/show portals #######################################################################

func hide_portals():
  for p in portals:
    p.visible = false
    p.disabled = true

func show_portals():
  for p in portals:
    p.visible = true
    p.disabled = false
